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
local ____DoraAgent = require("Agent.DoraAgent") -- 4
local runCodingAgent = ____DoraAgent.runCodingAgent -- 4
local truncateAgentUserPrompt = ____DoraAgent.truncateAgentUserPrompt -- 4
local AgentToolRegistry = require("Agent.Tool.Registry") -- 6
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 7
local Tools = require("Agent.Tools") -- 8
local ____Database = require("Agent.Storage.Database") -- 9
local TABLE_SESSION = ____Database.TABLE_SESSION -- 10
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE -- 11
local TABLE_STEP = ____Database.TABLE_STEP -- 12
local TABLE_TASK = ____Database.TABLE_TASK -- 13
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE -- 14
local addTaskReference = ____Database.addTaskReference -- 15
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData -- 16
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds -- 17
local requireAgentStorage = ____Database.requireAgentStorage -- 18
local ____Memory = require("Agent.Memory") -- 20
local DualLayerStorage = ____Memory.DualLayerStorage -- 20
local ____Utils = require("Agent.Utils") -- 21
local Log = ____Utils.Log -- 21
local getLLMConfig = ____Utils.getLLMConfig -- 21
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 21
local safeJsonDecode = ____Utils.safeJsonDecode -- 21
local safeJsonEncode = ____Utils.safeJsonEncode -- 21
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 21
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig -- 21
local ____Questionnaire = require("Agent.Questionnaire") -- 25
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers -- 25
local ____Support = require("Agent.Storage.Support") -- 27
local getLastInsertRowId = ____Support.getLastInsertRowId -- 27
local queryOne = ____Support.queryOne -- 27
local queryRows = ____Support.queryRows -- 27
local toStr = ____Support.toStr -- 27
function getDefaultUseChineseResponse() -- 330
	local zh = string.match(App.locale, "^zh") -- 331
	return zh ~= nil -- 332
end -- 332
function encodeJson(value) -- 335
	local text = safeJsonEncode(value) -- 336
	return text or "" -- 337
end -- 337
function decodeJsonObject(text) -- 340
	if not text or text == "" then -- 340
		return nil -- 341
	end -- 341
	local value = safeJsonDecode(text) -- 342
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 342
		return value -- 344
	end -- 344
	return nil -- 346
end -- 346
function decodeJsonFiles(text) -- 349
	if not text or text == "" then -- 349
		return nil -- 350
	end -- 350
	local value = safeJsonDecode(text) -- 351
	if not value or not __TS__ArrayIsArray(value) then -- 351
		return nil -- 352
	end -- 352
	local files = {} -- 353
	do -- 353
		local i = 0 -- 354
		while i < #value do -- 354
			do -- 354
				local item = value[i + 1] -- 355
				if type(item) ~= "table" then -- 355
					goto __continue12 -- 356
				end -- 356
				files[#files + 1] = { -- 357
					path = sanitizeUTF8(toStr(item.path)), -- 358
					op = sanitizeUTF8(toStr(item.op)) -- 359
				} -- 359
			end -- 359
			::__continue12:: -- 359
			i = i + 1 -- 354
		end -- 354
	end -- 354
	return files -- 362
end -- 362
function decodeChangeSetSummary(value) -- 365
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 365
		return nil -- 366
	end -- 366
	local row = value -- 367
	if row.success ~= true then -- 367
		return nil -- 368
	end -- 368
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 369
	if taskId <= 0 then -- 369
		return nil -- 370
	end -- 370
	local files = {} -- 371
	if __TS__ArrayIsArray(row.files) then -- 371
		do -- 371
			local i = 0 -- 373
			while i < #row.files do -- 373
				do -- 373
					local file = row.files[i + 1] -- 374
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 374
						goto __continue20 -- 375
					end -- 375
					local fileRow = file -- 376
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 377
					if path == "" then -- 377
						goto __continue20 -- 378
					end -- 378
					local checkpointIds = {} -- 379
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 379
						do -- 379
							local j = 0 -- 381
							while j < #fileRow.checkpointIds do -- 381
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 382
								if checkpointId > 0 then -- 382
									checkpointIds[#checkpointIds + 1] = checkpointId -- 383
								end -- 383
								j = j + 1 -- 381
							end -- 381
						end -- 381
					end -- 381
					local op = toStr(fileRow.op) -- 386
					files[#files + 1] = { -- 387
						path = path, -- 388
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 389
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 390
						checkpointIds = checkpointIds -- 391
					} -- 391
				end -- 391
				::__continue20:: -- 391
				i = i + 1 -- 373
			end -- 373
		end -- 373
	end -- 373
	return { -- 395
		success = true, -- 396
		taskId = taskId, -- 397
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 398
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 399
		files = files, -- 400
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 401
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 402
	} -- 402
end -- 402
function decodeHandoffEvidence(value) -- 406
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 406
		return nil -- 407
	end -- 407
	local row = value -- 408
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 409
		__TS__ArrayFilter( -- 410
			row.modifiedFiles, -- 410
			function(____, item) return type(item) == "string" end -- 410
		), -- 410
		function(____, item) return sanitizeUTF8(item) end -- 410
	) or ({}) -- 410
	local lastBuild = nil -- 412
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 412
		local build = row.lastBuild -- 414
		lastBuild = { -- 415
			result = build.result == "passed" and "passed" or "failed", -- 416
			path = sanitizeUTF8(toStr(build.path)), -- 417
			evidence = takeUtf8Head( -- 418
				sanitizeUTF8(toStr(build.evidence)), -- 418
				600 -- 418
			) -- 418
		} -- 418
	end -- 418
	local commands = {} -- 421
	if __TS__ArrayIsArray(row.commands) then -- 421
		do -- 421
			local i = 0 -- 423
			while i < #row.commands and #commands < 8 do -- 423
				do -- 423
					local raw = row.commands[i + 1] -- 424
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 424
						goto __continue34 -- 425
					end -- 425
					local item = raw -- 426
					commands[#commands + 1] = { -- 427
						mode = sanitizeUTF8(toStr(item.mode)), -- 428
						command = takeUtf8Head( -- 429
							sanitizeUTF8(toStr(item.command)), -- 429
							600 -- 429
						), -- 429
						result = item.result == "passed" and "passed" or "failed", -- 430
						evidence = takeUtf8Head( -- 431
							sanitizeUTF8(toStr(item.evidence)), -- 431
							600 -- 431
						) -- 431
					} -- 431
				end -- 431
				::__continue34:: -- 431
				i = i + 1 -- 423
			end -- 423
		end -- 423
	end -- 423
	local authoritativeSources = {} -- 435
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 435
		do -- 435
			local i = 0 -- 437
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 437
				do -- 437
					local raw = row.authoritativeSources[i + 1] -- 438
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 438
						goto __continue38 -- 439
					end -- 439
					local item = raw -- 440
					authoritativeSources[#authoritativeSources + 1] = { -- 441
						tool = "search_dora_doc", -- 442
						query = takeUtf8Head( -- 443
							sanitizeUTF8(toStr(item.query)), -- 443
							300 -- 443
						), -- 443
						source = sanitizeUTF8(toStr(item.source)), -- 444
						result = item.result == "passed" and "passed" or "failed" -- 445
					} -- 445
				end -- 445
				::__continue38:: -- 445
				i = i + 1 -- 437
			end -- 437
		end -- 437
	end -- 437
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 449
end -- 449
function takeUtf8Head(text, maxChars) -- 452
	if maxChars <= 0 or text == "" then -- 452
		return "" -- 453
	end -- 453
	local nextPos = utf8.offset(text, maxChars + 1) -- 454
	if nextPos == nil then -- 454
		return text -- 455
	end -- 455
	return string.sub(text, 1, nextPos - 1) -- 456
end -- 456
function normalizeMemoryEntryEvidence(value) -- 459
	local evidence = {} -- 460
	if not __TS__ArrayIsArray(value) then -- 460
		return evidence -- 461
	end -- 461
	do -- 461
		local i = 0 -- 462
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 462
			do -- 462
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 463
				if item == "" then -- 463
					goto __continue46 -- 464
				end -- 464
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 464
					evidence[#evidence + 1] = item -- 466
				end -- 466
			end -- 466
			::__continue46:: -- 466
			i = i + 1 -- 462
		end -- 462
	end -- 462
	return evidence -- 469
end -- 469
function decodeSubAgentMemoryEntry(value) -- 472
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 472
		return nil -- 473
	end -- 473
	local row = value -- 474
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 475
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 476
	local content = takeUtf8Head( -- 477
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 477
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 477
	) -- 477
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 477
		return nil -- 478
	end -- 478
	return { -- 479
		sourceSessionId = sourceSessionId, -- 480
		sourceTaskId = sourceTaskId, -- 481
		content = content, -- 482
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 483
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 484
	} -- 484
end -- 484
function getTaskChangeSetSummary(taskId) -- 488
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 489
	return summary.success and summary or nil -- 490
end -- 490
function summarizeHandoffResult(result) -- 493
	local candidates = {result.output, result.message, result.state, result.phase} -- 494
	do -- 494
		local i = 0 -- 495
		while i < #candidates do -- 495
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 496
			if text ~= "" then -- 496
				return takeUtf8Head(text, 600) -- 497
			end -- 497
			i = i + 1 -- 495
		end -- 495
	end -- 495
	local messages = result.messages -- 499
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 499
		local parts = {} -- 501
		do -- 501
			local i = 0 -- 502
			while i < #messages and #parts < 4 do -- 502
				do -- 502
					local row = messages[i + 1] -- 503
					if not row or type(row) ~= "table" then -- 503
						goto __continue59 -- 504
					end -- 504
					local item = row -- 505
					local ____sanitizeUTF8_3 = sanitizeUTF8 -- 506
					local ____toStr_2 = toStr -- 506
					local ____item_message_0 = item.message -- 506
					if ____item_message_0 == nil then -- 506
						____item_message_0 = item.error -- 506
					end -- 506
					local ____item_message_0_1 = ____item_message_0 -- 506
					if ____item_message_0_1 == nil then -- 506
						____item_message_0_1 = item.file -- 506
					end -- 506
					local text = __TS__StringTrim(____sanitizeUTF8_3(____toStr_2(____item_message_0_1))) -- 506
					if text ~= "" then -- 506
						parts[#parts + 1] = text -- 507
					end -- 507
				end -- 507
				::__continue59:: -- 507
				i = i + 1 -- 502
			end -- 502
		end -- 502
		if #parts > 0 then -- 502
			return takeUtf8Head( -- 509
				table.concat(parts, "; "), -- 509
				600 -- 509
			) -- 509
		end -- 509
	end -- 509
	return result.success == true and "tool result success=true" or "tool result success=false" -- 511
end -- 511
function getTaskHandoffEvidence(taskId, changeSet) -- 514
	local ____opt_4 = changeSet -- 514
	local evidence = { -- 515
		modifiedFiles = ____opt_4 and __TS__ArrayMap( -- 516
			changeSet and changeSet.files, -- 516
			function(____, item) return item.path end -- 516
		) or ({}), -- 516
		commands = {}, -- 517
		authoritativeSources = {} -- 518
	} -- 518
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 520
	do -- 520
		local i = 0 -- 525
		while i < #rows do -- 525
			local tool = toStr(rows[i + 1][1]) -- 526
			local status = toStr(rows[i + 1][2]) -- 527
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 528
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 529
			local passed = status == "DONE" and result.success == true -- 530
			if tool == "build" then -- 530
				evidence.lastBuild = { -- 532
					result = passed and "passed" or "failed", -- 533
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 534
					evidence = summarizeHandoffResult(result) -- 535
				} -- 535
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 535
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 538
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 539
				local ____evidence_commands_8 = evidence.commands -- 539
				____evidence_commands_8[#____evidence_commands_8 + 1] = { -- 540
					mode = mode, -- 541
					command = takeUtf8Head( -- 542
						__TS__StringTrim(sanitizeUTF8(command)), -- 542
						600 -- 542
					), -- 542
					result = passed and "passed" or "failed", -- 543
					evidence = summarizeHandoffResult(result) -- 544
				} -- 544
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 544
				local ____evidence_authoritativeSources_9 = evidence.authoritativeSources -- 544
				____evidence_authoritativeSources_9[#____evidence_authoritativeSources_9 + 1] = { -- 547
					tool = "search_dora_doc", -- 548
					query = takeUtf8Head( -- 549
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 549
						300 -- 549
					), -- 549
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 550
					result = passed and "passed" or "failed" -- 551
				} -- 551
			end -- 551
			i = i + 1 -- 525
		end -- 525
	end -- 525
	return evidence -- 555
end -- 555
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 558
	local lastBuild = evidence.lastBuild -- 562
	if not lastBuild or lastBuild.result ~= "failed" then -- 562
		return completion -- 563
	end -- 563
	local validation = __TS__ArraySlice(completion.validation) -- 564
	local foundBuild = false -- 565
	do -- 565
		local i = 0 -- 566
		while i < #validation do -- 566
			do -- 566
				if validation[i + 1].kind ~= "build" then -- 566
					goto __continue73 -- 567
				end -- 567
				foundBuild = true -- 568
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 569
			end -- 569
			::__continue73:: -- 569
			i = i + 1 -- 566
		end -- 566
	end -- 566
	if not foundBuild then -- 566
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 576
	end -- 576
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 578
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 579
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 579
		knownIssues[#knownIssues + 1] = issue -- 580
	end -- 580
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 581
end -- 581
function isValidProjectRoot(path) -- 589
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 590
end -- 590
function rowToSession(row) -- 593
	return { -- 594
		id = row[1], -- 595
		projectRoot = toStr(row[2]), -- 596
		title = toStr(row[3]), -- 597
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 598
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 599
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 600
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 601
		status = toStr(row[8]), -- 602
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 603
		currentTaskStatus = toStr(row[10]), -- 604
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 605
		createdAt = row[11], -- 606
		updatedAt = row[12], -- 607
		metrics = decodeJsonObject(toStr(row[13])), -- 608
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 609
	} -- 609
end -- 609
function rowToMessage(row) -- 613
	local message = { -- 614
		id = row[1], -- 615
		sessionId = row[2], -- 616
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 617
		role = toStr(row[4]), -- 618
		content = toStr(row[5]), -- 619
		createdAt = row[7], -- 620
		updatedAt = row[8] -- 621
	} -- 621
	local displayContent = toStr(row[6]) -- 623
	if displayContent ~= "" then -- 623
		message.displayContent = displayContent -- 624
	end -- 624
	return message -- 625
end -- 625
function rowToStep(row) -- 628
	return { -- 629
		id = row[1], -- 630
		sessionId = row[2], -- 631
		taskId = row[3], -- 632
		step = row[4], -- 633
		tool = toStr(row[5]), -- 634
		status = toStr(row[6]), -- 635
		reason = toStr(row[7]), -- 636
		reasoningContent = toStr(row[8]), -- 637
		params = decodeJsonObject(toStr(row[9])), -- 638
		result = decodeJsonObject(toStr(row[10])), -- 639
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 640
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 641
		files = decodeJsonFiles(toStr(row[13])), -- 642
		createdAt = row[14], -- 643
		updatedAt = row[15] -- 644
	} -- 644
end -- 644
function getQuestionnairePath(projectRoot) -- 648
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 649
end -- 649
function decodeQuestionnaireFile(text) -- 652
	local value = decodeJsonObject(text) -- 653
	if not value then -- 653
		return nil -- 654
	end -- 654
	local schema = value.schema -- 655
	local id = type(value.id) == "number" and value.id or 0 -- 656
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 657
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 658
	local step = type(value.step) == "number" and value.step or 0 -- 659
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 660
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 660
		return nil -- 662
	end -- 662
	return { -- 664
		id = id, -- 664
		sessionId = sessionId, -- 664
		taskId = taskId, -- 664
		step = step, -- 664
		status = "PENDING", -- 664
		schema = schema, -- 664
		createdAt = createdAt -- 664
	} -- 664
end -- 664
function getPendingQuestionnaire(sessionId) -- 667
	local session = getSessionItem(sessionId) -- 668
	if not session or session.kind ~= "main" then -- 668
		return nil -- 669
	end -- 669
	local path = getQuestionnairePath(session.projectRoot) -- 670
	if not Content:exist(path) then -- 670
		return nil -- 671
	end -- 671
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 672
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 673
end -- 673
function restorePendingQuestionnaireState(session) -- 676
	local questionnaire = getPendingQuestionnaire(session.id) -- 677
	if not questionnaire then -- 677
		return {session = session} -- 678
	end -- 678
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 678
		local t = now() -- 685
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 686
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 692
		local restored = getSessionItem(session.id) -- 693
		if restored then -- 693
			session = restored -- 694
		end -- 694
	end -- 694
	return {session = session, questionnaire = questionnaire} -- 696
end -- 696
function savePendingQuestionnaire(projectRoot, questionnaire) -- 699
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 700
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 700
		return false -- 701
	end -- 701
	local path = getQuestionnairePath(projectRoot) -- 702
	local tempPath = path .. ".tmp" -- 703
	local backupPath = path .. ".bak" -- 704
	Content:remove(tempPath) -- 705
	Content:remove(backupPath) -- 706
	if not Content:save( -- 706
		tempPath, -- 707
		encodeJson(questionnaire) -- 707
	) then -- 707
		return false -- 707
	end -- 707
	local hadOriginal = Content:exist(path) -- 708
	if hadOriginal and not Content:move(path, backupPath) then -- 708
		Content:remove(tempPath) -- 710
		return false -- 711
	end -- 711
	if Content:move(tempPath, path) then -- 711
		Content:remove(backupPath) -- 714
		Tools.sendWebIDEFileUpdate( -- 715
			path, -- 715
			true, -- 715
			encodeJson(questionnaire) -- 715
		) -- 715
		return true -- 716
	end -- 716
	Content:remove(tempPath) -- 718
	if hadOriginal and Content:exist(backupPath) then -- 718
		Content:move(backupPath, path) -- 720
	end -- 720
	return false -- 722
end -- 722
function removePendingQuestionnaire(session) -- 725
	local path = getQuestionnairePath(session.projectRoot) -- 726
	if not Content:exist(path) then -- 726
		return true -- 727
	end -- 727
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 728
	if questionnaire and questionnaire.sessionId ~= session.id then -- 728
		return false -- 729
	end -- 729
	if not Content:remove(path) then -- 729
		return false -- 730
	end -- 730
	Tools.sendWebIDEFileUpdate(path, false, "") -- 731
	return true -- 732
end -- 732
function publishQuestionnaire(request) -- 735
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 735
		local session = getSessionItem(request.sessionId) -- 741
		if not session or session.kind ~= "main" then -- 741
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 741
		end -- 741
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 743
		if Content:exist(pendingPath) then -- 743
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 743
		end -- 743
		local questionnaire = { -- 745
			id = request.taskId, -- 746
			sessionId = request.sessionId, -- 747
			taskId = request.taskId, -- 748
			step = request.step, -- 749
			status = "PENDING", -- 750
			schema = request.schema, -- 751
			createdAt = now() -- 752
		} -- 752
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 752
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 752
		end -- 752
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 752
	end) -- 752
end -- 752
function getMessageItem(messageId) -- 760
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 761
	return row and rowToMessage(row) or nil -- 767
end -- 767
function getStepItem(sessionId, taskId, step) -- 770
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 771
	return row and rowToStep(row) or nil -- 777
end -- 777
function deleteMessageSteps(sessionId, taskId) -- 780
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 781
	local ids = {} -- 786
	do -- 786
		local i = 0 -- 787
		while i < #rows do -- 787
			local row = rows[i + 1] -- 788
			if type(row[1]) == "number" then -- 788
				ids[#ids + 1] = row[1] -- 790
			end -- 790
			i = i + 1 -- 787
		end -- 787
	end -- 787
	if #ids > 0 then -- 787
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 794
	end -- 794
	return ids -- 800
end -- 800
function normalizeDisabledAgentTools(value) -- 803
	if not __TS__ArrayIsArray(value) then -- 803
		return {} -- 804
	end -- 804
	local tools = {} -- 805
	do -- 805
		local i = 0 -- 806
		while i < #value do -- 806
			do -- 806
				local name = value[i + 1] -- 807
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 807
					goto __continue117 -- 808
				end -- 808
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 808
					tools[#tools + 1] = name -- 809
				end -- 809
			end -- 809
			::__continue117:: -- 809
			i = i + 1 -- 806
		end -- 806
	end -- 806
	return tools -- 811
end -- 811
function normalizeWorkMode(value, fallback) -- 814
	if fallback == nil then -- 814
		fallback = "code" -- 814
	end -- 814
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 815
end -- 815
function getSessionRow(sessionId) -- 818
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 819
end -- 819
function getSessionItem(sessionId) -- 827
	local row = getSessionRow(sessionId) -- 828
	return row and rowToSession(row) or nil -- 829
end -- 829
function getTaskPrompt(taskId) -- 832
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 833
	if not row or type(row[1]) ~= "string" then -- 833
		return nil -- 834
	end -- 834
	return toStr(row[1]) -- 835
end -- 835
function getLatestMainSessionByProjectRoot(projectRoot) -- 838
	if not isValidProjectRoot(projectRoot) then -- 838
		return nil -- 839
	end -- 839
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 840
	return row and rowToSession(row) or nil -- 848
end -- 848
function countRunningSubSessions(rootSessionId) -- 851
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 852
	local count = 0 -- 859
	do -- 859
		local i = 0 -- 860
		while i < #rows do -- 860
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 861
			if session.currentTaskStatus == "RUNNING" then -- 861
				count = count + 1 -- 863
			end -- 863
			i = i + 1 -- 860
		end -- 860
	end -- 860
	return count -- 866
end -- 866
function deleteSessionRecords(sessionId, preserveArtifacts) -- 869
	if preserveArtifacts == nil then -- 869
		preserveArtifacts = false -- 869
	end -- 869
	local session = getSessionItem(sessionId) -- 870
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 871
	local taskIds = {} -- 879
	do -- 879
		local i = 0 -- 880
		while i < #taskRows do -- 880
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 881
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 881
				taskIds[#taskIds + 1] = taskId -- 883
				local stopToken = activeStopTokens[taskId] -- 884
				if stopToken ~= nil then -- 884
					stopToken.stopped = true -- 886
					stopToken.reason = "session deleted" -- 887
				end -- 887
			end -- 887
			i = i + 1 -- 880
		end -- 880
	end -- 880
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 891
	do -- 891
		local i = 0 -- 892
		while i < #children do -- 892
			local row = children[i + 1] -- 893
			if type(row[1]) == "number" and row[1] > 0 then -- 893
				deleteSessionRecords(row[1], preserveArtifacts) -- 895
			end -- 895
			i = i + 1 -- 892
		end -- 892
	end -- 892
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 898
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 899
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 900
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 901
	if session and session.kind == "main" then -- 901
		removePendingQuestionnaire(session) -- 903
	end -- 903
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 903
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 903
			Tools.sendWebIDERefreshTree() -- 907
		end -- 907
	end -- 907
	do -- 907
		local i = 0 -- 910
		while i < #taskIds do -- 910
			cleanupTaskHeavyData(taskIds[i + 1]) -- 911
			i = i + 1 -- 910
		end -- 910
	end -- 910
end -- 910
function getSessionRootId(session) -- 915
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 916
end -- 916
function getRootSessionItem(sessionId) -- 919
	local session = getSessionItem(sessionId) -- 920
	if not session then -- 920
		return nil -- 921
	end -- 921
	return getSessionItem(getSessionRootId(session)) or session -- 922
end -- 922
function listRelatedSessions(sessionId) -- 925
	local root = getRootSessionItem(sessionId) -- 926
	if not root then -- 926
		return {} -- 927
	end -- 927
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 928
	return __TS__ArrayMap( -- 937
		rows, -- 937
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 937
	) -- 937
end -- 937
function getSessionSpawnInfo(session) -- 940
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 941
	if not info then -- 941
		return nil -- 942
	end -- 942
	local ____temp_15 = type(info.sessionId) == "number" and info.sessionId or nil -- 944
	local ____temp_16 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 945
	local ____temp_17 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 946
	local ____temp_18 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 947
	local ____temp_19 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 948
	local ____temp_20 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 949
	local ____temp_21 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 950
	local ____temp_22 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 951
		__TS__ArrayFilter( -- 952
			info.filesHint, -- 952
			function(____, item) return type(item) == "string" end -- 952
		), -- 952
		function(____, item) return sanitizeUTF8(item) end -- 952
	) or nil -- 952
	local ____temp_23 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 954
	local ____temp_13 -- 957
	if info.success == true then -- 957
		____temp_13 = true -- 957
	else -- 957
		local ____temp_12 -- 957
		if info.success == false then -- 957
			____temp_12 = false -- 957
		else -- 957
			____temp_12 = nil -- 957
		end -- 957
		____temp_13 = ____temp_12 -- 957
	end -- 957
	local ____temp_14 -- 958
	if info.cleared == true then -- 958
		____temp_14 = true -- 958
	else -- 958
		____temp_14 = nil -- 958
	end -- 958
	return { -- 943
		sessionId = ____temp_15, -- 944
		rootSessionId = ____temp_16, -- 945
		parentSessionId = ____temp_17, -- 946
		title = ____temp_18, -- 947
		prompt = ____temp_19, -- 948
		goal = ____temp_20, -- 949
		expectedOutput = ____temp_21, -- 950
		filesHint = ____temp_22, -- 951
		status = ____temp_23, -- 954
		success = ____temp_13, -- 957
		cleared = ____temp_14, -- 958
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 959
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 960
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 961
		changeSet = decodeChangeSetSummary(info.changeSet), -- 962
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 963
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 964
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 965
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 966
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 969
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 970
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 971
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 972
	} -- 972
end -- 972
function ensureDirRecursive(dir) -- 989
	if not dir or dir == "" then -- 989
		return false -- 990
	end -- 990
	if Content:exist(dir) then -- 990
		return Content:isdir(dir) -- 991
	end -- 991
	local parent = Path:getPath(dir) -- 992
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 992
		if not ensureDirRecursive(parent) then -- 992
			return false -- 995
		end -- 995
	end -- 995
	return Content:mkdir(dir) -- 998
end -- 998
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1001
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1002
	if not Content:exist(dir) then -- 1002
		ensureDirRecursive(dir) -- 1004
	end -- 1004
	local path = Path(dir, SPAWN_INFO_FILE) -- 1006
	local text = safeJsonEncode(value) -- 1007
	if not text then -- 1007
		return false -- 1008
	end -- 1008
	local content = text .. "\n" -- 1009
	if not Content:save(path, content) then -- 1009
		return false -- 1011
	end -- 1011
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1013
	return true -- 1014
end -- 1014
function readSpawnInfo(projectRoot, memoryScope) -- 1017
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1018
	if not Content:exist(path) then -- 1018
		return nil -- 1019
	end -- 1019
	local text = Content:load(path) -- 1020
	if not text or __TS__StringTrim(text) == "" then -- 1020
		return nil -- 1021
	end -- 1021
	local value = safeJsonDecode(text) -- 1022
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1022
		return value -- 1024
	end -- 1024
	return nil -- 1026
end -- 1026
function getArtifactRelativeDir(memoryScope) -- 1029
	return Path(".agent", memoryScope) -- 1030
end -- 1030
function getArtifactDir(projectRoot, memoryScope) -- 1033
	return Path( -- 1034
		projectRoot, -- 1034
		getArtifactRelativeDir(memoryScope) -- 1034
	) -- 1034
end -- 1034
function getResultRelativePath(memoryScope) -- 1037
	return Path( -- 1038
		getArtifactRelativeDir(memoryScope), -- 1038
		RESULT_FILE -- 1038
	) -- 1038
end -- 1038
function getResultPath(projectRoot, memoryScope) -- 1041
	return Path( -- 1042
		projectRoot, -- 1042
		getResultRelativePath(memoryScope) -- 1042
	) -- 1042
end -- 1042
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1045
	if not resultFilePath or resultFilePath == "" then -- 1045
		return "" -- 1046
	end -- 1046
	local path = Path(projectRoot, resultFilePath) -- 1047
	if not Content:exist(path) then -- 1047
		return "" -- 1048
	end -- 1048
	local text = sanitizeUTF8(Content:load(path)) -- 1049
	if not text or __TS__StringTrim(text) == "" then -- 1049
		return "" -- 1050
	end -- 1050
	local marker = "\n## Summary\n" -- 1051
	local start = string.find(text, marker, 1, true) -- 1052
	if start ~= nil then -- 1052
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1054
	end -- 1054
	return __TS__StringTrim(text) -- 1056
end -- 1056
function buildStructuredSubAgentMemoryEntry(record) -- 1059
	local hasPassedValidation = false -- 1060
	do -- 1060
		local i = 0 -- 1061
		while i < #record.completion.validation do -- 1061
			local result = record.completion.validation[i + 1].result -- 1062
			if result == "failed" then -- 1062
				return nil -- 1067
			end -- 1067
			if result == "passed" then -- 1067
				hasPassedValidation = true -- 1069
			end -- 1069
			i = i + 1 -- 1061
		end -- 1061
	end -- 1061
	if not hasPassedValidation then -- 1061
		return nil -- 1072
	end -- 1072
	local candidates = record.completion.learningCandidates -- 1073
	local claims = {} -- 1074
	local evidence = {} -- 1075
	do -- 1075
		local i = 0 -- 1076
		while i < #candidates do -- 1076
			do -- 1076
				local candidate = candidates[i + 1] -- 1077
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1077
					goto __continue188 -- 1078
				end -- 1078
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1079
				do -- 1079
					local j = 0 -- 1080
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1080
						local item = candidate.evidence[j + 1] -- 1081
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1081
							evidence[#evidence + 1] = item -- 1082
						end -- 1082
						j = j + 1 -- 1080
					end -- 1080
				end -- 1080
			end -- 1080
			::__continue188:: -- 1080
			i = i + 1 -- 1076
		end -- 1076
	end -- 1076
	local content = takeUtf8Head( -- 1085
		table.concat(claims, "\n"), -- 1085
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1085
	) -- 1085
	if content == "" then -- 1085
		return nil -- 1086
	end -- 1086
	return { -- 1087
		sourceSessionId = record.sessionId, -- 1088
		sourceTaskId = record.sourceTaskId, -- 1089
		content = content, -- 1090
		evidence = evidence, -- 1091
		createdAt = record.finishedAt -- 1092
	} -- 1092
end -- 1092
function containsNormalizedText(text, query) -- 1096
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1097
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1098
	if normalizedQuery == "" then -- 1098
		return true -- 1099
	end -- 1099
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1100
end -- 1100
function getSubAgentDisplayKey(item) -- 1103
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1109
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1110
	local label = goal ~= "" and goal or title -- 1111
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1112
end -- 1112
function writeSubAgentResultFile(session, record, resultText) -- 1115
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1116
	if not Content:exist(dir) then -- 1116
		ensureDirRecursive(dir) -- 1118
	end -- 1118
	local ____array_32 = __TS__SparseArrayNew( -- 1118
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1121
		"- Status: " .. record.status, -- 1122
		"- Success: " .. (record.success and "true" or "false"), -- 1123
		"- Outcome: " .. record.completion.outcome, -- 1124
		"- Session ID: " .. tostring(record.sessionId), -- 1125
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1126
		"- Goal: " .. record.goal, -- 1127
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1128
	) -- 1128
	__TS__SparseArrayPush( -- 1128
		____array_32, -- 1128
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1129
	) -- 1129
	__TS__SparseArrayPush( -- 1129
		____array_32, -- 1129
		"- Finished At: " .. record.finishedAt, -- 1130
		"", -- 1131
		"## Validation", -- 1132
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1133
			record.completion.validation, -- 1134
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1134
		) or ({"- Not reported"})) -- 1134
	) -- 1134
	__TS__SparseArrayPush(____array_32, "", "## Recorded Evidence") -- 1134
	local ____opt_24 = record.handoffEvidence -- 1134
	__TS__SparseArrayPush( -- 1134
		____array_32, -- 1134
		table.unpack(____opt_24 and #____opt_24.modifiedFiles and __TS__ArrayMap( -- 1138
			record.handoffEvidence.modifiedFiles, -- 1139
			function(____, item) return "- modified: " .. item end -- 1139
		) or ({"- modified: none recorded"})) -- 1139
	) -- 1139
	local ____opt_26 = record.handoffEvidence -- 1139
	__TS__SparseArrayPush( -- 1139
		____array_32, -- 1139
		table.unpack(____opt_26 and ____opt_26.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1141
	) -- 1141
	local ____opt_28 = record.handoffEvidence -- 1141
	__TS__SparseArrayPush( -- 1141
		____array_32, -- 1141
		table.unpack(__TS__ArrayMap( -- 1144
			____opt_28 and ____opt_28.commands or ({}), -- 1144
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1144
		)) -- 1144
	) -- 1144
	local ____opt_30 = record.handoffEvidence -- 1144
	__TS__SparseArrayPush( -- 1144
		____array_32, -- 1144
		table.unpack(__TS__ArrayMap( -- 1145
			____opt_30 and ____opt_30.authoritativeSources or ({}), -- 1145
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1145
		)) -- 1145
	) -- 1145
	__TS__SparseArrayPush( -- 1145
		____array_32, -- 1145
		"", -- 1146
		"## Known Issues", -- 1147
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1148
			record.completion.knownIssues, -- 1148
			function(____, item) return "- " .. item end -- 1148
		) or ({"- None reported"})) -- 1148
	) -- 1148
	__TS__SparseArrayPush( -- 1148
		____array_32, -- 1148
		"", -- 1149
		"## Assumptions", -- 1150
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1151
			record.completion.assumptions, -- 1151
			function(____, item) return "- " .. item end -- 1151
		) or ({"- None reported"})) -- 1151
	) -- 1151
	__TS__SparseArrayPush(____array_32, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1151
	local lines = {__TS__SparseArraySpread(____array_32)} -- 1120
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1156
	local content = table.concat(lines, "\n") .. "\n" -- 1157
	if not Content:save(path, content) then -- 1157
		return false -- 1159
	end -- 1159
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1161
	return true -- 1162
end -- 1162
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1165
	local dir = Path(projectRoot, ".agent", "subagents") -- 1166
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1166
		return {} -- 1167
	end -- 1167
	local items = {} -- 1168
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1169
		do -- 1169
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1170
			if not Content:exist(path) or not Content:isdir(path) then -- 1170
				goto __continue208 -- 1171
			end -- 1171
			local info = readSpawnInfo( -- 1172
				projectRoot, -- 1172
				Path( -- 1172
					"subagents", -- 1172
					Path:getFilename(path) -- 1172
				) -- 1172
			) -- 1172
			if not info then -- 1172
				goto __continue208 -- 1173
			end -- 1173
			local sessionId = tonumber(info.sessionId) -- 1174
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1175
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1176
			local status = sanitizeUTF8(toStr(info.status)) -- 1177
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1177
				goto __continue208 -- 1178
			end -- 1178
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1178
				goto __continue208 -- 1179
			end -- 1179
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1180
			items[#items + 1] = { -- 1181
				sessionId = sessionId, -- 1182
				rootSessionId = infoRootSessionId, -- 1183
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1184
				title = sanitizeUTF8(toStr(info.title)), -- 1185
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1186
				goal = sanitizeUTF8(toStr(info.goal)), -- 1187
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1188
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1189
					__TS__ArrayFilter( -- 1190
						info.filesHint, -- 1190
						function(____, item) return type(item) == "string" end -- 1190
					), -- 1190
					function(____, item) return sanitizeUTF8(item) end -- 1190
				) or ({}), -- 1190
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1192
				success = info.success == true, -- 1193
				cleared = info.cleared == true, -- 1194
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1195
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1196
					"subagents", -- 1196
					Path:getFilename(path) -- 1196
				)), -- 1196
				sourceTaskId = sourceTaskId or 0, -- 1197
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1198
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1199
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1200
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1201
				completion = normalizeAgentCompletionReport(info.completion), -- 1202
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1203
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1204
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1205
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1206
			} -- 1206
		end -- 1206
		::__continue208:: -- 1206
	end -- 1206
	__TS__ArraySort( -- 1209
		items, -- 1209
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1209
	) -- 1209
	return items -- 1210
end -- 1210
function getPendingHandoffDir(projectRoot, memoryScope) -- 1213
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1214
end -- 1214
function writePendingHandoff(projectRoot, memoryScope, value) -- 1217
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1218
	if not Content:exist(dir) then -- 1218
		ensureDirRecursive(dir) -- 1220
	end -- 1220
	local path = Path(dir, value.id .. ".json") -- 1222
	local text = safeJsonEncode(value) -- 1223
	if not text then -- 1223
		return false -- 1224
	end -- 1224
	local content = text .. "\n" -- 1225
	if not Content:save(path, content) then -- 1225
		return false -- 1226
	end -- 1226
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1227
	return true -- 1228
end -- 1228
function listPendingHandoffs(projectRoot, memoryScope) -- 1231
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1232
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1232
		return {} -- 1233
	end -- 1233
	local items = {} -- 1234
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1235
		do -- 1235
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1236
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1236
				goto __continue224 -- 1237
			end -- 1237
			local text = Content:load(path) -- 1238
			if not text or __TS__StringTrim(text) == "" then -- 1238
				goto __continue224 -- 1239
			end -- 1239
			local obj = safeJsonDecode(text) -- 1240
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1240
				goto __continue224 -- 1241
			end -- 1241
			local value = obj -- 1242
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1243
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1244
			local id = sanitizeUTF8(toStr(value.id)) -- 1245
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1246
			local message = sanitizeUTF8(toStr(value.message)) -- 1247
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1248
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1249
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1250
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1250
				goto __continue224 -- 1252
			end -- 1252
			items[#items + 1] = { -- 1254
				id = id, -- 1255
				sourceSessionId = sourceSessionId, -- 1256
				sourceTitle = sourceTitle, -- 1257
				sourceTaskId = sourceTaskId, -- 1258
				message = message, -- 1259
				prompt = prompt, -- 1260
				goal = goal, -- 1261
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1262
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1263
					__TS__ArrayFilter( -- 1264
						value.filesHint, -- 1264
						function(____, item) return type(item) == "string" end -- 1264
					), -- 1264
					function(____, item) return sanitizeUTF8(item) end -- 1264
				) or ({}), -- 1264
				success = value.success == true, -- 1266
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1267
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1268
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1269
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1270
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1271
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1272
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1273
				createdAt = createdAt -- 1276
			} -- 1276
		end -- 1276
		::__continue224:: -- 1276
	end -- 1276
	__TS__ArraySort( -- 1279
		items, -- 1279
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1279
	) -- 1279
	return items -- 1280
end -- 1280
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1283
	local path = Path( -- 1284
		getPendingHandoffDir(projectRoot, memoryScope), -- 1284
		id .. ".json" -- 1284
	) -- 1284
	if Content:exist(path) then -- 1284
		if Content:remove(path) then -- 1284
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1287
		end -- 1287
	end -- 1287
end -- 1287
function normalizePromptText(prompt) -- 1292
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1293
end -- 1293
function normalizePromptTextSafe(prompt) -- 1296
	if type(prompt) == "string" then -- 1296
		local normalized = normalizePromptText(prompt) -- 1298
		if normalized ~= "" then -- 1298
			return normalized -- 1299
		end -- 1299
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1300
		if sanitized ~= "" then -- 1300
			return truncateAgentUserPrompt(sanitized) -- 1302
		end -- 1302
		return "" -- 1304
	end -- 1304
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1306
	if text == "" then -- 1306
		return "" -- 1307
	end -- 1307
	return truncateAgentUserPrompt(text) -- 1308
end -- 1308
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1311
	local sections = {} -- 1312
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1313
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1314
	local normalizedFiles = __TS__ArrayFilter( -- 1315
		__TS__ArrayMap( -- 1315
			__TS__ArrayFilter( -- 1315
				filesHint or ({}), -- 1315
				function(____, item) return type(item) == "string" end -- 1316
			), -- 1316
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1317
		), -- 1317
		function(____, item) return item ~= "" end -- 1318
	) -- 1318
	if normalizedTitle ~= "" then -- 1318
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1320
	end -- 1320
	if normalizedExpected ~= "" then -- 1320
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1323
	end -- 1323
	if #normalizedFiles > 0 then -- 1323
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1326
	end -- 1326
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1328
end -- 1328
function normalizeSessionRuntimeState(session) -- 1331
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1331
		return session -- 1333
	end -- 1333
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1333
		return session -- 1336
	end -- 1336
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1338
	if #pendingToolRows > 0 then -- 1338
		local t = now() -- 1344
		do -- 1344
			local i = 0 -- 1345
			while i < #pendingToolRows do -- 1345
				local row = pendingToolRows[i + 1] -- 1346
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1347
				result.success = false -- 1348
				result.state = "failed" -- 1349
				result.interrupted = true -- 1350
				result.message = "tool call was interrupted because the program exited before it completed." -- 1351
				DB:exec( -- 1352
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1352
					{ -- 1354
						encodeJson(result), -- 1354
						t, -- 1354
						row[1] -- 1354
					} -- 1354
				) -- 1354
				i = i + 1 -- 1345
			end -- 1345
		end -- 1345
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1357
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1358
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1359
	end -- 1359
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1366
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1367
	return __TS__ObjectAssign( -- 1368
		{}, -- 1368
		session, -- 1369
		{ -- 1368
			status = "STOPPED", -- 1370
			currentTaskStatus = "STOPPED", -- 1371
			updatedAt = now() -- 1372
		} -- 1372
	) -- 1372
end -- 1372
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1376
	DB:exec( -- 1377
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1377
		{ -- 1381
			status, -- 1382
			currentTaskId or 0, -- 1383
			currentTaskStatus or status, -- 1384
			now(), -- 1385
			sessionId -- 1386
		} -- 1386
	) -- 1386
end -- 1386
function mergeAgentMetrics(current, next) -- 1391
	return __TS__ObjectAssign({}, current or ({}), next) -- 1392
end -- 1392
function updateSessionMetrics(sessionId, metrics) -- 1398
	local session = getSessionItem(sessionId) -- 1399
	if not session then -- 1399
		return nil -- 1400
	end -- 1400
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1401
	DB:exec( -- 1402
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1402
		{ -- 1406
			encodeJson(merged), -- 1407
			now(), -- 1408
			sessionId -- 1409
		} -- 1409
	) -- 1409
	return merged -- 1412
end -- 1412
function clearSessionTokenUsage(sessionId) -- 1415
	local session = getSessionItem(sessionId) -- 1416
	if not session then -- 1416
		return nil -- 1417
	end -- 1417
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1418
	__TS__Delete(metrics, "usage") -- 1419
	DB:exec( -- 1420
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1420
		{ -- 1424
			encodeJson(metrics), -- 1425
			now(), -- 1426
			sessionId -- 1427
		} -- 1427
	) -- 1427
	return metrics -- 1430
end -- 1430
function getInitialTokenUsage(session) -- 1433
	local ____opt_33 = session.metrics -- 1433
	local usage = ____opt_33 and ____opt_33.usage -- 1434
	if not usage or (usage.requestCount or 0) <= 0 then -- 1434
		return nil -- 1435
	end -- 1435
	return { -- 1436
		inputTokens = usage.inputTokens or 0, -- 1437
		outputTokens = usage.outputTokens or 0, -- 1438
		totalTokens = usage.totalTokens, -- 1439
		cachedInputTokens = usage.cachedInputTokens, -- 1440
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1441
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1442
		requestCount = usage.requestCount or 0, -- 1443
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1444
		model = usage.model or "", -- 1445
		phase = usage.phase or "", -- 1446
		step = usage.step or 0, -- 1447
		updatedAt = usage.updatedAt or now() -- 1448
	} -- 1448
end -- 1448
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1452
	if taskId == nil or taskId <= 0 then -- 1452
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1454
		return -- 1455
	end -- 1455
	local row = getSessionRow(sessionId) -- 1457
	if not row then -- 1457
		return -- 1458
	end -- 1458
	local session = rowToSession(row) -- 1459
	if session.currentTaskId ~= taskId then -- 1459
		Log( -- 1461
			"Info", -- 1461
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1461
		) -- 1461
		return -- 1462
	end -- 1462
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1464
end -- 1464
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1467
	local t = now() -- 1468
	DB:exec( -- 1469
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1469
		{ -- 1472
			sessionId, -- 1473
			taskId or 0, -- 1474
			role, -- 1475
			sanitizeUTF8(content), -- 1476
			displayContent and sanitizeUTF8(displayContent) or "", -- 1477
			t, -- 1478
			t -- 1479
		} -- 1479
	) -- 1479
	return getLastInsertRowId() -- 1482
end -- 1482
function updateMessage(messageId, content) -- 1485
	DB:exec( -- 1486
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1486
		{ -- 1488
			sanitizeUTF8(content), -- 1488
			now(), -- 1488
			messageId -- 1488
		} -- 1488
	) -- 1488
end -- 1488
function updateUserMessageForTask(messageId, content, taskId) -- 1492
	DB:exec( -- 1493
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1493
		{ -- 1497
			sanitizeUTF8(content), -- 1497
			taskId, -- 1497
			now(), -- 1497
			messageId -- 1497
		} -- 1497
	) -- 1497
end -- 1497
function removeContinuableTaskSummary(session) -- 1554
	local taskId = session.currentTaskId -- 1555
	if taskId == nil then -- 1555
		return -- 1556
	end -- 1556
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1557
end -- 1557
function upsertAssistantMessage(sessionId, taskId, content) -- 1569
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1570
	if row and type(row[1]) == "number" then -- 1570
		updateMessage(row[1], content) -- 1577
		return row[1] -- 1578
	end -- 1578
	return insertMessage(sessionId, "assistant", content, taskId) -- 1580
end -- 1580
function upsertStep(sessionId, taskId, step, tool, patch) -- 1583
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1593
	local reason = sanitizeUTF8(patch.reason or "") -- 1597
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1598
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1599
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1600
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1601
	local statusPatch = patch.status or "" -- 1602
	local status = patch.status or "PENDING" -- 1603
	if not row then -- 1603
		local t = now() -- 1605
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1606
			sessionId, -- 1610
			taskId, -- 1611
			step, -- 1612
			tool, -- 1613
			status, -- 1614
			reason, -- 1615
			reasoningContent, -- 1616
			paramsJson, -- 1617
			resultJson, -- 1618
			patch.checkpointId or 0, -- 1619
			patch.checkpointSeq or 0, -- 1620
			filesJson, -- 1621
			t, -- 1622
			t -- 1623
		}) -- 1623
		return -- 1626
	end -- 1626
	DB:exec( -- 1628
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1628
		{ -- 1640
			tool, -- 1641
			statusPatch, -- 1642
			status, -- 1643
			reason, -- 1644
			reason, -- 1645
			reasoningContent, -- 1646
			reasoningContent, -- 1647
			paramsJson, -- 1648
			paramsJson, -- 1649
			resultJson, -- 1650
			resultJson, -- 1651
			patch.checkpointId or 0, -- 1652
			patch.checkpointId or 0, -- 1653
			patch.checkpointSeq or 0, -- 1654
			patch.checkpointSeq or 0, -- 1655
			filesJson, -- 1656
			filesJson, -- 1657
			now(), -- 1658
			row[1] -- 1659
		} -- 1659
	) -- 1659
end -- 1659
function getNextStepNumber(sessionId, taskId) -- 1664
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1665
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1669
	return math.max(0, current) + 1 -- 1670
end -- 1670
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1711
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1719
	local t = now() -- 1720
	local sqls = { -- 1721
		{ -- 1722
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1722
			{{ -- 1725
				sessionId, -- 1726
				ownerTaskId, -- 1727
				step, -- 1728
				"sub_agent_handoff", -- 1729
				"DONE", -- 1730
				sanitizeUTF8(reason), -- 1731
				encodeJson(params), -- 1732
				encodeJson(result), -- 1733
				t, -- 1734
				t -- 1735
			}} -- 1735
		}, -- 1735
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1738
	} -- 1738
	if not DB:transaction(sqls) then -- 1738
		return nil -- 1744
	end -- 1744
	return getStepItem(sessionId, ownerTaskId, step) -- 1745
end -- 1745
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1748
	if taskId <= 0 then -- 1748
		return -- 1749
	end -- 1749
	if finalSteps ~= nil and finalSteps >= 0 then -- 1749
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1751
	end -- 1751
	if not finalStatus then -- 1751
		return -- 1757
	end -- 1757
	if finalSteps ~= nil and finalSteps >= 0 then -- 1757
		DB:exec( -- 1759
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1759
			{ -- 1763
				finalStatus, -- 1763
				now(), -- 1763
				sessionId, -- 1763
				taskId, -- 1763
				finalSteps -- 1763
			} -- 1763
		) -- 1763
		return -- 1765
	end -- 1765
	DB:exec( -- 1767
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1767
		{ -- 1771
			finalStatus, -- 1771
			now(), -- 1771
			sessionId, -- 1771
			taskId -- 1771
		} -- 1771
	) -- 1771
end -- 1771
function emitAgentSessionPatch(sessionId, patch) -- 1798
	if HttpServer.wsConnectionCount == 0 then -- 1798
		return -- 1800
	end -- 1800
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1802
	if not text then -- 1802
		return -- 1807
	end -- 1807
	emit("AppWS", "Send", text) -- 1808
end -- 1808
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1811
	emitAgentSessionPatch( -- 1812
		sessionId, -- 1812
		{ -- 1812
			sessionDeleted = true, -- 1813
			relatedSessions = listRelatedSessions(rootSessionId) -- 1814
		} -- 1814
	) -- 1814
	local rootSession = getSessionItem(rootSessionId) -- 1816
	if rootSession then -- 1816
		emitAgentSessionPatch( -- 1818
			rootSessionId, -- 1818
			{ -- 1818
				session = rootSession, -- 1819
				relatedSessions = listRelatedSessions(rootSessionId) -- 1820
			} -- 1820
		) -- 1820
	end -- 1820
end -- 1820
function flushPendingSubAgentHandoffs(rootSession) -- 1825
	if rootSession.kind ~= "main" then -- 1825
		return -- 1826
	end -- 1826
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1826
		return -- 1828
	end -- 1828
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1830
	if #items == 0 then -- 1830
		return -- 1831
	end -- 1831
	local handoffTaskId = 0 -- 1832
	local previousTaskId = rootSession.currentTaskId -- 1833
	local ____rootSession_currentTaskId_37 -- 1834
	if rootSession.currentTaskId then -- 1834
		____rootSession_currentTaskId_37 = getTaskPrompt(rootSession.currentTaskId) -- 1834
	else -- 1834
		____rootSession_currentTaskId_37 = nil -- 1834
	end -- 1834
	local currentTaskPrompt = ____rootSession_currentTaskId_37 -- 1834
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1834
		handoffTaskId = rootSession.currentTaskId -- 1842
	else -- 1842
		local taskRes = Tools.createTask( -- 1844
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1844
			"code" -- 1844
		) -- 1844
		if not taskRes.success then -- 1844
			Log( -- 1846
				"Warn", -- 1846
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1846
			) -- 1846
			return -- 1847
		end -- 1847
		handoffTaskId = taskRes.taskId -- 1849
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1850
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1851
		emitAgentSessionPatch( -- 1852
			rootSession.id, -- 1852
			{session = getSessionItem(rootSession.id)} -- 1852
		) -- 1852
	end -- 1852
	do -- 1852
		local i = 0 -- 1856
		while i < #items do -- 1856
			local item = items[i + 1] -- 1857
			local step = appendHandoffSystemStep( -- 1858
				rootSession.id, -- 1859
				handoffTaskId, -- 1860
				item.sourceTaskId, -- 1861
				item.message, -- 1862
				{ -- 1863
					sourceSessionId = item.sourceSessionId, -- 1864
					sourceTitle = item.sourceTitle, -- 1865
					sourceTaskId = item.sourceTaskId, -- 1866
					success = item.success == true, -- 1867
					summary = item.message, -- 1868
					resultFilePath = item.resultFilePath or "", -- 1869
					artifactDir = item.artifactDir or "", -- 1870
					finishedAt = item.finishedAt or "", -- 1871
					changeSet = item.changeSet, -- 1872
					handoffEvidence = item.handoffEvidence, -- 1873
					memoryEntry = item.memoryEntry, -- 1874
					completion = item.completion -- 1875
				}, -- 1875
				{ -- 1877
					sourceSessionId = item.sourceSessionId, -- 1878
					sourceTitle = item.sourceTitle, -- 1879
					sourceTaskId = item.sourceTaskId, -- 1880
					prompt = item.prompt, -- 1881
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1882
					expectedOutput = item.expectedOutput or "", -- 1883
					filesHint = item.filesHint or ({}), -- 1884
					resultFilePath = item.resultFilePath or "", -- 1885
					artifactDir = item.artifactDir or "", -- 1886
					changeSet = item.changeSet, -- 1887
					handoffEvidence = item.handoffEvidence, -- 1888
					memoryEntry = item.memoryEntry, -- 1889
					completion = item.completion -- 1890
				} -- 1890
			) -- 1890
			if step then -- 1890
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1894
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1895
			else -- 1895
				Log( -- 1897
					"Warn", -- 1897
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1897
				) -- 1897
			end -- 1897
			i = i + 1 -- 1856
		end -- 1856
	end -- 1856
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1856
		cleanupTaskHeavyData(previousTaskId) -- 1901
	end -- 1901
end -- 1901
function applyEvent(sessionId, event) -- 1913
	if not getSessionItem(sessionId) then -- 1913
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1913
			__TS__Delete(activeStopTokens, event.taskId) -- 1916
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1917
		end -- 1917
		return -- 1919
	end -- 1919
	repeat -- 1919
		local ____switch317 = event.type -- 1919
		local metrics, startedSession -- 1919
		local ____cond317 = ____switch317 == "task_started" -- 1919
		if ____cond317 then -- 1919
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1923
			local ____event_resumed_40 -- 1924
			if event.resumed then -- 1924
				local ____opt_38 = getSessionItem(sessionId) -- 1924
				____event_resumed_40 = ____opt_38 and ____opt_38.metrics -- 1925
			else -- 1925
				____event_resumed_40 = clearSessionTokenUsage(sessionId) -- 1926
			end -- 1926
			metrics = ____event_resumed_40 -- 1924
			startedSession = getSessionItem(sessionId) -- 1927
			emitAgentSessionPatch( -- 1928
				sessionId, -- 1928
				{ -- 1928
					session = startedSession, -- 1929
					metrics = metrics, -- 1930
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1931
				} -- 1931
			) -- 1931
			break -- 1935
		end -- 1935
		____cond317 = ____cond317 or ____switch317 == "decision_made" -- 1935
		if ____cond317 then -- 1935
			upsertStep( -- 1937
				sessionId, -- 1937
				event.taskId, -- 1937
				event.step, -- 1937
				event.tool, -- 1937
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1937
			) -- 1937
			emitAgentSessionPatch( -- 1945
				sessionId, -- 1945
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1945
			) -- 1945
			break -- 1948
		end -- 1948
		____cond317 = ____cond317 or ____switch317 == "tool_started" -- 1948
		if ____cond317 then -- 1948
			upsertStep( -- 1950
				sessionId, -- 1950
				event.taskId, -- 1950
				event.step, -- 1950
				event.tool, -- 1950
				{status = "RUNNING"} -- 1950
			) -- 1950
			emitAgentSessionPatch( -- 1953
				sessionId, -- 1953
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1953
			) -- 1953
			break -- 1956
		end -- 1956
		____cond317 = ____cond317 or ____switch317 == "tool_finished" -- 1956
		if ____cond317 then -- 1956
			do -- 1956
				local ____temp_43 = event.result.success ~= true -- 1958
				if ____temp_43 then -- 1958
					local ____opt_41 = activeStopTokens[event.taskId] -- 1958
					____temp_43 = (____opt_41 and ____opt_41.stopped) == true -- 1958
				end -- 1958
				local stopped = ____temp_43 -- 1958
				upsertStep( -- 1960
					sessionId, -- 1960
					event.taskId, -- 1960
					event.step, -- 1960
					event.tool, -- 1960
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1960
				) -- 1960
				emitAgentSessionPatch( -- 1968
					sessionId, -- 1968
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1968
				) -- 1968
				break -- 1971
			end -- 1971
		end -- 1971
		____cond317 = ____cond317 or ____switch317 == "tool_progress" -- 1971
		if ____cond317 then -- 1971
			do -- 1971
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1975
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1975
					break -- 1977
				end -- 1977
			end -- 1977
			upsertStep( -- 1980
				sessionId, -- 1980
				event.taskId, -- 1980
				event.step, -- 1980
				event.tool, -- 1980
				{status = "RUNNING", result = event.result} -- 1980
			) -- 1980
			emitAgentSessionPatch( -- 1984
				sessionId, -- 1984
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1984
			) -- 1984
			break -- 1987
		end -- 1987
		____cond317 = ____cond317 or ____switch317 == "checkpoint_created" -- 1987
		if ____cond317 then -- 1987
			upsertStep( -- 1989
				sessionId, -- 1989
				event.taskId, -- 1989
				event.step, -- 1989
				event.tool, -- 1989
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1989
			) -- 1989
			emitAgentSessionPatch( -- 1994
				sessionId, -- 1994
				{ -- 1994
					step = getStepItem(sessionId, event.taskId, event.step), -- 1995
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 1996
				} -- 1996
			) -- 1996
			break -- 1998
		end -- 1998
		____cond317 = ____cond317 or ____switch317 == "memory_compression_started" -- 1998
		if ____cond317 then -- 1998
			upsertStep( -- 2000
				sessionId, -- 2000
				event.taskId, -- 2000
				event.step, -- 2000
				event.tool, -- 2000
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2000
			) -- 2000
			emitAgentSessionPatch( -- 2005
				sessionId, -- 2005
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2005
			) -- 2005
			break -- 2008
		end -- 2008
		____cond317 = ____cond317 or ____switch317 == "memory_compression_finished" -- 2008
		if ____cond317 then -- 2008
			upsertStep( -- 2010
				sessionId, -- 2010
				event.taskId, -- 2010
				event.step, -- 2010
				event.tool, -- 2010
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2010
			) -- 2010
			emitAgentSessionPatch( -- 2015
				sessionId, -- 2015
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2015
			) -- 2015
			break -- 2018
		end -- 2018
		____cond317 = ____cond317 or ____switch317 == "metrics_updated" -- 2018
		if ____cond317 then -- 2018
			do -- 2018
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2020
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2021
				break -- 2024
			end -- 2024
		end -- 2024
		____cond317 = ____cond317 or ____switch317 == "assistant_message_updated" -- 2024
		if ____cond317 then -- 2024
			do -- 2024
				upsertStep( -- 2027
					sessionId, -- 2027
					event.taskId, -- 2027
					event.step, -- 2027
					"message", -- 2027
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2027
				) -- 2027
				emitAgentSessionPatch( -- 2032
					sessionId, -- 2032
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2032
				) -- 2032
				break -- 2035
			end -- 2035
		end -- 2035
		____cond317 = ____cond317 or ____switch317 == "assistant_message_finished" -- 2035
		if ____cond317 then -- 2035
			do -- 2035
				upsertStep( -- 2038
					sessionId, -- 2038
					event.taskId, -- 2038
					event.step, -- 2038
					"message", -- 2038
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2038
				) -- 2038
				emitAgentSessionPatch( -- 2044
					sessionId, -- 2044
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2044
				) -- 2044
				break -- 2047
			end -- 2047
		end -- 2047
		____cond317 = ____cond317 or ____switch317 == "task_waiting_for_user" -- 2047
		if ____cond317 then -- 2047
			do -- 2047
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2050
				__TS__Delete(activeStopTokens, event.taskId) -- 2051
				emitAgentSessionPatch( -- 2052
					sessionId, -- 2052
					{ -- 2052
						session = getSessionItem(sessionId), -- 2053
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2054
					} -- 2054
				) -- 2054
				break -- 2056
			end -- 2056
		end -- 2056
		____cond317 = ____cond317 or ____switch317 == "task_finished" -- 2056
		if ____cond317 then -- 2056
			do -- 2056
				local session = getSessionItem(sessionId) -- 2059
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2059
					__TS__Delete(activeStopTokens, event.taskId) -- 2061
					Log( -- 2062
						"Info", -- 2062
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2062
					) -- 2062
					break -- 2063
				end -- 2063
				local ____opt_44 = activeStopTokens[event.taskId or -1] -- 2063
				local stopped = (____opt_44 and ____opt_44.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2065
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2067
				local isSubSession = (session and session.kind) == "sub" -- 2070
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2071
				if isSubSession and event.taskId ~= nil then -- 2071
					finalizingSubSessionTaskIds[event.taskId] = true -- 2073
				end -- 2073
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2075
				if event.taskId ~= nil then -- 2075
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2077
					local ____finalizeTaskSteps_50 = finalizeTaskSteps -- 2078
					local ____array_49 = __TS__SparseArrayNew( -- 2078
						sessionId, -- 2079
						event.taskId, -- 2080
						type(event.steps) == "number" and math.max( -- 2081
							0, -- 2081
							math.floor(event.steps) -- 2081
						) or nil -- 2081
					) -- 2081
					local ____event_success_48 -- 2082
					if event.success then -- 2082
						____event_success_48 = nil -- 2082
					else -- 2082
						____event_success_48 = stopped and "STOPPED" or "FAILED" -- 2082
					end -- 2082
					__TS__SparseArrayPush(____array_49, ____event_success_48) -- 2082
					____finalizeTaskSteps_50(__TS__SparseArraySpread(____array_49)) -- 2078
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2084
					if not isSubSession then -- 2084
						__TS__Delete(activeStopTokens, event.taskId) -- 2086
					end -- 2086
					emitAgentSessionPatch( -- 2088
						sessionId, -- 2088
						{ -- 2088
							session = getSessionItem(sessionId), -- 2089
							message = getMessageItem(messageId), -- 2090
							removedStepIds = removedStepIds -- 2091
						} -- 2091
					) -- 2091
				end -- 2091
				if session and session.kind == "main" then -- 2091
					flushPendingSubAgentHandoffs(session) -- 2095
				end -- 2095
				break -- 2097
			end -- 2097
		end -- 2097
	until true -- 2097
end -- 2097
function ____exports.createSession(projectRoot, title) -- 2102
	if title == nil then -- 2102
		title = "" -- 2102
	end -- 2102
	local storage = requireAgentStorage() -- 2103
	if not storage.success then -- 2103
		return storage -- 2104
	end -- 2104
	if not isValidProjectRoot(projectRoot) then -- 2104
		return {success = false, message = "invalid projectRoot"} -- 2106
	end -- 2106
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2108
	if row then -- 2108
		return { -- 2117
			success = true, -- 2117
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2117
		} -- 2117
	end -- 2117
	local t = now() -- 2119
	DB:exec( -- 2120
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 2120
		{ -- 2123
			projectRoot, -- 2123
			title ~= "" and title or Path:getFilename(projectRoot), -- 2123
			t, -- 2123
			t -- 2123
		} -- 2123
	) -- 2123
	local sessionId = getLastInsertRowId() -- 2125
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2126
	local session = getSessionItem(sessionId) -- 2127
	if not session then -- 2127
		return {success = false, message = "failed to create session"} -- 2129
	end -- 2129
	return {success = true, session = session} -- 2131
end -- 2102
function ____exports.createSubSession(parentSessionId, title) -- 2134
	if title == nil then -- 2134
		title = "" -- 2134
	end -- 2134
	local storage = requireAgentStorage() -- 2135
	if not storage.success then -- 2135
		return storage -- 2136
	end -- 2136
	local parent = getSessionItem(parentSessionId) -- 2137
	if not parent then -- 2137
		return {success = false, message = "parent session not found"} -- 2139
	end -- 2139
	local rootId = getSessionRootId(parent) -- 2141
	local t = now() -- 2142
	DB:exec( -- 2143
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2143
		{ -- 2146
			parent.projectRoot, -- 2146
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2146
			rootId, -- 2146
			parent.id, -- 2146
			t, -- 2146
			t -- 2146
		} -- 2146
	) -- 2146
	local sessionId = getLastInsertRowId() -- 2148
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2149
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2150
	local session = getSessionItem(sessionId) -- 2151
	if not session then -- 2151
		return {success = false, message = "failed to create sub session"} -- 2153
	end -- 2153
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2155
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2156
	subStorage:writeMemory(parentStorage:readMemory()) -- 2157
	return {success = true, session = session} -- 2158
end -- 2134
function spawnSubAgentSession(request) -- 2161
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2161
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2174
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2175
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2176
		if normalizedPrompt == "" then -- 2176
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2178
		end -- 2178
		if normalizedPrompt == "" then -- 2178
			local ____Log_56 = Log -- 2185
			local ____temp_53 = #normalizedTitle -- 2185
			local ____temp_54 = #rawPrompt -- 2185
			local ____temp_55 = #toStr(request.expectedOutput) -- 2185
			local ____opt_51 = request.filesHint -- 2185
			____Log_56( -- 2185
				"Warn", -- 2185
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_53)) .. " raw_prompt_len=") .. tostring(____temp_54)) .. " expected_len=") .. tostring(____temp_55)) .. " files_hint_count=") .. tostring(____opt_51 and #____opt_51 or 0) -- 2185
			) -- 2185
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2185
		end -- 2185
		Log( -- 2188
			"Info", -- 2188
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2188
		) -- 2188
		local parentSessionId = request.parentSessionId -- 2189
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2189
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2191
			if not fallbackParent then -- 2191
				local createdMain = ____exports.createSession(request.projectRoot) -- 2193
				if createdMain.success then -- 2193
					fallbackParent = createdMain.session -- 2195
				end -- 2195
			end -- 2195
			if fallbackParent then -- 2195
				Log( -- 2199
					"Warn", -- 2199
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2199
				) -- 2199
				parentSessionId = fallbackParent.id -- 2200
			end -- 2200
		end -- 2200
		local parentSession = getSessionItem(parentSessionId) -- 2203
		if not parentSession then -- 2203
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2203
		end -- 2203
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2207
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2207
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2207
		end -- 2207
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2211
		if not created.success then -- 2211
			return ____awaiter_resolve(nil, created) -- 2211
		end -- 2211
		writeSpawnInfo( -- 2215
			created.session.projectRoot, -- 2215
			created.session.memoryScope, -- 2215
			{ -- 2215
				sessionId = created.session.id, -- 2216
				rootSessionId = created.session.rootSessionId, -- 2217
				parentSessionId = created.session.parentSessionId, -- 2218
				title = created.session.title, -- 2219
				prompt = normalizedPrompt, -- 2220
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2221
				expectedOutput = request.expectedOutput or "", -- 2222
				filesHint = request.filesHint or ({}), -- 2223
				status = "RUNNING", -- 2224
				success = false, -- 2225
				resultFilePath = "", -- 2226
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2227
				sourceTaskId = 0, -- 2228
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2229
				createdAtTs = created.session.createdAt, -- 2230
				finishedAt = "", -- 2231
				finishedAtTs = 0 -- 2232
			} -- 2232
		) -- 2232
		local sent = ____exports.sendPrompt( -- 2234
			created.session.id, -- 2234
			normalizedPrompt, -- 2234
			request.disabledAgentTools, -- 2234
			nil, -- 2234
			nil, -- 2234
			request.llmConfig -- 2234
		) -- 2234
		if not sent.success then -- 2234
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2234
		end -- 2234
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2234
	end) -- 2234
end -- 2234
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2339
	local rootSession = getRootSessionItem(session.id) -- 2340
	if not rootSession then -- 2340
		return -- 2341
	end -- 2341
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2342
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2343
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2344
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2345
	local queueResult = writePendingHandoff( -- 2346
		rootSession.projectRoot, -- 2346
		rootSession.memoryScope, -- 2346
		{ -- 2346
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2347
			sourceSessionId = session.id, -- 2348
			sourceTitle = session.title, -- 2349
			sourceTaskId = taskId, -- 2350
			message = summary, -- 2351
			prompt = result.prompt, -- 2352
			goal = result.goal, -- 2353
			expectedOutput = result.expectedOutput or "", -- 2354
			filesHint = result.filesHint or ({}), -- 2355
			success = result.success, -- 2356
			resultFilePath = result.resultFilePath, -- 2357
			artifactDir = result.artifactDir, -- 2358
			finishedAt = result.finishedAt, -- 2359
			changeSet = changeSet, -- 2360
			handoffEvidence = result.handoffEvidence, -- 2361
			memoryEntry = result.memoryEntry, -- 2362
			completion = result.completion, -- 2363
			createdAt = createdAt -- 2364
		} -- 2364
	) -- 2364
	if not queueResult then -- 2364
		Log( -- 2367
			"Warn", -- 2367
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2367
		) -- 2367
		return -- 2368
	end -- 2368
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2368
		addTaskReference(rootSession.currentTaskId, taskId) -- 2371
	end -- 2371
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2371
		flushPendingSubAgentHandoffs(rootSession) -- 2374
	end -- 2374
end -- 2374
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2378
	if forceHandoff == nil then -- 2378
		forceHandoff = false -- 2384
	end -- 2384
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2384
		local rootSessionId = getSessionRootId(session) -- 2386
		local rootSession = getRootSessionItem(session.id) -- 2387
		if not rootSession then -- 2387
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2387
		end -- 2387
		local spawnInfo = getSessionSpawnInfo(session) -- 2391
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2392
		local finishedAtTs = now() -- 2393
		local resultText = sanitizeUTF8(message) -- 2394
		local changeSet = getTaskChangeSetSummary(taskId) -- 2395
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2396
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2397
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2401
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2401
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2403
		end -- 2403
		local completed = success and completionReport.outcome == "completed" -- 2411
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2412
		local record = { -- 2415
			sessionId = session.id, -- 2416
			rootSessionId = rootSessionId, -- 2417
			parentSessionId = session.parentSessionId, -- 2418
			title = session.title, -- 2419
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2420
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2421
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2422
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2423
			status = recordStatus, -- 2424
			success = completed, -- 2425
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2426
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2427
			sourceTaskId = taskId, -- 2428
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2429
			finishedAt = finishedAt, -- 2430
			createdAtTs = session.createdAt, -- 2431
			finishedAtTs = finishedAtTs, -- 2432
			changeSet = changeSet, -- 2433
			handoffEvidence = handoffEvidence, -- 2434
			completion = completionReport -- 2435
		} -- 2435
		local ____record_success_69 -- 2437
		if record.success then -- 2437
			____record_success_69 = buildStructuredSubAgentMemoryEntry(record) -- 2437
		else -- 2437
			____record_success_69 = nil -- 2437
		end -- 2437
		record.memoryEntry = ____record_success_69 -- 2437
		if not writeSubAgentResultFile(session, record, resultText) then -- 2437
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2437
		end -- 2437
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2437
			sessionId = record.sessionId, -- 2442
			rootSessionId = record.rootSessionId, -- 2443
			parentSessionId = record.parentSessionId, -- 2444
			title = record.title, -- 2445
			prompt = record.prompt, -- 2446
			goal = record.goal, -- 2447
			expectedOutput = record.expectedOutput or "", -- 2448
			filesHint = record.filesHint or ({}), -- 2449
			status = record.status, -- 2450
			success = record.success, -- 2451
			resultFilePath = record.resultFilePath, -- 2452
			artifactDir = record.artifactDir, -- 2453
			sourceTaskId = record.sourceTaskId, -- 2454
			createdAt = record.createdAt, -- 2455
			finishedAt = record.finishedAt, -- 2456
			createdAtTs = record.createdAtTs, -- 2457
			finishedAtTs = record.finishedAtTs, -- 2458
			changeSet = record.changeSet, -- 2459
			handoffEvidence = record.handoffEvidence, -- 2460
			memoryEntry = record.memoryEntry, -- 2461
			memoryEntryError = record.memoryEntryError, -- 2462
			completion = record.completion -- 2463
		}) then -- 2463
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2463
		end -- 2463
		if success or forceHandoff then -- 2463
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2468
			deleteSessionRecords(session.id, true) -- 2469
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2470
		end -- 2470
		return ____awaiter_resolve(nil, {success = true}) -- 2470
	end) -- 2470
end -- 2470
function stopClearedSubSession(session, taskId) -- 2475
	local spawnInfo = getSessionSpawnInfo(session) -- 2476
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2477
	local rootSessionId = getSessionRootId(session) -- 2478
	Tools.setTaskStatus(taskId, "STOPPED") -- 2479
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2480
	if not writeSpawnInfo( -- 2480
		session.projectRoot, -- 2481
		session.memoryScope, -- 2481
		{ -- 2481
			sessionId = session.id, -- 2482
			rootSessionId = rootSessionId, -- 2483
			parentSessionId = session.parentSessionId, -- 2484
			title = session.title, -- 2485
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2486
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2487
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2488
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2489
			status = "STOPPED", -- 2490
			success = false, -- 2491
			cleared = true, -- 2492
			resultFilePath = "", -- 2493
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2494
			sourceTaskId = taskId, -- 2495
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2496
			finishedAt = finishedAt, -- 2497
			createdAtTs = session.createdAt, -- 2498
			finishedAtTs = now() -- 2499
		} -- 2499
	) then -- 2499
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2501
	end -- 2501
	deleteSessionRecords(session.id, true) -- 2503
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2504
	return {success = true} -- 2505
end -- 2505
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2508
	local session = getSessionItem(sessionId) -- 2509
	if not session then -- 2509
		return {success = false, message = "session not found"} -- 2511
	end -- 2511
	if getPendingQuestionnaire(sessionId) then -- 2511
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2513
	end -- 2513
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2513
		return {success = false, message = "session task is finalizing"} -- 2515
	end -- 2515
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2515
		return {success = false, message = "session task is still running"} -- 2518
	end -- 2518
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2520
	if normalizedPrompt == "" and session.kind == "sub" then -- 2520
		local spawnInfo = getSessionSpawnInfo(session) -- 2522
		if spawnInfo then -- 2522
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2524
			if normalizedPrompt == "" then -- 2524
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2526
			end -- 2526
		end -- 2526
	end -- 2526
	if normalizedPrompt == "" then -- 2526
		return {success = false, message = "prompt is empty"} -- 2535
	end -- 2535
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2537
	if session.workMode ~= nextWorkMode then -- 2537
		DB:exec( -- 2539
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2539
			{ -- 2539
				nextWorkMode, -- 2539
				now(), -- 2539
				session.id -- 2539
			} -- 2539
		) -- 2539
		session.workMode = nextWorkMode -- 2540
	end -- 2540
	return startPromptTask( -- 2542
		session, -- 2542
		normalizedPrompt, -- 2542
		nil, -- 2542
		normalizeDisabledAgentTools(disabledAgentTools), -- 2542
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2542
	) -- 2542
end -- 2508
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2595
	if disabledAgentTools == nil then -- 2595
		disabledAgentTools = {} -- 2599
	end -- 2599
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2602
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2603
	if not llmConfigRes.success then -- 2603
		return {success = false, message = llmConfigRes.message} -- 2607
	end -- 2607
	local llmConfig = llmConfigRes.config -- 2609
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2610
	if not llmConfigValidation.success then -- 2610
		return llmConfigValidation -- 2612
	end -- 2612
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2614
	if not taskRes.success then -- 2614
		return {success = false, message = taskRes.message} -- 2617
	end -- 2617
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2617
		removeContinuableTaskSummary(session) -- 2619
	end -- 2619
	local taskId = taskRes.taskId -- 2621
	local ____temp_90 -- 2622
	if (options and options.existingTaskId) == nil then -- 2622
		____temp_90 = session.currentTaskId -- 2622
	else -- 2622
		____temp_90 = nil -- 2622
	end -- 2622
	local previousTaskId = ____temp_90 -- 2622
	local useChineseResponse = getDefaultUseChineseResponse() -- 2623
	if existingUserMessageId ~= nil then -- 2623
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2625
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2625
		insertMessage( -- 2627
			session.id, -- 2627
			"user", -- 2627
			normalizedPrompt, -- 2627
			taskId, -- 2627
			options and options.displayContent -- 2627
		) -- 2627
	end -- 2627
	local stopToken = {stopped = false} -- 2629
	activeStopTokens[taskId] = stopToken -- 2630
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2631
	if previousTaskId and previousTaskId ~= taskId then -- 2631
		cleanupTaskHeavyData(previousTaskId) -- 2633
	end -- 2633
	local ____runCodingAgent_119 = runCodingAgent -- 2635
	local ____normalizedPrompt_112 = normalizedPrompt -- 2636
	local ____temp_113 = options and options.resumeConversation -- 2637
	local ____temp_114 = (options and options.existingTaskId) ~= nil -- 2638
	local ____temp_115 = options and options.initialStep -- 2639
	local ____temp_116 = options and options.initialAgentStepCount -- 2640
	local ____temp_107 -- 2641
	if (options and options.existingTaskId) ~= nil then -- 2641
		____temp_107 = getInitialTokenUsage(session) -- 2641
	else -- 2641
		____temp_107 = nil -- 2641
	end -- 2641
	____runCodingAgent_119( -- 2635
		{ -- 2635
			prompt = ____normalizedPrompt_112, -- 2636
			resumeConversation = ____temp_113, -- 2637
			resumeTask = ____temp_114, -- 2638
			initialStep = ____temp_115, -- 2639
			initialAgentStepCount = ____temp_116, -- 2640
			initialTokenUsage = ____temp_107, -- 2641
			workDir = session.projectRoot, -- 2642
			useChineseResponse = useChineseResponse, -- 2643
			taskId = taskId, -- 2644
			sessionId = session.id, -- 2645
			memoryScope = session.memoryScope, -- 2646
			role = session.kind, -- 2647
			maxSteps = options and options.maxSteps, -- 2648
			disabledAgentTools = disabledAgentTools, -- 2649
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2650
			llmConfig = llmConfig, -- 2651
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2652
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2655
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2658
			stopToken = stopToken, -- 2659
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2660
		}, -- 2660
		function(result) -- 2661
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2661
				local nextSession = getSessionItem(session.id) -- 2662
				if nextSession and nextSession.kind == "sub" then -- 2662
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2662
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2665
						if not stopped.success then -- 2665
							Log( -- 2667
								"Warn", -- 2667
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2667
							) -- 2667
							emitAgentSessionPatch( -- 2668
								session.id, -- 2668
								{session = getSessionItem(session.id)} -- 2668
							) -- 2668
						end -- 2668
						__TS__Delete(activeStopTokens, taskId) -- 2672
						return ____awaiter_resolve(nil) -- 2672
					end -- 2672
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2675
					emitAgentSessionPatch( -- 2676
						session.id, -- 2676
						{session = getSessionItem(session.id)} -- 2676
					) -- 2676
					local finalized = __TS__Await(finalizeSubSession( -- 2679
						nextSession, -- 2680
						taskId, -- 2681
						result.success, -- 2682
						result.message, -- 2683
						result.completion, -- 2684
						(options and options.forceSubAgentHandoff) == true -- 2685
					)) -- 2685
					if not finalized.success then -- 2685
						Log( -- 2688
							"Warn", -- 2688
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2688
						) -- 2688
					end -- 2688
					local finalizedSession = getSessionItem(session.id) -- 2690
					if finalizedSession then -- 2690
						local stopped = stopToken.stopped == true -- 2692
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2693
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2696
						emitAgentSessionPatch( -- 2697
							session.id, -- 2697
							{session = getSessionItem(session.id)} -- 2697
						) -- 2697
					end -- 2697
					__TS__Delete(activeStopTokens, taskId) -- 2701
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2702
				end -- 2702
				local fallbackSession = getSessionItem(session.id) -- 2704
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2704
					applyEvent(session.id, { -- 2710
						type = "task_finished", -- 2711
						sessionId = session.id, -- 2712
						taskId = result.taskId, -- 2713
						success = false, -- 2714
						message = result.message, -- 2715
						steps = result.steps -- 2716
					}) -- 2716
				end -- 2716
			end) -- 2716
		end -- 2661
	) -- 2661
	return {success = true, sessionId = session.id, taskId = taskId} -- 2720
end -- 2720
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2872
	local lines = {} -- 2873
	do -- 2873
		local i = 0 -- 2874
		while i < #questionnaire.schema.questions do -- 2874
			local question = questionnaire.schema.questions[i + 1] -- 2875
			local answer = __TS__ArrayFind( -- 2876
				answers, -- 2876
				function(____, item) return item.questionId == question.id end -- 2876
			) -- 2876
			local answerText = "已跳过" -- 2877
			if answer and answer.status == "answered" then -- 2877
				local parts = {} -- 2879
				do -- 2879
					local j = 0 -- 2880
					while j < #(answer.selectedOptionIds or ({})) do -- 2880
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2881
						local option = __TS__ArrayFind( -- 2882
							question.options or ({}), -- 2882
							function(____, item) return item.id == optionId end -- 2882
						) -- 2882
						if option then -- 2882
							parts[#parts + 1] = option.label -- 2883
						end -- 2883
						j = j + 1 -- 2880
					end -- 2880
				end -- 2880
				if answer.otherText then -- 2880
					parts[#parts + 1] = answer.otherText -- 2885
				end -- 2885
				if answer.text then -- 2885
					parts[#parts + 1] = answer.text -- 2886
				end -- 2886
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2887
			end -- 2887
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2889
			i = i + 1 -- 2874
		end -- 2874
	end -- 2874
	return table.concat(lines, "\n\n") -- 2891
end -- 2891
function ____exports.listRunningSubAgents(request) -- 3135
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3135
		local session = getSessionItem(request.sessionId) -- 3143
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3143
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3145
		end -- 3145
		if not session then -- 3145
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3145
		end -- 3145
		local rootSession = getRootSessionItem(session.id) -- 3150
		if not rootSession then -- 3150
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3150
		end -- 3150
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3154
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3155
		local limit = math.max( -- 3156
			1, -- 3156
			math.floor(tonumber(request.limit) or 5) -- 3156
		) -- 3156
		local offset = math.max( -- 3157
			0, -- 3157
			math.floor(tonumber(request.offset) or 0) -- 3157
		) -- 3157
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3158
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3159
		local runningSessions = {} -- 3166
		do -- 3166
			local i = 0 -- 3167
			while i < #rows do -- 3167
				do -- 3167
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3168
					if current.currentTaskStatus ~= "RUNNING" then -- 3168
						goto __continue515 -- 3170
					end -- 3170
					local spawnInfo = getSessionSpawnInfo(current) -- 3172
					runningSessions[#runningSessions + 1] = { -- 3173
						sessionId = current.id, -- 3174
						title = current.title, -- 3175
						parentSessionId = current.parentSessionId, -- 3176
						rootSessionId = current.rootSessionId, -- 3177
						status = "RUNNING", -- 3178
						currentTaskId = current.currentTaskId, -- 3179
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3180
						goal = spawnInfo and spawnInfo.goal, -- 3181
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3182
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3183
						createdAt = current.createdAt, -- 3184
						updatedAt = current.updatedAt -- 3185
					} -- 3185
				end -- 3185
				::__continue515:: -- 3185
				i = i + 1 -- 3167
			end -- 3167
		end -- 3167
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3188
		local completedSessions = __TS__ArrayMap( -- 3189
			completedRecords, -- 3189
			function(____, record) return { -- 3189
				sessionId = record.sessionId, -- 3190
				title = record.title, -- 3191
				parentSessionId = record.parentSessionId, -- 3192
				rootSessionId = record.rootSessionId, -- 3193
				status = record.status, -- 3194
				goal = record.goal, -- 3195
				expectedOutput = record.expectedOutput, -- 3196
				filesHint = record.filesHint, -- 3197
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3198
				success = record.success, -- 3199
				cleared = record.cleared, -- 3200
				resultFilePath = record.resultFilePath, -- 3201
				artifactDir = record.artifactDir, -- 3202
				finishedAt = record.finishedAt, -- 3203
				createdAt = record.createdAtTs, -- 3204
				updatedAt = record.finishedAtTs -- 3205
			} end -- 3205
		) -- 3205
		local merged = {} -- 3207
		if status == "running" then -- 3207
			merged = runningSessions -- 3209
		elseif status == "done" then -- 3209
			merged = __TS__ArrayFilter( -- 3211
				completedSessions, -- 3211
				function(____, item) return item.status == "DONE" end -- 3211
			) -- 3211
		elseif status == "failed" then -- 3211
			merged = __TS__ArrayFilter( -- 3213
				completedSessions, -- 3213
				function(____, item) return item.status == "FAILED" end -- 3213
			) -- 3213
		elseif status == "stopped" then -- 3213
			merged = __TS__ArrayFilter( -- 3215
				completedSessions, -- 3215
				function(____, item) return item.status == "STOPPED" end -- 3215
			) -- 3215
		elseif status == "all" then -- 3215
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3217
		else -- 3217
			local runningKeys = {} -- 3219
			do -- 3219
				local i = 0 -- 3220
				while i < #runningSessions do -- 3220
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3221
					i = i + 1 -- 3220
				end -- 3220
			end -- 3220
			local latestCompletedByKey = {} -- 3223
			do -- 3223
				local i = 0 -- 3224
				while i < #completedSessions do -- 3224
					do -- 3224
						local item = completedSessions[i + 1] -- 3225
						local key = getSubAgentDisplayKey(item) -- 3226
						if runningKeys[key] then -- 3226
							goto __continue530 -- 3228
						end -- 3228
						local current = latestCompletedByKey[key] -- 3230
						if not current or item.updatedAt > current.updatedAt then -- 3230
							latestCompletedByKey[key] = item -- 3232
						end -- 3232
					end -- 3232
					::__continue530:: -- 3232
					i = i + 1 -- 3224
				end -- 3224
			end -- 3224
			local latestCompleted = {} -- 3235
			for ____, item in pairs(latestCompletedByKey) do -- 3236
				latestCompleted[#latestCompleted + 1] = item -- 3237
			end -- 3237
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3239
		end -- 3239
		if query ~= "" then -- 3239
			merged = __TS__ArrayFilter( -- 3242
				merged, -- 3242
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3242
			) -- 3242
		end -- 3242
		__TS__ArraySort( -- 3248
			merged, -- 3248
			function(____, a, b) -- 3248
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3248
					return -1 -- 3249
				end -- 3249
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3249
					return 1 -- 3250
				end -- 3250
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3250
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3252
				end -- 3252
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3254
			end -- 3248
		) -- 3248
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3256
		return ____awaiter_resolve(nil, { -- 3256
			success = true, -- 3258
			rootSessionId = rootSession.id, -- 3259
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3260
			status = status, -- 3261
			limit = limit, -- 3262
			offset = offset, -- 3263
			hasMore = offset + limit < #merged, -- 3264
			sessions = paged -- 3265
		}) -- 3265
	end) -- 3265
end -- 3135
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 268
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 269
SPAWN_INFO_FILE = "SPAWN.json" -- 270
RESULT_FILE = "RESULT.md" -- 271
PENDING_HANDOFF_DIR = "pending-handoffs" -- 272
MAX_CONCURRENT_SUB_AGENTS = 4 -- 273
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 274
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 275
activeStopTokens = {} -- 325
finalizingSubSessionTaskIds = {} -- 326
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 327
now = function() return os.time() end -- 328
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 976
	if projectRoot == oldRoot then -- 976
		return newRoot -- 978
	end -- 978
	for ____, separator in ipairs({"/", "\\"}) do -- 980
		local prefix = oldRoot .. separator -- 981
		if __TS__StringStartsWith(projectRoot, prefix) then -- 981
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 983
		end -- 983
	end -- 983
	return nil -- 986
end -- 976
local function clearSessionAfterMessage(sessionId, message) -- 1501
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1502
	local removedStepIds = {} -- 1510
	do -- 1510
		local i = 0 -- 1511
		while i < #removedStepRows do -- 1511
			local row = removedStepRows[i + 1] -- 1512
			if type(row[1]) == "number" then -- 1512
				removedStepIds[#removedStepIds + 1] = row[1] -- 1514
			end -- 1514
			i = i + 1 -- 1511
		end -- 1511
	end -- 1511
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1517
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1525
	return removedStepIds -- 1530
end -- 1501
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1533
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1534
	local persisted = storage:readSessionState() -- 1535
	local userIndex = -1 -- 1536
	do -- 1536
		local i = #persisted.messages - 1 -- 1537
		while i >= 0 do -- 1537
			if persisted.messages[i + 1].role == "user" then -- 1537
				userIndex = i -- 1539
				break -- 1540
			end -- 1540
			i = i - 1 -- 1537
		end -- 1537
	end -- 1537
	if userIndex < 0 then -- 1537
		return -- 1543
	end -- 1543
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1544
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1545
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1546
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1551
end -- 1533
local function listCurrentTaskCheckpoints(sessionId) -- 1563
	local session = getSessionItem(sessionId) -- 1564
	local taskId = session and session.currentTaskId -- 1565
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1566
end -- 1563
local function getAgentStepCount(sessionId, taskId) -- 1673
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1674
		sessionId, -- 1679
		taskId, -- 1680
		"compress_memory", -- 1681
		"merge_memory", -- 1682
		"sub_agent_handoff", -- 1683
		"questionnaire_answer", -- 1684
		"message" -- 1685
	}) -- 1685
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1688
end -- 1673
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1691
	if status == nil then -- 1691
		status = "DONE" -- 1699
	end -- 1699
	local step = getNextStepNumber(sessionId, taskId) -- 1701
	upsertStep( -- 1702
		sessionId, -- 1702
		taskId, -- 1702
		step, -- 1702
		tool, -- 1702
		{status = status, reason = reason, params = params, result = result} -- 1702
	) -- 1702
	return getStepItem(sessionId, taskId, step) -- 1708
end -- 1691
local function sanitizeStoredSteps(sessionId) -- 1775
	DB:exec( -- 1776
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1776
		{ -- 1794
			now(), -- 1794
			sessionId -- 1794
		} -- 1794
	) -- 1794
end -- 1775
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2246
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2246
		return {success = false, message = "invalid projectRoot"} -- 2248
	end -- 2248
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2250
	for ____, row in ipairs(rows) do -- 2251
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2252
		if sessionId > 0 then -- 2252
			deleteSessionRecords(sessionId) -- 2254
		end -- 2254
	end -- 2254
	return {success = true, deleted = #rows} -- 2257
end -- 2246
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2260
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2260
		return {success = false, message = "invalid projectRoot"} -- 2262
	end -- 2262
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2264
	local renamed = 0 -- 2265
	for ____, row in ipairs(rows) do -- 2266
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2267
		local projectRoot = toStr(row[2]) -- 2268
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2269
		if sessionId > 0 and nextProjectRoot then -- 2269
			DB:exec( -- 2271
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2271
				{ -- 2273
					nextProjectRoot, -- 2273
					Path:getFilename(nextProjectRoot), -- 2273
					now(), -- 2273
					sessionId -- 2273
				} -- 2273
			) -- 2273
			renamed = renamed + 1 -- 2275
		end -- 2275
	end -- 2275
	return {success = true, renamed = renamed} -- 2278
end -- 2260
function ____exports.getSession(sessionId) -- 2281
	local session = getSessionItem(sessionId) -- 2282
	if not session then -- 2282
		return {success = false, message = "session not found"} -- 2284
	end -- 2284
	local restored = restorePendingQuestionnaireState(session) -- 2286
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2287
	local relatedSessions = listRelatedSessions(sessionId) -- 2288
	sanitizeStoredSteps(sessionId) -- 2289
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2290
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2297
	local ____relatedSessions_58 = relatedSessions -- 2308
	local ____temp_57 -- 2309
	if normalizedSession.kind == "sub" then -- 2309
		____temp_57 = getSessionSpawnInfo(normalizedSession) -- 2309
	else -- 2309
		____temp_57 = nil -- 2309
	end -- 2309
	return { -- 2305
		success = true, -- 2306
		session = normalizedSession, -- 2307
		relatedSessions = ____relatedSessions_58, -- 2308
		spawnInfo = ____temp_57, -- 2309
		messages = __TS__ArrayMap( -- 2310
			messages, -- 2310
			function(____, row) return rowToMessage(row) end -- 2310
		), -- 2310
		steps = __TS__ArrayMap( -- 2311
			steps, -- 2311
			function(____, row) return rowToStep(row) end -- 2311
		), -- 2311
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2312
		pendingQuestionnaire = restored.questionnaire, -- 2313
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2314
	} -- 2314
end -- 2281
function ____exports.setWorkMode(sessionId, workMode) -- 2319
	local session = getSessionItem(sessionId) -- 2320
	if not session then -- 2320
		return {success = false, message = "session not found"} -- 2321
	end -- 2321
	if session.kind ~= "main" then -- 2321
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2322
	end -- 2322
	if workMode ~= "code" and workMode ~= "plan" then -- 2322
		return {success = false, message = "invalid work mode"} -- 2323
	end -- 2323
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2324
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2324
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2326
	end -- 2326
	if getPendingQuestionnaire(sessionId) then -- 2326
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2329
	end -- 2329
	if normalizedSession.workMode ~= workMode then -- 2329
		DB:exec( -- 2332
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2332
			{ -- 2332
				workMode, -- 2332
				now(), -- 2332
				sessionId -- 2332
			} -- 2332
		) -- 2332
	end -- 2332
	local updated = getSessionItem(sessionId) -- 2334
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2335
	return { -- 2336
		success = true, -- 2336
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2336
	} -- 2336
end -- 2319
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2545
	local session = getSessionItem(sessionId) -- 2546
	if not session then -- 2546
		return {success = false, message = "session not found"} -- 2548
	end -- 2548
	if getPendingQuestionnaire(sessionId) then -- 2548
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2550
	end -- 2550
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2550
		return {success = false, message = "session task is finalizing"} -- 2552
	end -- 2552
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2552
		return {success = false, message = "session task is still stopping"} -- 2555
	end -- 2555
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2555
		return {success = false, message = "session task is not continuable"} -- 2558
	end -- 2558
	if session.currentTaskId == nil then -- 2558
		return {success = false, message = "session task not found"} -- 2561
	end -- 2561
	local taskId = session.currentTaskId -- 2563
	return startPromptTask( -- 2564
		session, -- 2565
		"", -- 2566
		nil, -- 2567
		normalizeDisabledAgentTools(disabledAgentTools), -- 2568
		{ -- 2569
			workMode = session.workMode, -- 2570
			persistUserMessage = false, -- 2571
			resumeConversation = true, -- 2572
			existingTaskId = taskId, -- 2573
			initialStep = math.max( -- 2574
				0, -- 2574
				getNextStepNumber(session.id, taskId) - 1 -- 2574
			), -- 2574
			initialAgentStepCount = getAgentStepCount(session.id, taskId), -- 2575
			llmConfigId = llmConfigId -- 2576
		} -- 2576
	) -- 2576
end -- 2545
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2723
	local session = getSessionItem(sessionId) -- 2724
	if not session then -- 2724
		return {success = false, message = "session not found"} -- 2726
	end -- 2726
	if session.kind ~= "sub" then -- 2726
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2729
	end -- 2729
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2729
		return {success = false, message = "session task is finalizing"} -- 2732
	end -- 2732
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2734
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2734
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2739
	end -- 2739
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2739
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2742
	end -- 2742
	local disabledAgentTools = __TS__ArrayFilter( -- 2744
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2744
		function(____, tool) return tool ~= "finish" end -- 2745
	) -- 2745
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2746
	return startPromptTask( -- 2749
		session, -- 2749
		prompt, -- 2749
		nil, -- 2749
		disabledAgentTools, -- 2749
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2749
	) -- 2749
end -- 2723
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2756
	local session = getSessionItem(sessionId) -- 2757
	if not session then -- 2757
		return {success = false, message = "session not found"} -- 2759
	end -- 2759
	if getPendingQuestionnaire(sessionId) then -- 2759
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2761
	end -- 2761
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2761
		return {success = false, message = "session task is finalizing"} -- 2763
	end -- 2763
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2763
		return {success = false, message = "session task is still running"} -- 2766
	end -- 2766
	local message = getMessageItem(messageId) -- 2768
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2768
		return {success = false, message = "message not found"} -- 2770
	end -- 2770
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2772
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2778
	if latestUserMessageId ~= messageId then -- 2778
		return {success = false, message = "only the latest user prompt can be edited"} -- 2780
	end -- 2780
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2782
	if normalizedPrompt == "" then -- 2782
		return {success = false, message = "prompt is empty"} -- 2784
	end -- 2784
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2786
	if session.workMode ~= nextWorkMode then -- 2786
		DB:exec( -- 2788
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2788
			{ -- 2788
				nextWorkMode, -- 2788
				now(), -- 2788
				session.id -- 2788
			} -- 2788
		) -- 2788
		session.workMode = nextWorkMode -- 2789
	end -- 2789
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2791
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2792
	local result = startPromptTask( -- 2793
		session, -- 2793
		normalizedPrompt, -- 2793
		messageId, -- 2793
		normalizeDisabledAgentTools(disabledAgentTools), -- 2793
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2793
	) -- 2793
	if result.success and #removedStepIds > 0 then -- 2793
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2795
	end -- 2795
	return result -- 2797
end -- 2756
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2802
	if status == "dismissed" then -- 2802
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2808
	end -- 2808
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2810
end -- 2802
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2813
	if status == "dismissed" then -- 2813
		return { -- 2819
			success = true, -- 2820
			status = "dismissed", -- 2821
			source = "user", -- 2822
			questionnaireId = questionnaire.id, -- 2823
			title = questionnaire.schema.title, -- 2824
			answers = {}, -- 2825
			responses = {}, -- 2826
			displayText = "用户关闭了调查问卷，未作答。", -- 2827
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2828
		} -- 2828
	end -- 2828
	local responses = {} -- 2831
	do -- 2831
		local i = 0 -- 2832
		while i < #questionnaire.schema.questions do -- 2832
			do -- 2832
				local question = questionnaire.schema.questions[i + 1] -- 2833
				local answer = __TS__ArrayFind( -- 2834
					answers, -- 2834
					function(____, item) return item.questionId == question.id end -- 2834
				) -- 2834
				if not answer or answer.status == "skipped" then -- 2834
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2836
					goto __continue441 -- 2841
				end -- 2841
				local selectedOptionLabels = {} -- 2843
				do -- 2843
					local j = 0 -- 2844
					while j < #(answer.selectedOptionIds or ({})) do -- 2844
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2845
						local option = __TS__ArrayFind( -- 2846
							question.options or ({}), -- 2846
							function(____, item) return item.id == optionId end -- 2846
						) -- 2846
						if option then -- 2846
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2847
						end -- 2847
						j = j + 1 -- 2844
					end -- 2844
				end -- 2844
				responses[#responses + 1] = { -- 2849
					questionId = question.id, -- 2850
					prompt = question.prompt, -- 2851
					status = "answered", -- 2852
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2853
					selectedOptionLabels = selectedOptionLabels, -- 2854
					otherText = answer.otherText, -- 2855
					text = answer.text -- 2856
				} -- 2856
			end -- 2856
			::__continue441:: -- 2856
			i = i + 1 -- 2832
		end -- 2832
	end -- 2832
	return { -- 2859
		success = true, -- 2860
		status = "answered", -- 2861
		source = "user", -- 2862
		questionnaireId = questionnaire.id, -- 2863
		title = questionnaire.schema.title, -- 2864
		answers = answers, -- 2865
		responses = responses, -- 2866
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2867
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2868
	} -- 2868
end -- 2813
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2894
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2900
	local persisted = storage:readSessionState() -- 2901
	local messages = __TS__ArraySlice(persisted.messages) -- 2902
	local toolResultIndex = -1 -- 2903
	local existingResult -- 2904
	do -- 2904
		local i = #messages - 1 -- 2905
		while i >= 0 do -- 2905
			do -- 2905
				local message = messages[i + 1] -- 2906
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2906
					goto __continue461 -- 2907
				end -- 2907
				local decoded = safeJsonDecode(message.content) -- 2908
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2908
					goto __continue461 -- 2909
				end -- 2909
				local row = decoded -- 2910
				if row.questionnaireId ~= questionnaire.id then -- 2910
					goto __continue461 -- 2911
				end -- 2911
				toolResultIndex = i -- 2912
				existingResult = row -- 2913
				break -- 2914
			end -- 2914
			::__continue461:: -- 2914
			i = i - 1 -- 2905
		end -- 2905
	end -- 2905
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2916
	local guidance = {} -- 2917
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2917
		guidance[#guidance + 1] = existingResult.guidance -- 2919
	end -- 2919
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2919
		guidance[#guidance + 1] = result.guidance -- 2922
	end -- 2922
	result.guidance = table.concat(guidance, "\n") -- 2924
	if toolResultIndex < 0 then -- 2924
		messages[#messages + 1] = { -- 2926
			role = "user", -- 2927
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 2928
		} -- 2928
		toolResultIndex = #messages - 1 -- 2930
	else -- 2930
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2932
			{}, -- 2932
			messages[toolResultIndex + 1], -- 2933
			{content = encodeJson(result)} -- 2932
		) -- 2932
	end -- 2932
	local pairStartIndex = toolResultIndex -- 2938
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2939
	if toolCallId and toolCallId ~= "" then -- 2939
		do -- 2939
			local i = toolResultIndex - 1 -- 2941
			while i >= 0 do -- 2941
				do -- 2941
					local message = messages[i + 1] -- 2942
					if message.role ~= "assistant" or not message.tool_calls then -- 2942
						goto __continue471 -- 2943
					end -- 2943
					if __TS__ArraySome( -- 2943
						message.tool_calls, -- 2944
						function(____, call) return call.id == toolCallId end -- 2944
					) then -- 2944
						pairStartIndex = i -- 2945
						break -- 2946
					end -- 2946
				end -- 2946
				::__continue471:: -- 2946
				i = i - 1 -- 2941
			end -- 2941
		end -- 2941
	end -- 2941
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2950
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2953
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2957
	upsertStep( -- 2959
		session.id, -- 2959
		questionnaire.taskId, -- 2959
		questionnaire.step, -- 2959
		"ask_user", -- 2959
		{status = "DONE", result = result} -- 2959
	) -- 2959
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 2963
	upsertStep( -- 2964
		session.id, -- 2964
		questionnaire.taskId, -- 2964
		answerStep, -- 2964
		"questionnaire_answer", -- 2964
		{status = "DONE", result = result} -- 2964
	) -- 2964
	return {success = true, answerStep = answerStep, result = result} -- 2968
end -- 2894
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 2971
	local session = getSessionItem(sessionId) -- 2972
	if not session then -- 2972
		return {success = false, message = "session not found"} -- 2973
	end -- 2973
	if session.kind ~= "main" then -- 2973
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2974
	end -- 2974
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2975
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2975
		return {success = false, message = "pending questionnaire not found or already handled"} -- 2977
	end -- 2977
	local llmConfigRes = getLLMConfig(llmConfigId) -- 2979
	if not llmConfigRes.success then -- 2979
		return {success = false, message = llmConfigRes.message} -- 2980
	end -- 2980
	if not removePendingQuestionnaire(session) then -- 2980
		return {success = false, message = "failed to consume questionnaire file"} -- 2981
	end -- 2981
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 2982
	if not replaced.success then -- 2982
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 2984
		return replaced -- 2985
	end -- 2985
	local t = now() -- 2987
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 2988
	session.workMode = "plan" -- 2989
	local result = startPromptTask( -- 2990
		session, -- 2990
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 2990
		nil, -- 2990
		{}, -- 2990
		{ -- 2990
			workMode = "plan", -- 2991
			persistUserMessage = false, -- 2992
			resumeConversation = true, -- 2993
			existingTaskId = questionnaire.taskId, -- 2994
			initialStep = replaced.answerStep, -- 2995
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 2996
			llmConfig = llmConfigRes.config -- 2997
		} -- 2997
	) -- 2997
	if not result.success then -- 2997
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3000
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3001
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3002
		emitAgentSessionPatch( -- 3003
			session.id, -- 3003
			{ -- 3003
				session = getSessionItem(session.id), -- 3004
				pendingQuestionnaire = questionnaire -- 3005
			} -- 3005
		) -- 3005
		return result -- 3007
	end -- 3007
	emitAgentSessionPatch( -- 3009
		sessionId, -- 3009
		{ -- 3009
			session = getSessionItem(sessionId), -- 3010
			pendingQuestionnaire = false -- 3011
		} -- 3011
	) -- 3011
	return result -- 3013
end -- 2971
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 3016
	local session = getSessionItem(sessionId) -- 3017
	if not session then -- 3017
		return {success = false, message = "session not found"} -- 3018
	end -- 3018
	if session.kind ~= "main" then -- 3018
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3019
	end -- 3019
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3020
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3020
		return {success = false, message = "pending questionnaire not found"} -- 3021
	end -- 3021
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3022
	if not validated.success then -- 3022
		return validated -- 3023
	end -- 3023
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3024
	if not llmConfigRes.success then -- 3024
		return {success = false, message = llmConfigRes.message} -- 3025
	end -- 3025
	local t = now() -- 3026
	if not removePendingQuestionnaire(session) then -- 3026
		return {success = false, message = "failed to consume questionnaire file"} -- 3027
	end -- 3027
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3028
	if not replaced.success then -- 3028
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3030
		return replaced -- 3031
	end -- 3031
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3033
	session.workMode = "plan" -- 3034
	local result = startPromptTask( -- 3035
		session, -- 3035
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3035
		nil, -- 3035
		{}, -- 3035
		{ -- 3035
			workMode = "plan", -- 3036
			persistUserMessage = false, -- 3037
			resumeConversation = true, -- 3038
			existingTaskId = questionnaire.taskId, -- 3039
			initialStep = replaced.answerStep, -- 3040
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3041
			llmConfig = llmConfigRes.config -- 3042
		} -- 3042
	) -- 3042
	if not result.success then -- 3042
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3045
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3046
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3047
		emitAgentSessionPatch( -- 3048
			session.id, -- 3048
			{ -- 3048
				session = getSessionItem(session.id), -- 3049
				pendingQuestionnaire = questionnaire -- 3050
			} -- 3050
		) -- 3050
		return result -- 3052
	end -- 3052
	emitAgentSessionPatch( -- 3054
		sessionId, -- 3054
		{ -- 3054
			session = getSessionItem(sessionId), -- 3055
			pendingQuestionnaire = false -- 3056
		} -- 3056
	) -- 3056
	return result -- 3058
end -- 3016
function ____exports.stopSessionTask(sessionId) -- 3061
	local session = getSessionItem(sessionId) -- 3062
	if not session or session.currentTaskId == nil then -- 3062
		return {success = false, message = "session task not found"} -- 3064
	end -- 3064
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3064
		return {success = false, message = "session task is finalizing"} -- 3067
	end -- 3067
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3069
	local stopToken = activeStopTokens[session.currentTaskId] -- 3070
	if not stopToken then -- 3070
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3070
			return {success = true, recovered = true} -- 3073
		end -- 3073
		return {success = false, message = "task is not running"} -- 3075
	end -- 3075
	if stopToken.stopped then -- 3075
		return {success = true, stopping = true} -- 3078
	end -- 3078
	stopToken.stopped = true -- 3080
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3081
	return {success = true, stopping = true} -- 3085
end -- 3061
function ____exports.getCurrentTaskId(sessionId) -- 3088
	local ____opt_122 = getSessionItem(sessionId) -- 3088
	return ____opt_122 and ____opt_122.currentTaskId -- 3089
end -- 3088
function ____exports.validateTaskAccess(sessionId, taskId) -- 3092
	local session = getSessionItem(sessionId) -- 3093
	if not session then -- 3093
		return {success = false, message = "session not found"} -- 3094
	end -- 3094
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3094
		getSessionOperableTaskIds(sessionId), -- 3095
		taskId -- 3095
	) < 0 then -- 3095
		return {success = false, message = "task is not operable for this session"} -- 3096
	end -- 3096
	return {success = true, session = session} -- 3098
end -- 3092
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3101
	if checkpointId <= 0 then -- 3101
		return {success = false, message = "invalid checkpointId"} -- 3103
	end -- 3103
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3105
	if not checkpoint then -- 3105
		return {success = false, message = "checkpoint not found"} -- 3107
	end -- 3107
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3109
	if not taskAccess.success then -- 3109
		return taskAccess -- 3110
	end -- 3110
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3111
end -- 3101
function ____exports.listRunningSessions() -- 3114
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3115
	local sessions = {} -- 3122
	do -- 3122
		local i = 0 -- 3123
		while i < #rows do -- 3123
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3124
			if session.currentTaskStatus == "RUNNING" then -- 3124
				sessions[#sessions + 1] = session -- 3126
			end -- 3126
			i = i + 1 -- 3123
		end -- 3123
	end -- 3123
	return {success = true, sessions = sessions} -- 3129
end -- 3114
return ____exports -- 3114