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
function getDefaultUseChineseResponse() -- 332
	local zh = string.match(App.locale, "^zh") -- 333
	return zh ~= nil -- 334
end -- 334
function encodeJson(value) -- 337
	local text = safeJsonEncode(value) -- 338
	return text or "" -- 339
end -- 339
function decodeJsonObject(text) -- 342
	if not text or text == "" then -- 342
		return nil -- 343
	end -- 343
	local value = safeJsonDecode(text) -- 344
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 344
		return value -- 346
	end -- 346
	return nil -- 348
end -- 348
function decodeJsonFiles(text) -- 351
	if not text or text == "" then -- 351
		return nil -- 352
	end -- 352
	local value = safeJsonDecode(text) -- 353
	if not value or not __TS__ArrayIsArray(value) then -- 353
		return nil -- 354
	end -- 354
	local files = {} -- 355
	do -- 355
		local i = 0 -- 356
		while i < #value do -- 356
			do -- 356
				local item = value[i + 1] -- 357
				if type(item) ~= "table" then -- 357
					goto __continue12 -- 358
				end -- 358
				files[#files + 1] = { -- 359
					path = sanitizeUTF8(toStr(item.path)), -- 360
					op = sanitizeUTF8(toStr(item.op)) -- 361
				} -- 361
			end -- 361
			::__continue12:: -- 361
			i = i + 1 -- 356
		end -- 356
	end -- 356
	return files -- 364
end -- 364
function decodeChangeSetSummary(value) -- 367
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 367
		return nil -- 368
	end -- 368
	local row = value -- 369
	if row.success ~= true then -- 369
		return nil -- 370
	end -- 370
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 371
	if taskId <= 0 then -- 371
		return nil -- 372
	end -- 372
	local files = {} -- 373
	if __TS__ArrayIsArray(row.files) then -- 373
		do -- 373
			local i = 0 -- 375
			while i < #row.files do -- 375
				do -- 375
					local file = row.files[i + 1] -- 376
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 376
						goto __continue20 -- 377
					end -- 377
					local fileRow = file -- 378
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 379
					if path == "" then -- 379
						goto __continue20 -- 380
					end -- 380
					local checkpointIds = {} -- 381
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 381
						do -- 381
							local j = 0 -- 383
							while j < #fileRow.checkpointIds do -- 383
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 384
								if checkpointId > 0 then -- 384
									checkpointIds[#checkpointIds + 1] = checkpointId -- 385
								end -- 385
								j = j + 1 -- 383
							end -- 383
						end -- 383
					end -- 383
					local op = toStr(fileRow.op) -- 388
					files[#files + 1] = { -- 389
						path = path, -- 390
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 391
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 392
						checkpointIds = checkpointIds -- 393
					} -- 393
				end -- 393
				::__continue20:: -- 393
				i = i + 1 -- 375
			end -- 375
		end -- 375
	end -- 375
	return { -- 397
		success = true, -- 398
		taskId = taskId, -- 399
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 400
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 401
		files = files, -- 402
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 403
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 404
	} -- 404
end -- 404
function decodeHandoffEvidence(value) -- 408
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 408
		return nil -- 409
	end -- 409
	local row = value -- 410
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 411
		__TS__ArrayFilter( -- 412
			row.modifiedFiles, -- 412
			function(____, item) return type(item) == "string" end -- 412
		), -- 412
		function(____, item) return sanitizeUTF8(item) end -- 412
	) or ({}) -- 412
	local lastBuild = nil -- 414
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 414
		local build = row.lastBuild -- 416
		lastBuild = { -- 417
			result = build.result == "passed" and "passed" or "failed", -- 418
			path = sanitizeUTF8(toStr(build.path)), -- 419
			evidence = takeUtf8Head( -- 420
				sanitizeUTF8(toStr(build.evidence)), -- 420
				600 -- 420
			) -- 420
		} -- 420
	end -- 420
	local commands = {} -- 423
	if __TS__ArrayIsArray(row.commands) then -- 423
		do -- 423
			local i = 0 -- 425
			while i < #row.commands and #commands < 8 do -- 425
				do -- 425
					local raw = row.commands[i + 1] -- 426
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 426
						goto __continue34 -- 427
					end -- 427
					local item = raw -- 428
					commands[#commands + 1] = { -- 429
						mode = sanitizeUTF8(toStr(item.mode)), -- 430
						command = takeUtf8Head( -- 431
							sanitizeUTF8(toStr(item.command)), -- 431
							600 -- 431
						), -- 431
						result = item.result == "passed" and "passed" or "failed", -- 432
						evidence = takeUtf8Head( -- 433
							sanitizeUTF8(toStr(item.evidence)), -- 433
							600 -- 433
						) -- 433
					} -- 433
				end -- 433
				::__continue34:: -- 433
				i = i + 1 -- 425
			end -- 425
		end -- 425
	end -- 425
	local authoritativeSources = {} -- 437
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 437
		do -- 437
			local i = 0 -- 439
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 439
				do -- 439
					local raw = row.authoritativeSources[i + 1] -- 440
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 440
						goto __continue38 -- 441
					end -- 441
					local item = raw -- 442
					authoritativeSources[#authoritativeSources + 1] = { -- 443
						tool = "search_dora_doc", -- 444
						query = takeUtf8Head( -- 445
							sanitizeUTF8(toStr(item.query)), -- 445
							300 -- 445
						), -- 445
						source = sanitizeUTF8(toStr(item.source)), -- 446
						result = item.result == "passed" and "passed" or "failed" -- 447
					} -- 447
				end -- 447
				::__continue38:: -- 447
				i = i + 1 -- 439
			end -- 439
		end -- 439
	end -- 439
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 451
end -- 451
function takeUtf8Head(text, maxChars) -- 454
	if maxChars <= 0 or text == "" then -- 454
		return "" -- 455
	end -- 455
	local nextPos = utf8.offset(text, maxChars + 1) -- 456
	if nextPos == nil then -- 456
		return text -- 457
	end -- 457
	return string.sub(text, 1, nextPos - 1) -- 458
end -- 458
function normalizeMemoryEntryEvidence(value) -- 461
	local evidence = {} -- 462
	if not __TS__ArrayIsArray(value) then -- 462
		return evidence -- 463
	end -- 463
	do -- 463
		local i = 0 -- 464
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 464
			do -- 464
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 465
				if item == "" then -- 465
					goto __continue46 -- 466
				end -- 466
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 466
					evidence[#evidence + 1] = item -- 468
				end -- 468
			end -- 468
			::__continue46:: -- 468
			i = i + 1 -- 464
		end -- 464
	end -- 464
	return evidence -- 471
end -- 471
function decodeSubAgentMemoryEntry(value) -- 474
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 474
		return nil -- 475
	end -- 475
	local row = value -- 476
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 477
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 478
	local content = takeUtf8Head( -- 479
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 479
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 479
	) -- 479
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 479
		return nil -- 480
	end -- 480
	return { -- 481
		sourceSessionId = sourceSessionId, -- 482
		sourceTaskId = sourceTaskId, -- 483
		content = content, -- 484
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 485
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 486
	} -- 486
end -- 486
function getTaskChangeSetSummary(taskId) -- 490
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 491
	return summary.success and summary or nil -- 492
end -- 492
function summarizeHandoffResult(result) -- 495
	local candidates = {result.output, result.message, result.state, result.phase} -- 496
	do -- 496
		local i = 0 -- 497
		while i < #candidates do -- 497
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 498
			if text ~= "" then -- 498
				return takeUtf8Head(text, 600) -- 499
			end -- 499
			i = i + 1 -- 497
		end -- 497
	end -- 497
	local messages = result.messages -- 501
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 501
		local parts = {} -- 503
		do -- 503
			local i = 0 -- 504
			while i < #messages and #parts < 4 do -- 504
				do -- 504
					local row = messages[i + 1] -- 505
					if not row or type(row) ~= "table" then -- 505
						goto __continue59 -- 506
					end -- 506
					local item = row -- 507
					local ____sanitizeUTF8_3 = sanitizeUTF8 -- 508
					local ____toStr_2 = toStr -- 508
					local ____item_message_0 = item.message -- 508
					if ____item_message_0 == nil then -- 508
						____item_message_0 = item.error -- 508
					end -- 508
					local ____item_message_0_1 = ____item_message_0 -- 508
					if ____item_message_0_1 == nil then -- 508
						____item_message_0_1 = item.file -- 508
					end -- 508
					local text = __TS__StringTrim(____sanitizeUTF8_3(____toStr_2(____item_message_0_1))) -- 508
					if text ~= "" then -- 508
						parts[#parts + 1] = text -- 509
					end -- 509
				end -- 509
				::__continue59:: -- 509
				i = i + 1 -- 504
			end -- 504
		end -- 504
		if #parts > 0 then -- 504
			return takeUtf8Head( -- 511
				table.concat(parts, "; "), -- 511
				600 -- 511
			) -- 511
		end -- 511
	end -- 511
	return result.success == true and "tool result success=true" or "tool result success=false" -- 513
end -- 513
function getTaskHandoffEvidence(taskId, changeSet) -- 516
	local ____opt_4 = changeSet -- 516
	local evidence = { -- 517
		modifiedFiles = ____opt_4 and __TS__ArrayMap( -- 518
			changeSet and changeSet.files, -- 518
			function(____, item) return item.path end -- 518
		) or ({}), -- 518
		commands = {}, -- 519
		authoritativeSources = {} -- 520
	} -- 520
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 522
	do -- 522
		local i = 0 -- 527
		while i < #rows do -- 527
			local tool = toStr(rows[i + 1][1]) -- 528
			local status = toStr(rows[i + 1][2]) -- 529
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 530
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 531
			local passed = status == "DONE" and result.success == true -- 532
			if tool == "build" then -- 532
				evidence.lastBuild = { -- 534
					result = passed and "passed" or "failed", -- 535
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 536
					evidence = summarizeHandoffResult(result) -- 537
				} -- 537
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 537
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 540
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 541
				local ____evidence_commands_8 = evidence.commands -- 541
				____evidence_commands_8[#____evidence_commands_8 + 1] = { -- 542
					mode = mode, -- 543
					command = takeUtf8Head( -- 544
						__TS__StringTrim(sanitizeUTF8(command)), -- 544
						600 -- 544
					), -- 544
					result = passed and "passed" or "failed", -- 545
					evidence = summarizeHandoffResult(result) -- 546
				} -- 546
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 546
				local ____evidence_authoritativeSources_9 = evidence.authoritativeSources -- 546
				____evidence_authoritativeSources_9[#____evidence_authoritativeSources_9 + 1] = { -- 549
					tool = "search_dora_doc", -- 550
					query = takeUtf8Head( -- 551
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 551
						300 -- 551
					), -- 551
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 552
					result = passed and "passed" or "failed" -- 553
				} -- 553
			end -- 553
			i = i + 1 -- 527
		end -- 527
	end -- 527
	return evidence -- 557
end -- 557
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 560
	local lastBuild = evidence.lastBuild -- 564
	if not lastBuild or lastBuild.result ~= "failed" then -- 564
		return completion -- 565
	end -- 565
	local validation = __TS__ArraySlice(completion.validation) -- 566
	local foundBuild = false -- 567
	do -- 567
		local i = 0 -- 568
		while i < #validation do -- 568
			do -- 568
				if validation[i + 1].kind ~= "build" then -- 568
					goto __continue73 -- 569
				end -- 569
				foundBuild = true -- 570
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 571
			end -- 571
			::__continue73:: -- 571
			i = i + 1 -- 568
		end -- 568
	end -- 568
	if not foundBuild then -- 568
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 578
	end -- 578
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 580
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 581
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 581
		knownIssues[#knownIssues + 1] = issue -- 582
	end -- 582
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 583
end -- 583
function isValidProjectRoot(path) -- 591
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 592
end -- 592
function rowToSession(row) -- 595
	return { -- 596
		id = row[1], -- 597
		projectRoot = toStr(row[2]), -- 598
		title = toStr(row[3]), -- 599
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 600
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 601
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 602
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 603
		status = toStr(row[8]), -- 604
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 605
		currentTaskStatus = toStr(row[10]), -- 606
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 607
		createdAt = row[11], -- 608
		updatedAt = row[12], -- 609
		metrics = decodeJsonObject(toStr(row[13])), -- 610
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 611
	} -- 611
end -- 611
function rowToMessage(row) -- 615
	local message = { -- 616
		id = row[1], -- 617
		sessionId = row[2], -- 618
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 619
		role = toStr(row[4]), -- 620
		content = toStr(row[5]), -- 621
		createdAt = row[7], -- 622
		updatedAt = row[8] -- 623
	} -- 623
	local displayContent = toStr(row[6]) -- 625
	if displayContent ~= "" then -- 625
		message.displayContent = displayContent -- 626
	end -- 626
	return message -- 627
end -- 627
function rowToStep(row) -- 630
	return { -- 631
		id = row[1], -- 632
		sessionId = row[2], -- 633
		taskId = row[3], -- 634
		step = row[4], -- 635
		tool = toStr(row[5]), -- 636
		status = toStr(row[6]), -- 637
		reason = toStr(row[7]), -- 638
		reasoningContent = toStr(row[8]), -- 639
		params = decodeJsonObject(toStr(row[9])), -- 640
		result = decodeJsonObject(toStr(row[10])), -- 641
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 642
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 643
		files = decodeJsonFiles(toStr(row[13])), -- 644
		createdAt = row[14], -- 645
		updatedAt = row[15] -- 646
	} -- 646
end -- 646
function getQuestionnairePath(projectRoot) -- 650
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 651
end -- 651
function decodeQuestionnaireFile(text) -- 654
	local value = decodeJsonObject(text) -- 655
	if not value then -- 655
		return nil -- 656
	end -- 656
	local schema = value.schema -- 657
	local id = type(value.id) == "number" and value.id or 0 -- 658
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 659
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 660
	local step = type(value.step) == "number" and value.step or 0 -- 661
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 662
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 662
		return nil -- 664
	end -- 664
	return { -- 666
		id = id, -- 666
		sessionId = sessionId, -- 666
		taskId = taskId, -- 666
		step = step, -- 666
		status = "PENDING", -- 666
		schema = schema, -- 666
		createdAt = createdAt -- 666
	} -- 666
end -- 666
function getPendingQuestionnaire(sessionId) -- 669
	local session = getSessionItem(sessionId) -- 670
	if not session or session.kind ~= "main" then -- 670
		return nil -- 671
	end -- 671
	local path = getQuestionnairePath(session.projectRoot) -- 672
	if not Content:exist(path) then -- 672
		return nil -- 673
	end -- 673
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 674
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 675
end -- 675
function restorePendingQuestionnaireState(session) -- 678
	local questionnaire = getPendingQuestionnaire(session.id) -- 679
	if not questionnaire then -- 679
		return {session = session} -- 680
	end -- 680
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 680
		local t = now() -- 687
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 688
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 694
		local restored = getSessionItem(session.id) -- 695
		if restored then -- 695
			session = restored -- 696
		end -- 696
	end -- 696
	return {session = session, questionnaire = questionnaire} -- 698
end -- 698
function savePendingQuestionnaire(projectRoot, questionnaire) -- 701
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 702
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 702
		return false -- 703
	end -- 703
	local path = getQuestionnairePath(projectRoot) -- 704
	local tempPath = path .. ".tmp" -- 705
	local backupPath = path .. ".bak" -- 706
	Content:remove(tempPath) -- 707
	Content:remove(backupPath) -- 708
	if not Content:save( -- 708
		tempPath, -- 709
		encodeJson(questionnaire) -- 709
	) then -- 709
		return false -- 709
	end -- 709
	local hadOriginal = Content:exist(path) -- 710
	if hadOriginal and not Content:move(path, backupPath) then -- 710
		Content:remove(tempPath) -- 712
		return false -- 713
	end -- 713
	if Content:move(tempPath, path) then -- 713
		Content:remove(backupPath) -- 716
		Tools.sendWebIDEFileUpdate( -- 717
			path, -- 717
			true, -- 717
			encodeJson(questionnaire) -- 717
		) -- 717
		return true -- 718
	end -- 718
	Content:remove(tempPath) -- 720
	if hadOriginal and Content:exist(backupPath) then -- 720
		Content:move(backupPath, path) -- 722
	end -- 722
	return false -- 724
end -- 724
function removePendingQuestionnaire(session) -- 727
	local path = getQuestionnairePath(session.projectRoot) -- 728
	if not Content:exist(path) then -- 728
		return true -- 729
	end -- 729
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 730
	if questionnaire and questionnaire.sessionId ~= session.id then -- 730
		return false -- 731
	end -- 731
	if not Content:remove(path) then -- 731
		return false -- 732
	end -- 732
	Tools.sendWebIDEFileUpdate(path, false, "") -- 733
	return true -- 734
end -- 734
function publishQuestionnaire(request) -- 737
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 737
		local session = getSessionItem(request.sessionId) -- 743
		if not session or session.kind ~= "main" then -- 743
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 743
		end -- 743
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 745
		if Content:exist(pendingPath) then -- 745
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 745
		end -- 745
		local questionnaire = { -- 747
			id = request.taskId, -- 748
			sessionId = request.sessionId, -- 749
			taskId = request.taskId, -- 750
			step = request.step, -- 751
			status = "PENDING", -- 752
			schema = request.schema, -- 753
			createdAt = now() -- 754
		} -- 754
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 754
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 754
		end -- 754
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 754
	end) -- 754
end -- 754
function getMessageItem(messageId) -- 762
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 763
	return row and rowToMessage(row) or nil -- 769
end -- 769
function getStepItem(sessionId, taskId, step) -- 772
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 773
	return row and rowToStep(row) or nil -- 779
end -- 779
function deleteMessageSteps(sessionId, taskId) -- 782
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 783
	local ids = {} -- 788
	do -- 788
		local i = 0 -- 789
		while i < #rows do -- 789
			local row = rows[i + 1] -- 790
			if type(row[1]) == "number" then -- 790
				ids[#ids + 1] = row[1] -- 792
			end -- 792
			i = i + 1 -- 789
		end -- 789
	end -- 789
	if #ids > 0 then -- 789
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 796
	end -- 796
	return ids -- 802
end -- 802
function normalizeDisabledAgentTools(value) -- 805
	if not __TS__ArrayIsArray(value) then -- 805
		return {} -- 806
	end -- 806
	local tools = {} -- 807
	do -- 807
		local i = 0 -- 808
		while i < #value do -- 808
			do -- 808
				local name = value[i + 1] -- 809
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 809
					goto __continue117 -- 810
				end -- 810
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 810
					tools[#tools + 1] = name -- 811
				end -- 811
			end -- 811
			::__continue117:: -- 811
			i = i + 1 -- 808
		end -- 808
	end -- 808
	return tools -- 813
end -- 813
function normalizeWorkMode(value, fallback) -- 816
	if fallback == nil then -- 816
		fallback = "code" -- 816
	end -- 816
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 817
end -- 817
function getSessionRow(sessionId) -- 820
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 821
end -- 821
function getSessionItem(sessionId) -- 829
	local row = getSessionRow(sessionId) -- 830
	return row and rowToSession(row) or nil -- 831
end -- 831
function getTaskPrompt(taskId) -- 834
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 835
	if not row or type(row[1]) ~= "string" then -- 835
		return nil -- 836
	end -- 836
	return toStr(row[1]) -- 837
end -- 837
function getLatestMainSessionByProjectRoot(projectRoot) -- 840
	if not isValidProjectRoot(projectRoot) then -- 840
		return nil -- 841
	end -- 841
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 842
	return row and rowToSession(row) or nil -- 850
end -- 850
function countRunningSubSessions(rootSessionId) -- 853
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 854
	local count = 0 -- 861
	do -- 861
		local i = 0 -- 862
		while i < #rows do -- 862
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 863
			if session.currentTaskStatus == "RUNNING" then -- 863
				count = count + 1 -- 865
			end -- 865
			i = i + 1 -- 862
		end -- 862
	end -- 862
	return count -- 868
end -- 868
function deleteSessionRecords(sessionId, preserveArtifacts) -- 871
	if preserveArtifacts == nil then -- 871
		preserveArtifacts = false -- 871
	end -- 871
	local session = getSessionItem(sessionId) -- 872
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 873
	local taskIds = {} -- 881
	do -- 881
		local i = 0 -- 882
		while i < #taskRows do -- 882
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 883
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 883
				taskIds[#taskIds + 1] = taskId -- 885
				local stopToken = activeStopTokens[taskId] -- 886
				if stopToken ~= nil then -- 886
					stopToken.stopped = true -- 888
					stopToken.reason = "session deleted" -- 889
				end -- 889
			end -- 889
			i = i + 1 -- 882
		end -- 882
	end -- 882
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 893
	do -- 893
		local i = 0 -- 894
		while i < #children do -- 894
			local row = children[i + 1] -- 895
			if type(row[1]) == "number" and row[1] > 0 then -- 895
				deleteSessionRecords(row[1], preserveArtifacts) -- 897
			end -- 897
			i = i + 1 -- 894
		end -- 894
	end -- 894
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 900
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 901
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 902
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 903
	if session and session.kind == "main" then -- 903
		removePendingQuestionnaire(session) -- 905
	end -- 905
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 905
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 905
			Tools.sendWebIDERefreshTree() -- 909
		end -- 909
	end -- 909
	do -- 909
		local i = 0 -- 912
		while i < #taskIds do -- 912
			cleanupTaskHeavyData(taskIds[i + 1]) -- 913
			i = i + 1 -- 912
		end -- 912
	end -- 912
end -- 912
function getSessionRootId(session) -- 917
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 918
end -- 918
function getRootSessionItem(sessionId) -- 921
	local session = getSessionItem(sessionId) -- 922
	if not session then -- 922
		return nil -- 923
	end -- 923
	return getSessionItem(getSessionRootId(session)) or session -- 924
end -- 924
function listRelatedSessions(sessionId) -- 927
	local root = getRootSessionItem(sessionId) -- 928
	if not root then -- 928
		return {} -- 929
	end -- 929
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 930
	return __TS__ArrayMap( -- 939
		rows, -- 939
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 939
	) -- 939
end -- 939
function getSessionSpawnInfo(session) -- 942
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 943
	if not info then -- 943
		return nil -- 944
	end -- 944
	local ____temp_15 = type(info.sessionId) == "number" and info.sessionId or nil -- 946
	local ____temp_16 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 947
	local ____temp_17 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 948
	local ____temp_18 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 949
	local ____temp_19 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 950
	local ____temp_20 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 951
	local ____temp_21 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 952
	local ____temp_22 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 953
		__TS__ArrayFilter( -- 954
			info.filesHint, -- 954
			function(____, item) return type(item) == "string" end -- 954
		), -- 954
		function(____, item) return sanitizeUTF8(item) end -- 954
	) or nil -- 954
	local ____temp_23 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 956
	local ____temp_13 -- 959
	if info.success == true then -- 959
		____temp_13 = true -- 959
	else -- 959
		local ____temp_12 -- 959
		if info.success == false then -- 959
			____temp_12 = false -- 959
		else -- 959
			____temp_12 = nil -- 959
		end -- 959
		____temp_13 = ____temp_12 -- 959
	end -- 959
	local ____temp_14 -- 960
	if info.cleared == true then -- 960
		____temp_14 = true -- 960
	else -- 960
		____temp_14 = nil -- 960
	end -- 960
	return { -- 945
		sessionId = ____temp_15, -- 946
		rootSessionId = ____temp_16, -- 947
		parentSessionId = ____temp_17, -- 948
		title = ____temp_18, -- 949
		prompt = ____temp_19, -- 950
		goal = ____temp_20, -- 951
		expectedOutput = ____temp_21, -- 952
		filesHint = ____temp_22, -- 953
		status = ____temp_23, -- 956
		success = ____temp_13, -- 959
		cleared = ____temp_14, -- 960
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 961
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 962
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 963
		changeSet = decodeChangeSetSummary(info.changeSet), -- 964
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 965
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 966
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 967
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 968
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 971
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 972
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 973
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 974
	} -- 974
end -- 974
function ensureDirRecursive(dir) -- 991
	if not dir or dir == "" then -- 991
		return false -- 992
	end -- 992
	if Content:exist(dir) then -- 992
		return Content:isdir(dir) -- 993
	end -- 993
	local parent = Path:getPath(dir) -- 994
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 994
		if not ensureDirRecursive(parent) then -- 994
			return false -- 997
		end -- 997
	end -- 997
	return Content:mkdir(dir) -- 1000
end -- 1000
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1003
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1004
	if not Content:exist(dir) then -- 1004
		ensureDirRecursive(dir) -- 1006
	end -- 1006
	local path = Path(dir, SPAWN_INFO_FILE) -- 1008
	local text = safeJsonEncode(value) -- 1009
	if not text then -- 1009
		return false -- 1010
	end -- 1010
	local content = text .. "\n" -- 1011
	if not Content:save(path, content) then -- 1011
		return false -- 1013
	end -- 1013
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1015
	return true -- 1016
end -- 1016
function readSpawnInfo(projectRoot, memoryScope) -- 1019
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1020
	if not Content:exist(path) then -- 1020
		return nil -- 1021
	end -- 1021
	local text = Content:load(path) -- 1022
	if not text or __TS__StringTrim(text) == "" then -- 1022
		return nil -- 1023
	end -- 1023
	local value = safeJsonDecode(text) -- 1024
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1024
		return value -- 1026
	end -- 1026
	return nil -- 1028
end -- 1028
function getArtifactRelativeDir(memoryScope) -- 1031
	return Path(".agent", memoryScope) -- 1032
end -- 1032
function getArtifactDir(projectRoot, memoryScope) -- 1035
	return Path( -- 1036
		projectRoot, -- 1036
		getArtifactRelativeDir(memoryScope) -- 1036
	) -- 1036
end -- 1036
function getResultRelativePath(memoryScope) -- 1039
	return Path( -- 1040
		getArtifactRelativeDir(memoryScope), -- 1040
		RESULT_FILE -- 1040
	) -- 1040
end -- 1040
function getResultPath(projectRoot, memoryScope) -- 1043
	return Path( -- 1044
		projectRoot, -- 1044
		getResultRelativePath(memoryScope) -- 1044
	) -- 1044
end -- 1044
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1047
	if not resultFilePath or resultFilePath == "" then -- 1047
		return "" -- 1048
	end -- 1048
	local path = Path(projectRoot, resultFilePath) -- 1049
	if not Content:exist(path) then -- 1049
		return "" -- 1050
	end -- 1050
	local text = sanitizeUTF8(Content:load(path)) -- 1051
	if not text or __TS__StringTrim(text) == "" then -- 1051
		return "" -- 1052
	end -- 1052
	local marker = "\n## Summary\n" -- 1053
	local start = string.find(text, marker, 1, true) -- 1054
	if start ~= nil then -- 1054
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1056
	end -- 1056
	return __TS__StringTrim(text) -- 1058
end -- 1058
function buildStructuredSubAgentMemoryEntry(record) -- 1061
	local hasPassedValidation = false -- 1062
	do -- 1062
		local i = 0 -- 1063
		while i < #record.completion.validation do -- 1063
			local result = record.completion.validation[i + 1].result -- 1064
			if result == "failed" then -- 1064
				return nil -- 1069
			end -- 1069
			if result == "passed" then -- 1069
				hasPassedValidation = true -- 1071
			end -- 1071
			i = i + 1 -- 1063
		end -- 1063
	end -- 1063
	if not hasPassedValidation then -- 1063
		return nil -- 1074
	end -- 1074
	local candidates = record.completion.learningCandidates -- 1075
	local claims = {} -- 1076
	local evidence = {} -- 1077
	do -- 1077
		local i = 0 -- 1078
		while i < #candidates do -- 1078
			do -- 1078
				local candidate = candidates[i + 1] -- 1079
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1079
					goto __continue188 -- 1080
				end -- 1080
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1081
				do -- 1081
					local j = 0 -- 1082
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1082
						local item = candidate.evidence[j + 1] -- 1083
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1083
							evidence[#evidence + 1] = item -- 1084
						end -- 1084
						j = j + 1 -- 1082
					end -- 1082
				end -- 1082
			end -- 1082
			::__continue188:: -- 1082
			i = i + 1 -- 1078
		end -- 1078
	end -- 1078
	local content = takeUtf8Head( -- 1087
		table.concat(claims, "\n"), -- 1087
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1087
	) -- 1087
	if content == "" then -- 1087
		return nil -- 1088
	end -- 1088
	return { -- 1089
		sourceSessionId = record.sessionId, -- 1090
		sourceTaskId = record.sourceTaskId, -- 1091
		content = content, -- 1092
		evidence = evidence, -- 1093
		createdAt = record.finishedAt -- 1094
	} -- 1094
end -- 1094
function containsNormalizedText(text, query) -- 1098
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1099
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1100
	if normalizedQuery == "" then -- 1100
		return true -- 1101
	end -- 1101
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1102
end -- 1102
function getSubAgentDisplayKey(item) -- 1105
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1111
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1112
	local label = goal ~= "" and goal or title -- 1113
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1114
end -- 1114
function writeSubAgentResultFile(session, record, resultText) -- 1117
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1118
	if not Content:exist(dir) then -- 1118
		ensureDirRecursive(dir) -- 1120
	end -- 1120
	local ____array_32 = __TS__SparseArrayNew( -- 1120
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1123
		"- Status: " .. record.status, -- 1124
		"- Success: " .. (record.success and "true" or "false"), -- 1125
		"- Outcome: " .. record.completion.outcome, -- 1126
		"- Session ID: " .. tostring(record.sessionId), -- 1127
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1128
		"- Goal: " .. record.goal, -- 1129
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1130
	) -- 1130
	__TS__SparseArrayPush( -- 1130
		____array_32, -- 1130
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1131
	) -- 1131
	__TS__SparseArrayPush( -- 1131
		____array_32, -- 1131
		"- Finished At: " .. record.finishedAt, -- 1132
		"", -- 1133
		"## Validation", -- 1134
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1135
			record.completion.validation, -- 1136
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1136
		) or ({"- Not reported"})) -- 1136
	) -- 1136
	__TS__SparseArrayPush(____array_32, "", "## Recorded Evidence") -- 1136
	local ____opt_24 = record.handoffEvidence -- 1136
	__TS__SparseArrayPush( -- 1136
		____array_32, -- 1136
		table.unpack(____opt_24 and #____opt_24.modifiedFiles and __TS__ArrayMap( -- 1140
			record.handoffEvidence.modifiedFiles, -- 1141
			function(____, item) return "- modified: " .. item end -- 1141
		) or ({"- modified: none recorded"})) -- 1141
	) -- 1141
	local ____opt_26 = record.handoffEvidence -- 1141
	__TS__SparseArrayPush( -- 1141
		____array_32, -- 1141
		table.unpack(____opt_26 and ____opt_26.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1143
	) -- 1143
	local ____opt_28 = record.handoffEvidence -- 1143
	__TS__SparseArrayPush( -- 1143
		____array_32, -- 1143
		table.unpack(__TS__ArrayMap( -- 1146
			____opt_28 and ____opt_28.commands or ({}), -- 1146
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1146
		)) -- 1146
	) -- 1146
	local ____opt_30 = record.handoffEvidence -- 1146
	__TS__SparseArrayPush( -- 1146
		____array_32, -- 1146
		table.unpack(__TS__ArrayMap( -- 1147
			____opt_30 and ____opt_30.authoritativeSources or ({}), -- 1147
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1147
		)) -- 1147
	) -- 1147
	__TS__SparseArrayPush( -- 1147
		____array_32, -- 1147
		"", -- 1148
		"## Known Issues", -- 1149
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1150
			record.completion.knownIssues, -- 1150
			function(____, item) return "- " .. item end -- 1150
		) or ({"- None reported"})) -- 1150
	) -- 1150
	__TS__SparseArrayPush( -- 1150
		____array_32, -- 1150
		"", -- 1151
		"## Assumptions", -- 1152
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1153
			record.completion.assumptions, -- 1153
			function(____, item) return "- " .. item end -- 1153
		) or ({"- None reported"})) -- 1153
	) -- 1153
	__TS__SparseArrayPush(____array_32, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1153
	local lines = {__TS__SparseArraySpread(____array_32)} -- 1122
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1158
	local content = table.concat(lines, "\n") .. "\n" -- 1159
	if not Content:save(path, content) then -- 1159
		return false -- 1161
	end -- 1161
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1163
	return true -- 1164
end -- 1164
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1167
	local dir = Path(projectRoot, ".agent", "subagents") -- 1168
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1168
		return {} -- 1169
	end -- 1169
	local items = {} -- 1170
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1171
		do -- 1171
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1172
			if not Content:exist(path) or not Content:isdir(path) then -- 1172
				goto __continue208 -- 1173
			end -- 1173
			local info = readSpawnInfo( -- 1174
				projectRoot, -- 1174
				Path( -- 1174
					"subagents", -- 1174
					Path:getFilename(path) -- 1174
				) -- 1174
			) -- 1174
			if not info then -- 1174
				goto __continue208 -- 1175
			end -- 1175
			local sessionId = tonumber(info.sessionId) -- 1176
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1177
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1178
			local status = sanitizeUTF8(toStr(info.status)) -- 1179
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1179
				goto __continue208 -- 1180
			end -- 1180
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1180
				goto __continue208 -- 1181
			end -- 1181
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1182
			items[#items + 1] = { -- 1183
				sessionId = sessionId, -- 1184
				rootSessionId = infoRootSessionId, -- 1185
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1186
				title = sanitizeUTF8(toStr(info.title)), -- 1187
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1188
				goal = sanitizeUTF8(toStr(info.goal)), -- 1189
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1190
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1191
					__TS__ArrayFilter( -- 1192
						info.filesHint, -- 1192
						function(____, item) return type(item) == "string" end -- 1192
					), -- 1192
					function(____, item) return sanitizeUTF8(item) end -- 1192
				) or ({}), -- 1192
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1194
				success = info.success == true, -- 1195
				cleared = info.cleared == true, -- 1196
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1197
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1198
					"subagents", -- 1198
					Path:getFilename(path) -- 1198
				)), -- 1198
				sourceTaskId = sourceTaskId or 0, -- 1199
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1200
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1201
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1202
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1203
				completion = normalizeAgentCompletionReport(info.completion), -- 1204
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1205
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1206
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1207
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1208
			} -- 1208
		end -- 1208
		::__continue208:: -- 1208
	end -- 1208
	__TS__ArraySort( -- 1211
		items, -- 1211
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1211
	) -- 1211
	return items -- 1212
end -- 1212
function getPendingHandoffDir(projectRoot, memoryScope) -- 1215
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1216
end -- 1216
function writePendingHandoff(projectRoot, memoryScope, value) -- 1219
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1220
	if not Content:exist(dir) then -- 1220
		ensureDirRecursive(dir) -- 1222
	end -- 1222
	local path = Path(dir, value.id .. ".json") -- 1224
	local text = safeJsonEncode(value) -- 1225
	if not text then -- 1225
		return false -- 1226
	end -- 1226
	local content = text .. "\n" -- 1227
	if not Content:save(path, content) then -- 1227
		return false -- 1228
	end -- 1228
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1229
	return true -- 1230
end -- 1230
function listPendingHandoffs(projectRoot, memoryScope) -- 1233
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1234
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1234
		return {} -- 1235
	end -- 1235
	local items = {} -- 1236
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1237
		do -- 1237
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1238
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1238
				goto __continue224 -- 1239
			end -- 1239
			local text = Content:load(path) -- 1240
			if not text or __TS__StringTrim(text) == "" then -- 1240
				goto __continue224 -- 1241
			end -- 1241
			local obj = safeJsonDecode(text) -- 1242
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1242
				goto __continue224 -- 1243
			end -- 1243
			local value = obj -- 1244
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1245
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1246
			local id = sanitizeUTF8(toStr(value.id)) -- 1247
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1248
			local message = sanitizeUTF8(toStr(value.message)) -- 1249
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1250
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1251
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1252
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1252
				goto __continue224 -- 1254
			end -- 1254
			items[#items + 1] = { -- 1256
				id = id, -- 1257
				sourceSessionId = sourceSessionId, -- 1258
				sourceTitle = sourceTitle, -- 1259
				sourceTaskId = sourceTaskId, -- 1260
				message = message, -- 1261
				prompt = prompt, -- 1262
				goal = goal, -- 1263
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1264
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1265
					__TS__ArrayFilter( -- 1266
						value.filesHint, -- 1266
						function(____, item) return type(item) == "string" end -- 1266
					), -- 1266
					function(____, item) return sanitizeUTF8(item) end -- 1266
				) or ({}), -- 1266
				success = value.success == true, -- 1268
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1269
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1270
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1271
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1272
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1273
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1274
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1275
				createdAt = createdAt -- 1278
			} -- 1278
		end -- 1278
		::__continue224:: -- 1278
	end -- 1278
	__TS__ArraySort( -- 1281
		items, -- 1281
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1281
	) -- 1281
	return items -- 1282
end -- 1282
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1285
	local path = Path( -- 1286
		getPendingHandoffDir(projectRoot, memoryScope), -- 1286
		id .. ".json" -- 1286
	) -- 1286
	if Content:exist(path) then -- 1286
		if Content:remove(path) then -- 1286
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1289
		end -- 1289
	end -- 1289
end -- 1289
function normalizePromptText(prompt) -- 1294
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1295
end -- 1295
function normalizePromptTextSafe(prompt) -- 1298
	if type(prompt) == "string" then -- 1298
		local normalized = normalizePromptText(prompt) -- 1300
		if normalized ~= "" then -- 1300
			return normalized -- 1301
		end -- 1301
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1302
		if sanitized ~= "" then -- 1302
			return truncateAgentUserPrompt(sanitized) -- 1304
		end -- 1304
		return "" -- 1306
	end -- 1306
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1308
	if text == "" then -- 1308
		return "" -- 1309
	end -- 1309
	return truncateAgentUserPrompt(text) -- 1310
end -- 1310
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1313
	local sections = {} -- 1314
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1315
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1316
	local normalizedFiles = __TS__ArrayFilter( -- 1317
		__TS__ArrayMap( -- 1317
			__TS__ArrayFilter( -- 1317
				filesHint or ({}), -- 1317
				function(____, item) return type(item) == "string" end -- 1318
			), -- 1318
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1319
		), -- 1319
		function(____, item) return item ~= "" end -- 1320
	) -- 1320
	if normalizedTitle ~= "" then -- 1320
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1322
	end -- 1322
	if normalizedExpected ~= "" then -- 1322
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1325
	end -- 1325
	if #normalizedFiles > 0 then -- 1325
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1328
	end -- 1328
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1330
end -- 1330
function normalizeSessionRuntimeState(session) -- 1333
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1333
		return session -- 1335
	end -- 1335
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1335
		return session -- 1338
	end -- 1338
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1340
	if #pendingToolRows > 0 then -- 1340
		local t = now() -- 1346
		do -- 1346
			local i = 0 -- 1347
			while i < #pendingToolRows do -- 1347
				local row = pendingToolRows[i + 1] -- 1348
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1349
				result.success = false -- 1350
				result.state = "failed" -- 1351
				result.interrupted = true -- 1352
				result.message = "tool call was interrupted because the program exited before it completed." -- 1353
				DB:exec( -- 1354
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1354
					{ -- 1356
						encodeJson(result), -- 1356
						t, -- 1356
						row[1] -- 1356
					} -- 1356
				) -- 1356
				i = i + 1 -- 1347
			end -- 1347
		end -- 1347
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1359
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1360
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1361
	end -- 1361
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1368
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1369
	return __TS__ObjectAssign( -- 1370
		{}, -- 1370
		session, -- 1371
		{ -- 1370
			status = "STOPPED", -- 1372
			currentTaskStatus = "STOPPED", -- 1373
			updatedAt = now() -- 1374
		} -- 1374
	) -- 1374
end -- 1374
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1378
	DB:exec( -- 1379
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1379
		{ -- 1383
			status, -- 1384
			currentTaskId or 0, -- 1385
			currentTaskStatus or status, -- 1386
			now(), -- 1387
			sessionId -- 1388
		} -- 1388
	) -- 1388
end -- 1388
function mergeAgentMetrics(current, next) -- 1393
	return __TS__ObjectAssign({}, current or ({}), next) -- 1394
end -- 1394
function updateSessionMetrics(sessionId, metrics) -- 1400
	local session = getSessionItem(sessionId) -- 1401
	if not session then -- 1401
		return nil -- 1402
	end -- 1402
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1403
	DB:exec( -- 1404
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1404
		{ -- 1408
			encodeJson(merged), -- 1409
			now(), -- 1410
			sessionId -- 1411
		} -- 1411
	) -- 1411
	return merged -- 1414
end -- 1414
function clearSessionTokenUsage(sessionId) -- 1417
	local session = getSessionItem(sessionId) -- 1418
	if not session then -- 1418
		return nil -- 1419
	end -- 1419
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1420
	__TS__Delete(metrics, "usage") -- 1421
	DB:exec( -- 1422
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1422
		{ -- 1426
			encodeJson(metrics), -- 1427
			now(), -- 1428
			sessionId -- 1429
		} -- 1429
	) -- 1429
	return metrics -- 1432
end -- 1432
function getInitialTokenUsage(session) -- 1435
	local ____opt_33 = session.metrics -- 1435
	local usage = ____opt_33 and ____opt_33.usage -- 1436
	if not usage or (usage.requestCount or 0) <= 0 then -- 1436
		return nil -- 1437
	end -- 1437
	return { -- 1438
		inputTokens = usage.inputTokens or 0, -- 1439
		outputTokens = usage.outputTokens or 0, -- 1440
		totalTokens = usage.totalTokens, -- 1441
		cachedInputTokens = usage.cachedInputTokens, -- 1442
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1443
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1444
		requestCount = usage.requestCount or 0, -- 1445
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1446
		model = usage.model or "", -- 1447
		phase = usage.phase or "", -- 1448
		step = usage.step or 0, -- 1449
		updatedAt = usage.updatedAt or now() -- 1450
	} -- 1450
end -- 1450
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1454
	if taskId == nil or taskId <= 0 then -- 1454
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1456
		return -- 1457
	end -- 1457
	local row = getSessionRow(sessionId) -- 1459
	if not row then -- 1459
		return -- 1460
	end -- 1460
	local session = rowToSession(row) -- 1461
	if session.currentTaskId ~= taskId then -- 1461
		Log( -- 1463
			"Info", -- 1463
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1463
		) -- 1463
		return -- 1464
	end -- 1464
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1466
end -- 1466
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1469
	local t = now() -- 1470
	DB:exec( -- 1471
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1471
		{ -- 1474
			sessionId, -- 1475
			taskId or 0, -- 1476
			role, -- 1477
			sanitizeUTF8(content), -- 1478
			displayContent and sanitizeUTF8(displayContent) or "", -- 1479
			t, -- 1480
			t -- 1481
		} -- 1481
	) -- 1481
	return getLastInsertRowId() -- 1484
end -- 1484
function updateMessage(messageId, content) -- 1487
	DB:exec( -- 1488
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1488
		{ -- 1490
			sanitizeUTF8(content), -- 1490
			now(), -- 1490
			messageId -- 1490
		} -- 1490
	) -- 1490
end -- 1490
function updateUserMessageForTask(messageId, content, taskId) -- 1494
	DB:exec( -- 1495
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1495
		{ -- 1499
			sanitizeUTF8(content), -- 1499
			taskId, -- 1499
			now(), -- 1499
			messageId -- 1499
		} -- 1499
	) -- 1499
end -- 1499
function removeContinuableTaskSummary(session) -- 1556
	local taskId = session.currentTaskId -- 1557
	if taskId == nil then -- 1557
		return -- 1558
	end -- 1558
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1559
end -- 1559
function upsertAssistantMessage(sessionId, taskId, content) -- 1571
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1572
	if row and type(row[1]) == "number" then -- 1572
		updateMessage(row[1], content) -- 1579
		return row[1] -- 1580
	end -- 1580
	return insertMessage(sessionId, "assistant", content, taskId) -- 1582
end -- 1582
function upsertStep(sessionId, taskId, step, tool, patch) -- 1585
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1595
	local reason = sanitizeUTF8(patch.reason or "") -- 1599
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1600
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1601
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1602
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1603
	local statusPatch = patch.status or "" -- 1604
	local status = patch.status or "PENDING" -- 1605
	if not row then -- 1605
		local t = now() -- 1607
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1608
			sessionId, -- 1612
			taskId, -- 1613
			step, -- 1614
			tool, -- 1615
			status, -- 1616
			reason, -- 1617
			reasoningContent, -- 1618
			paramsJson, -- 1619
			resultJson, -- 1620
			patch.checkpointId or 0, -- 1621
			patch.checkpointSeq or 0, -- 1622
			filesJson, -- 1623
			t, -- 1624
			t -- 1625
		}) -- 1625
		return -- 1628
	end -- 1628
	DB:exec( -- 1630
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1630
		{ -- 1642
			tool, -- 1643
			statusPatch, -- 1644
			status, -- 1645
			reason, -- 1646
			reason, -- 1647
			reasoningContent, -- 1648
			reasoningContent, -- 1649
			paramsJson, -- 1650
			paramsJson, -- 1651
			resultJson, -- 1652
			resultJson, -- 1653
			patch.checkpointId or 0, -- 1654
			patch.checkpointId or 0, -- 1655
			patch.checkpointSeq or 0, -- 1656
			patch.checkpointSeq or 0, -- 1657
			filesJson, -- 1658
			filesJson, -- 1659
			now(), -- 1660
			row[1] -- 1661
		} -- 1661
	) -- 1661
end -- 1661
function getNextStepNumber(sessionId, taskId) -- 1666
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1667
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1671
	return math.max(0, current) + 1 -- 1672
end -- 1672
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1713
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1721
	local t = now() -- 1722
	local sqls = { -- 1723
		{ -- 1724
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1724
			{{ -- 1727
				sessionId, -- 1728
				ownerTaskId, -- 1729
				step, -- 1730
				"sub_agent_handoff", -- 1731
				"DONE", -- 1732
				sanitizeUTF8(reason), -- 1733
				encodeJson(params), -- 1734
				encodeJson(result), -- 1735
				t, -- 1736
				t -- 1737
			}} -- 1737
		}, -- 1737
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1740
	} -- 1740
	if not DB:transaction(sqls) then -- 1740
		return nil -- 1746
	end -- 1746
	return getStepItem(sessionId, ownerTaskId, step) -- 1747
end -- 1747
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1750
	if taskId <= 0 then -- 1750
		return -- 1751
	end -- 1751
	if finalSteps ~= nil and finalSteps >= 0 then -- 1751
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1753
	end -- 1753
	if not finalStatus then -- 1753
		return -- 1759
	end -- 1759
	if finalSteps ~= nil and finalSteps >= 0 then -- 1759
		DB:exec( -- 1761
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1761
			{ -- 1765
				finalStatus, -- 1765
				now(), -- 1765
				sessionId, -- 1765
				taskId, -- 1765
				finalSteps -- 1765
			} -- 1765
		) -- 1765
		return -- 1767
	end -- 1767
	DB:exec( -- 1769
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1769
		{ -- 1773
			finalStatus, -- 1773
			now(), -- 1773
			sessionId, -- 1773
			taskId -- 1773
		} -- 1773
	) -- 1773
end -- 1773
function emitAgentSessionPatch(sessionId, patch) -- 1800
	if HttpServer.wsConnectionCount == 0 then -- 1800
		return -- 1802
	end -- 1802
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1804
	if not text then -- 1804
		return -- 1809
	end -- 1809
	emit("AppWS", "Send", text) -- 1810
end -- 1810
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1813
	emitAgentSessionPatch( -- 1814
		sessionId, -- 1814
		{ -- 1814
			sessionDeleted = true, -- 1815
			relatedSessions = listRelatedSessions(rootSessionId) -- 1816
		} -- 1816
	) -- 1816
	local rootSession = getSessionItem(rootSessionId) -- 1818
	if rootSession then -- 1818
		emitAgentSessionPatch( -- 1820
			rootSessionId, -- 1820
			{ -- 1820
				session = rootSession, -- 1821
				relatedSessions = listRelatedSessions(rootSessionId) -- 1822
			} -- 1822
		) -- 1822
	end -- 1822
end -- 1822
function flushPendingSubAgentHandoffs(rootSession) -- 1827
	if rootSession.kind ~= "main" then -- 1827
		return -- 1828
	end -- 1828
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1828
		return -- 1830
	end -- 1830
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1832
	if #items == 0 then -- 1832
		return -- 1833
	end -- 1833
	local handoffTaskId = 0 -- 1834
	local previousTaskId = rootSession.currentTaskId -- 1835
	local ____rootSession_currentTaskId_37 -- 1836
	if rootSession.currentTaskId then -- 1836
		____rootSession_currentTaskId_37 = getTaskPrompt(rootSession.currentTaskId) -- 1836
	else -- 1836
		____rootSession_currentTaskId_37 = nil -- 1836
	end -- 1836
	local currentTaskPrompt = ____rootSession_currentTaskId_37 -- 1836
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1836
		handoffTaskId = rootSession.currentTaskId -- 1844
	else -- 1844
		local taskRes = Tools.createTask( -- 1846
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1846
			"code" -- 1846
		) -- 1846
		if not taskRes.success then -- 1846
			Log( -- 1848
				"Warn", -- 1848
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1848
			) -- 1848
			return -- 1849
		end -- 1849
		handoffTaskId = taskRes.taskId -- 1851
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1852
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1853
		emitAgentSessionPatch( -- 1854
			rootSession.id, -- 1854
			{session = getSessionItem(rootSession.id)} -- 1854
		) -- 1854
	end -- 1854
	do -- 1854
		local i = 0 -- 1858
		while i < #items do -- 1858
			local item = items[i + 1] -- 1859
			local step = appendHandoffSystemStep( -- 1860
				rootSession.id, -- 1861
				handoffTaskId, -- 1862
				item.sourceTaskId, -- 1863
				item.message, -- 1864
				{ -- 1865
					sourceSessionId = item.sourceSessionId, -- 1866
					sourceTitle = item.sourceTitle, -- 1867
					sourceTaskId = item.sourceTaskId, -- 1868
					success = item.success == true, -- 1869
					summary = item.message, -- 1870
					resultFilePath = item.resultFilePath or "", -- 1871
					artifactDir = item.artifactDir or "", -- 1872
					finishedAt = item.finishedAt or "", -- 1873
					changeSet = item.changeSet, -- 1874
					handoffEvidence = item.handoffEvidence, -- 1875
					memoryEntry = item.memoryEntry, -- 1876
					completion = item.completion -- 1877
				}, -- 1877
				{ -- 1879
					sourceSessionId = item.sourceSessionId, -- 1880
					sourceTitle = item.sourceTitle, -- 1881
					sourceTaskId = item.sourceTaskId, -- 1882
					prompt = item.prompt, -- 1883
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1884
					expectedOutput = item.expectedOutput or "", -- 1885
					filesHint = item.filesHint or ({}), -- 1886
					resultFilePath = item.resultFilePath or "", -- 1887
					artifactDir = item.artifactDir or "", -- 1888
					changeSet = item.changeSet, -- 1889
					handoffEvidence = item.handoffEvidence, -- 1890
					memoryEntry = item.memoryEntry, -- 1891
					completion = item.completion -- 1892
				} -- 1892
			) -- 1892
			if step then -- 1892
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1896
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1897
			else -- 1897
				Log( -- 1899
					"Warn", -- 1899
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1899
				) -- 1899
			end -- 1899
			i = i + 1 -- 1858
		end -- 1858
	end -- 1858
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1858
		cleanupTaskHeavyData(previousTaskId) -- 1903
	end -- 1903
end -- 1903
function applyEvent(sessionId, event) -- 1915
	if not getSessionItem(sessionId) then -- 1915
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1915
			__TS__Delete(activeStopTokens, event.taskId) -- 1918
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1919
		end -- 1919
		return -- 1921
	end -- 1921
	repeat -- 1921
		local ____switch317 = event.type -- 1921
		local metrics, startedSession -- 1921
		local ____cond317 = ____switch317 == "task_started" -- 1921
		if ____cond317 then -- 1921
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1925
			local ____event_resumed_40 -- 1926
			if event.resumed then -- 1926
				local ____opt_38 = getSessionItem(sessionId) -- 1926
				____event_resumed_40 = ____opt_38 and ____opt_38.metrics -- 1927
			else -- 1927
				____event_resumed_40 = clearSessionTokenUsage(sessionId) -- 1928
			end -- 1928
			metrics = ____event_resumed_40 -- 1926
			startedSession = getSessionItem(sessionId) -- 1929
			emitAgentSessionPatch( -- 1930
				sessionId, -- 1930
				{ -- 1930
					session = startedSession, -- 1931
					metrics = metrics, -- 1932
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1933
				} -- 1933
			) -- 1933
			break -- 1937
		end -- 1937
		____cond317 = ____cond317 or ____switch317 == "decision_made" -- 1937
		if ____cond317 then -- 1937
			upsertStep( -- 1939
				sessionId, -- 1939
				event.taskId, -- 1939
				event.step, -- 1939
				event.tool, -- 1939
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1939
			) -- 1939
			emitAgentSessionPatch( -- 1947
				sessionId, -- 1947
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1947
			) -- 1947
			break -- 1950
		end -- 1950
		____cond317 = ____cond317 or ____switch317 == "tool_started" -- 1950
		if ____cond317 then -- 1950
			upsertStep( -- 1952
				sessionId, -- 1952
				event.taskId, -- 1952
				event.step, -- 1952
				event.tool, -- 1952
				{status = "RUNNING"} -- 1952
			) -- 1952
			emitAgentSessionPatch( -- 1955
				sessionId, -- 1955
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1955
			) -- 1955
			break -- 1958
		end -- 1958
		____cond317 = ____cond317 or ____switch317 == "tool_finished" -- 1958
		if ____cond317 then -- 1958
			do -- 1958
				local ____temp_43 = event.result.success ~= true -- 1960
				if ____temp_43 then -- 1960
					local ____opt_41 = activeStopTokens[event.taskId] -- 1960
					____temp_43 = (____opt_41 and ____opt_41.stopped) == true -- 1960
				end -- 1960
				local stopped = ____temp_43 -- 1960
				upsertStep( -- 1962
					sessionId, -- 1962
					event.taskId, -- 1962
					event.step, -- 1962
					event.tool, -- 1962
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1962
				) -- 1962
				emitAgentSessionPatch( -- 1970
					sessionId, -- 1970
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1970
				) -- 1970
				break -- 1973
			end -- 1973
		end -- 1973
		____cond317 = ____cond317 or ____switch317 == "tool_progress" -- 1973
		if ____cond317 then -- 1973
			do -- 1973
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1977
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1977
					break -- 1979
				end -- 1979
			end -- 1979
			upsertStep( -- 1982
				sessionId, -- 1982
				event.taskId, -- 1982
				event.step, -- 1982
				event.tool, -- 1982
				{status = "RUNNING", result = event.result} -- 1982
			) -- 1982
			emitAgentSessionPatch( -- 1986
				sessionId, -- 1986
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1986
			) -- 1986
			break -- 1989
		end -- 1989
		____cond317 = ____cond317 or ____switch317 == "checkpoint_created" -- 1989
		if ____cond317 then -- 1989
			upsertStep( -- 1991
				sessionId, -- 1991
				event.taskId, -- 1991
				event.step, -- 1991
				event.tool, -- 1991
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1991
			) -- 1991
			emitAgentSessionPatch( -- 1996
				sessionId, -- 1996
				{ -- 1996
					step = getStepItem(sessionId, event.taskId, event.step), -- 1997
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 1998
				} -- 1998
			) -- 1998
			break -- 2000
		end -- 2000
		____cond317 = ____cond317 or ____switch317 == "memory_compression_started" -- 2000
		if ____cond317 then -- 2000
			upsertStep( -- 2002
				sessionId, -- 2002
				event.taskId, -- 2002
				event.step, -- 2002
				event.tool, -- 2002
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2002
			) -- 2002
			emitAgentSessionPatch( -- 2007
				sessionId, -- 2007
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2007
			) -- 2007
			break -- 2010
		end -- 2010
		____cond317 = ____cond317 or ____switch317 == "memory_compression_finished" -- 2010
		if ____cond317 then -- 2010
			upsertStep( -- 2012
				sessionId, -- 2012
				event.taskId, -- 2012
				event.step, -- 2012
				event.tool, -- 2012
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2012
			) -- 2012
			emitAgentSessionPatch( -- 2017
				sessionId, -- 2017
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2017
			) -- 2017
			break -- 2020
		end -- 2020
		____cond317 = ____cond317 or ____switch317 == "metrics_updated" -- 2020
		if ____cond317 then -- 2020
			do -- 2020
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2022
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2023
				break -- 2026
			end -- 2026
		end -- 2026
		____cond317 = ____cond317 or ____switch317 == "assistant_message_updated" -- 2026
		if ____cond317 then -- 2026
			do -- 2026
				upsertStep( -- 2029
					sessionId, -- 2029
					event.taskId, -- 2029
					event.step, -- 2029
					"message", -- 2029
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2029
				) -- 2029
				emitAgentSessionPatch( -- 2034
					sessionId, -- 2034
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2034
				) -- 2034
				break -- 2037
			end -- 2037
		end -- 2037
		____cond317 = ____cond317 or ____switch317 == "assistant_message_finished" -- 2037
		if ____cond317 then -- 2037
			do -- 2037
				upsertStep( -- 2040
					sessionId, -- 2040
					event.taskId, -- 2040
					event.step, -- 2040
					"message", -- 2040
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2040
				) -- 2040
				emitAgentSessionPatch( -- 2046
					sessionId, -- 2046
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2046
				) -- 2046
				break -- 2049
			end -- 2049
		end -- 2049
		____cond317 = ____cond317 or ____switch317 == "task_waiting_for_user" -- 2049
		if ____cond317 then -- 2049
			do -- 2049
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2052
				__TS__Delete(activeStopTokens, event.taskId) -- 2053
				emitAgentSessionPatch( -- 2054
					sessionId, -- 2054
					{ -- 2054
						session = getSessionItem(sessionId), -- 2055
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2056
					} -- 2056
				) -- 2056
				break -- 2058
			end -- 2058
		end -- 2058
		____cond317 = ____cond317 or ____switch317 == "task_finished" -- 2058
		if ____cond317 then -- 2058
			do -- 2058
				local session = getSessionItem(sessionId) -- 2061
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2061
					__TS__Delete(activeStopTokens, event.taskId) -- 2063
					Log( -- 2064
						"Info", -- 2064
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2064
					) -- 2064
					break -- 2065
				end -- 2065
				local ____opt_44 = activeStopTokens[event.taskId or -1] -- 2065
				local stopped = (____opt_44 and ____opt_44.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2067
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2069
				local isSubSession = (session and session.kind) == "sub" -- 2072
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2073
				if isSubSession and event.taskId ~= nil then -- 2073
					finalizingSubSessionTaskIds[event.taskId] = true -- 2075
				end -- 2075
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2077
				if event.taskId ~= nil then -- 2077
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2079
					local ____finalizeTaskSteps_50 = finalizeTaskSteps -- 2080
					local ____array_49 = __TS__SparseArrayNew( -- 2080
						sessionId, -- 2081
						event.taskId, -- 2082
						type(event.steps) == "number" and math.max( -- 2083
							0, -- 2083
							math.floor(event.steps) -- 2083
						) or nil -- 2083
					) -- 2083
					local ____event_success_48 -- 2084
					if event.success then -- 2084
						____event_success_48 = nil -- 2084
					else -- 2084
						____event_success_48 = stopped and "STOPPED" or "FAILED" -- 2084
					end -- 2084
					__TS__SparseArrayPush(____array_49, ____event_success_48) -- 2084
					____finalizeTaskSteps_50(__TS__SparseArraySpread(____array_49)) -- 2080
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2086
					if not isSubSession then -- 2086
						__TS__Delete(activeStopTokens, event.taskId) -- 2088
					end -- 2088
					emitAgentSessionPatch( -- 2090
						sessionId, -- 2090
						{ -- 2090
							session = getSessionItem(sessionId), -- 2091
							message = getMessageItem(messageId), -- 2092
							removedStepIds = removedStepIds -- 2093
						} -- 2093
					) -- 2093
				end -- 2093
				if session and session.kind == "main" then -- 2093
					flushPendingSubAgentHandoffs(session) -- 2097
				end -- 2097
				break -- 2099
			end -- 2099
		end -- 2099
	until true -- 2099
end -- 2099
function ____exports.createSession(projectRoot, title) -- 2104
	if title == nil then -- 2104
		title = "" -- 2104
	end -- 2104
	local storage = requireAgentStorage() -- 2105
	if not storage.success then -- 2105
		return storage -- 2106
	end -- 2106
	if not isValidProjectRoot(projectRoot) then -- 2106
		return {success = false, message = "invalid projectRoot"} -- 2108
	end -- 2108
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2110
	if row then -- 2110
		return { -- 2119
			success = true, -- 2119
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2119
		} -- 2119
	end -- 2119
	local t = now() -- 2121
	DB:exec( -- 2122
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2122
		{ -- 2125
			projectRoot, -- 2125
			title ~= "" and title or Path:getFilename(projectRoot), -- 2125
			t, -- 2125
			t -- 2125
		} -- 2125
	) -- 2125
	local sessionId = getLastInsertRowId() -- 2127
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2128
	local session = getSessionItem(sessionId) -- 2129
	if not session then -- 2129
		return {success = false, message = "failed to create session"} -- 2131
	end -- 2131
	return {success = true, session = session} -- 2133
end -- 2104
function ____exports.createSubSession(parentSessionId, title) -- 2136
	if title == nil then -- 2136
		title = "" -- 2136
	end -- 2136
	local storage = requireAgentStorage() -- 2137
	if not storage.success then -- 2137
		return storage -- 2138
	end -- 2138
	local parent = getSessionItem(parentSessionId) -- 2139
	if not parent then -- 2139
		return {success = false, message = "parent session not found"} -- 2141
	end -- 2141
	local rootId = getSessionRootId(parent) -- 2143
	local t = now() -- 2144
	DB:exec( -- 2145
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2145
		{ -- 2148
			parent.projectRoot, -- 2148
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2148
			rootId, -- 2148
			parent.id, -- 2148
			t, -- 2148
			t -- 2148
		} -- 2148
	) -- 2148
	local sessionId = getLastInsertRowId() -- 2150
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2151
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2152
	local session = getSessionItem(sessionId) -- 2153
	if not session then -- 2153
		return {success = false, message = "failed to create sub session"} -- 2155
	end -- 2155
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2157
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2158
	subStorage:writeMemory(parentStorage:readMemory()) -- 2159
	return {success = true, session = session} -- 2160
end -- 2136
function spawnSubAgentSession(request) -- 2163
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2163
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2176
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2177
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2178
		if normalizedPrompt == "" then -- 2178
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2180
		end -- 2180
		if normalizedPrompt == "" then -- 2180
			local ____Log_56 = Log -- 2187
			local ____temp_53 = #normalizedTitle -- 2187
			local ____temp_54 = #rawPrompt -- 2187
			local ____temp_55 = #toStr(request.expectedOutput) -- 2187
			local ____opt_51 = request.filesHint -- 2187
			____Log_56( -- 2187
				"Warn", -- 2187
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_53)) .. " raw_prompt_len=") .. tostring(____temp_54)) .. " expected_len=") .. tostring(____temp_55)) .. " files_hint_count=") .. tostring(____opt_51 and #____opt_51 or 0) -- 2187
			) -- 2187
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2187
		end -- 2187
		Log( -- 2190
			"Info", -- 2190
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2190
		) -- 2190
		local parentSessionId = request.parentSessionId -- 2191
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2191
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2193
			if not fallbackParent then -- 2193
				local createdMain = ____exports.createSession(request.projectRoot) -- 2195
				if createdMain.success then -- 2195
					fallbackParent = createdMain.session -- 2197
				end -- 2197
			end -- 2197
			if fallbackParent then -- 2197
				Log( -- 2201
					"Warn", -- 2201
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2201
				) -- 2201
				parentSessionId = fallbackParent.id -- 2202
			end -- 2202
		end -- 2202
		local parentSession = getSessionItem(parentSessionId) -- 2205
		if not parentSession then -- 2205
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2205
		end -- 2205
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2209
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2209
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2209
		end -- 2209
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2213
		if not created.success then -- 2213
			return ____awaiter_resolve(nil, created) -- 2213
		end -- 2213
		writeSpawnInfo( -- 2217
			created.session.projectRoot, -- 2217
			created.session.memoryScope, -- 2217
			{ -- 2217
				sessionId = created.session.id, -- 2218
				rootSessionId = created.session.rootSessionId, -- 2219
				parentSessionId = created.session.parentSessionId, -- 2220
				title = created.session.title, -- 2221
				prompt = normalizedPrompt, -- 2222
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2223
				expectedOutput = request.expectedOutput or "", -- 2224
				filesHint = request.filesHint or ({}), -- 2225
				status = "RUNNING", -- 2226
				success = false, -- 2227
				resultFilePath = "", -- 2228
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2229
				sourceTaskId = 0, -- 2230
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2231
				createdAtTs = created.session.createdAt, -- 2232
				finishedAt = "", -- 2233
				finishedAtTs = 0 -- 2234
			} -- 2234
		) -- 2234
		local sent = ____exports.sendPrompt( -- 2236
			created.session.id, -- 2236
			normalizedPrompt, -- 2236
			request.disabledAgentTools, -- 2236
			nil, -- 2236
			nil, -- 2236
			request.llmConfig -- 2236
		) -- 2236
		if not sent.success then -- 2236
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2236
		end -- 2236
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2236
	end) -- 2236
end -- 2236
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2356
	local rootSession = getRootSessionItem(session.id) -- 2357
	if not rootSession then -- 2357
		return -- 2358
	end -- 2358
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2359
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2360
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2361
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2362
	local queueResult = writePendingHandoff( -- 2363
		rootSession.projectRoot, -- 2363
		rootSession.memoryScope, -- 2363
		{ -- 2363
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2364
			sourceSessionId = session.id, -- 2365
			sourceTitle = session.title, -- 2366
			sourceTaskId = taskId, -- 2367
			message = summary, -- 2368
			prompt = result.prompt, -- 2369
			goal = result.goal, -- 2370
			expectedOutput = result.expectedOutput or "", -- 2371
			filesHint = result.filesHint or ({}), -- 2372
			success = result.success, -- 2373
			resultFilePath = result.resultFilePath, -- 2374
			artifactDir = result.artifactDir, -- 2375
			finishedAt = result.finishedAt, -- 2376
			changeSet = changeSet, -- 2377
			handoffEvidence = result.handoffEvidence, -- 2378
			memoryEntry = result.memoryEntry, -- 2379
			completion = result.completion, -- 2380
			createdAt = createdAt -- 2381
		} -- 2381
	) -- 2381
	if not queueResult then -- 2381
		Log( -- 2384
			"Warn", -- 2384
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2384
		) -- 2384
		return -- 2385
	end -- 2385
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2385
		addTaskReference(rootSession.currentTaskId, taskId) -- 2388
	end -- 2388
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2388
		flushPendingSubAgentHandoffs(rootSession) -- 2391
	end -- 2391
end -- 2391
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2395
	if forceHandoff == nil then -- 2395
		forceHandoff = false -- 2401
	end -- 2401
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2401
		local rootSessionId = getSessionRootId(session) -- 2403
		local rootSession = getRootSessionItem(session.id) -- 2404
		if not rootSession then -- 2404
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2404
		end -- 2404
		local spawnInfo = getSessionSpawnInfo(session) -- 2408
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2409
		local finishedAtTs = now() -- 2410
		local resultText = sanitizeUTF8(message) -- 2411
		local changeSet = getTaskChangeSetSummary(taskId) -- 2412
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2413
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2414
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2418
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2418
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2420
		end -- 2420
		local completed = success and completionReport.outcome == "completed" -- 2428
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2429
		local record = { -- 2432
			sessionId = session.id, -- 2433
			rootSessionId = rootSessionId, -- 2434
			parentSessionId = session.parentSessionId, -- 2435
			title = session.title, -- 2436
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2437
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2438
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2439
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2440
			status = recordStatus, -- 2441
			success = completed, -- 2442
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2443
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2444
			sourceTaskId = taskId, -- 2445
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2446
			finishedAt = finishedAt, -- 2447
			createdAtTs = session.createdAt, -- 2448
			finishedAtTs = finishedAtTs, -- 2449
			changeSet = changeSet, -- 2450
			handoffEvidence = handoffEvidence, -- 2451
			completion = completionReport -- 2452
		} -- 2452
		local ____record_success_73 -- 2454
		if record.success then -- 2454
			____record_success_73 = buildStructuredSubAgentMemoryEntry(record) -- 2454
		else -- 2454
			____record_success_73 = nil -- 2454
		end -- 2454
		record.memoryEntry = ____record_success_73 -- 2454
		if not writeSubAgentResultFile(session, record, resultText) then -- 2454
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2454
		end -- 2454
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2454
			sessionId = record.sessionId, -- 2459
			rootSessionId = record.rootSessionId, -- 2460
			parentSessionId = record.parentSessionId, -- 2461
			title = record.title, -- 2462
			prompt = record.prompt, -- 2463
			goal = record.goal, -- 2464
			expectedOutput = record.expectedOutput or "", -- 2465
			filesHint = record.filesHint or ({}), -- 2466
			status = record.status, -- 2467
			success = record.success, -- 2468
			resultFilePath = record.resultFilePath, -- 2469
			artifactDir = record.artifactDir, -- 2470
			sourceTaskId = record.sourceTaskId, -- 2471
			createdAt = record.createdAt, -- 2472
			finishedAt = record.finishedAt, -- 2473
			createdAtTs = record.createdAtTs, -- 2474
			finishedAtTs = record.finishedAtTs, -- 2475
			changeSet = record.changeSet, -- 2476
			handoffEvidence = record.handoffEvidence, -- 2477
			memoryEntry = record.memoryEntry, -- 2478
			memoryEntryError = record.memoryEntryError, -- 2479
			completion = record.completion -- 2480
		}) then -- 2480
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2480
		end -- 2480
		if success or forceHandoff then -- 2480
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2485
			deleteSessionRecords(session.id, true) -- 2486
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2487
		end -- 2487
		return ____awaiter_resolve(nil, {success = true}) -- 2487
	end) -- 2487
end -- 2487
function stopClearedSubSession(session, taskId) -- 2492
	local spawnInfo = getSessionSpawnInfo(session) -- 2493
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2494
	local rootSessionId = getSessionRootId(session) -- 2495
	Tools.setTaskStatus(taskId, "STOPPED") -- 2496
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2497
	if not writeSpawnInfo( -- 2497
		session.projectRoot, -- 2498
		session.memoryScope, -- 2498
		{ -- 2498
			sessionId = session.id, -- 2499
			rootSessionId = rootSessionId, -- 2500
			parentSessionId = session.parentSessionId, -- 2501
			title = session.title, -- 2502
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2503
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2504
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2505
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2506
			status = "STOPPED", -- 2507
			success = false, -- 2508
			cleared = true, -- 2509
			resultFilePath = "", -- 2510
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2511
			sourceTaskId = taskId, -- 2512
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2513
			finishedAt = finishedAt, -- 2514
			createdAtTs = session.createdAt, -- 2515
			finishedAtTs = now() -- 2516
		} -- 2516
	) then -- 2516
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2518
	end -- 2518
	deleteSessionRecords(session.id, true) -- 2520
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2521
	return {success = true} -- 2522
end -- 2522
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2525
	local session = getSessionItem(sessionId) -- 2526
	if not session then -- 2526
		return {success = false, message = "session not found"} -- 2528
	end -- 2528
	if getPendingQuestionnaire(sessionId) then -- 2528
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2530
	end -- 2530
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2530
		return {success = false, message = "session task is finalizing"} -- 2532
	end -- 2532
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2532
		return {success = false, message = "session task is still running"} -- 2535
	end -- 2535
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2537
	if normalizedPrompt == "" and session.kind == "sub" then -- 2537
		local spawnInfo = getSessionSpawnInfo(session) -- 2539
		if spawnInfo then -- 2539
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2541
			if normalizedPrompt == "" then -- 2541
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2543
			end -- 2543
		end -- 2543
	end -- 2543
	if normalizedPrompt == "" then -- 2543
		return {success = false, message = "prompt is empty"} -- 2552
	end -- 2552
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2554
	if session.workMode ~= nextWorkMode then -- 2554
		DB:exec( -- 2556
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2556
			{ -- 2556
				nextWorkMode, -- 2556
				now(), -- 2556
				session.id -- 2556
			} -- 2556
		) -- 2556
		session.workMode = nextWorkMode -- 2557
	end -- 2557
	return startPromptTask( -- 2559
		session, -- 2559
		normalizedPrompt, -- 2559
		nil, -- 2559
		normalizeDisabledAgentTools(disabledAgentTools), -- 2559
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2559
	) -- 2559
end -- 2525
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2612
	if disabledAgentTools == nil then -- 2612
		disabledAgentTools = {} -- 2616
	end -- 2616
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2619
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2620
	if not llmConfigRes.success then -- 2620
		return {success = false, message = llmConfigRes.message} -- 2624
	end -- 2624
	local llmConfig = llmConfigRes.config -- 2626
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2627
	if not llmConfigValidation.success then -- 2627
		return llmConfigValidation -- 2629
	end -- 2629
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2631
	if not taskRes.success then -- 2631
		return {success = false, message = taskRes.message} -- 2634
	end -- 2634
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2634
		removeContinuableTaskSummary(session) -- 2636
	end -- 2636
	local taskId = taskRes.taskId -- 2638
	local ____temp_94 -- 2639
	if (options and options.existingTaskId) == nil then -- 2639
		____temp_94 = session.currentTaskId -- 2639
	else -- 2639
		____temp_94 = nil -- 2639
	end -- 2639
	local previousTaskId = ____temp_94 -- 2639
	local useChineseResponse = getDefaultUseChineseResponse() -- 2640
	if existingUserMessageId ~= nil then -- 2640
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2642
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2642
		insertMessage( -- 2644
			session.id, -- 2644
			"user", -- 2644
			normalizedPrompt, -- 2644
			taskId, -- 2644
			options and options.displayContent -- 2644
		) -- 2644
	end -- 2644
	local stopToken = {stopped = false} -- 2646
	activeStopTokens[taskId] = stopToken -- 2647
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2648
	if previousTaskId and previousTaskId ~= taskId then -- 2648
		cleanupTaskHeavyData(previousTaskId) -- 2650
	end -- 2650
	local ____runCodingAgent_123 = runCodingAgent -- 2652
	local ____normalizedPrompt_116 = normalizedPrompt -- 2653
	local ____temp_117 = options and options.resumeConversation -- 2654
	local ____temp_118 = (options and options.existingTaskId) ~= nil -- 2655
	local ____temp_119 = options and options.initialStep -- 2656
	local ____temp_120 = options and options.initialAgentStepCount -- 2657
	local ____temp_111 -- 2658
	if (options and options.existingTaskId) ~= nil then -- 2658
		____temp_111 = getInitialTokenUsage(session) -- 2658
	else -- 2658
		____temp_111 = nil -- 2658
	end -- 2658
	____runCodingAgent_123( -- 2652
		{ -- 2652
			prompt = ____normalizedPrompt_116, -- 2653
			resumeConversation = ____temp_117, -- 2654
			resumeTask = ____temp_118, -- 2655
			initialStep = ____temp_119, -- 2656
			initialAgentStepCount = ____temp_120, -- 2657
			initialTokenUsage = ____temp_111, -- 2658
			workDir = session.projectRoot, -- 2659
			useChineseResponse = useChineseResponse, -- 2660
			taskId = taskId, -- 2661
			sessionId = session.id, -- 2662
			memoryScope = session.memoryScope, -- 2663
			role = session.kind, -- 2664
			maxSteps = options and options.maxSteps, -- 2665
			disabledAgentTools = disabledAgentTools, -- 2666
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2667
			llmConfig = llmConfig, -- 2668
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2669
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2672
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2675
			stopToken = stopToken, -- 2676
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2677
		}, -- 2677
		function(result) -- 2678
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2678
				local nextSession = getSessionItem(session.id) -- 2679
				if nextSession and nextSession.kind == "sub" then -- 2679
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2679
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2682
						if not stopped.success then -- 2682
							Log( -- 2684
								"Warn", -- 2684
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2684
							) -- 2684
							emitAgentSessionPatch( -- 2685
								session.id, -- 2685
								{session = getSessionItem(session.id)} -- 2685
							) -- 2685
						end -- 2685
						__TS__Delete(activeStopTokens, taskId) -- 2689
						return ____awaiter_resolve(nil) -- 2689
					end -- 2689
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2692
					emitAgentSessionPatch( -- 2693
						session.id, -- 2693
						{session = getSessionItem(session.id)} -- 2693
					) -- 2693
					local finalized = __TS__Await(finalizeSubSession( -- 2696
						nextSession, -- 2697
						taskId, -- 2698
						result.success, -- 2699
						result.message, -- 2700
						result.completion, -- 2701
						(options and options.forceSubAgentHandoff) == true -- 2702
					)) -- 2702
					if not finalized.success then -- 2702
						Log( -- 2705
							"Warn", -- 2705
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2705
						) -- 2705
					end -- 2705
					local finalizedSession = getSessionItem(session.id) -- 2707
					if finalizedSession then -- 2707
						local stopped = stopToken.stopped == true -- 2709
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2710
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2713
						emitAgentSessionPatch( -- 2714
							session.id, -- 2714
							{session = getSessionItem(session.id)} -- 2714
						) -- 2714
					end -- 2714
					__TS__Delete(activeStopTokens, taskId) -- 2718
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2719
				end -- 2719
				local fallbackSession = getSessionItem(session.id) -- 2721
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2721
					applyEvent(session.id, { -- 2727
						type = "task_finished", -- 2728
						sessionId = session.id, -- 2729
						taskId = result.taskId, -- 2730
						success = false, -- 2731
						message = result.message, -- 2732
						steps = result.steps -- 2733
					}) -- 2733
				end -- 2733
			end) -- 2733
		end -- 2678
	) -- 2678
	return {success = true, sessionId = session.id, taskId = taskId} -- 2737
end -- 2737
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2889
	local lines = {} -- 2890
	do -- 2890
		local i = 0 -- 2891
		while i < #questionnaire.schema.questions do -- 2891
			local question = questionnaire.schema.questions[i + 1] -- 2892
			local answer = __TS__ArrayFind( -- 2893
				answers, -- 2893
				function(____, item) return item.questionId == question.id end -- 2893
			) -- 2893
			local answerText = "已跳过" -- 2894
			if answer and answer.status == "answered" then -- 2894
				local parts = {} -- 2896
				do -- 2896
					local j = 0 -- 2897
					while j < #(answer.selectedOptionIds or ({})) do -- 2897
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2898
						local option = __TS__ArrayFind( -- 2899
							question.options or ({}), -- 2899
							function(____, item) return item.id == optionId end -- 2899
						) -- 2899
						if option then -- 2899
							parts[#parts + 1] = option.label -- 2900
						end -- 2900
						j = j + 1 -- 2897
					end -- 2897
				end -- 2897
				if answer.otherText then -- 2897
					parts[#parts + 1] = answer.otherText -- 2902
				end -- 2902
				if answer.text then -- 2902
					parts[#parts + 1] = answer.text -- 2903
				end -- 2903
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2904
			end -- 2904
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2906
			i = i + 1 -- 2891
		end -- 2891
	end -- 2891
	return table.concat(lines, "\n\n") -- 2908
end -- 2908
function ____exports.listRunningSubAgents(request) -- 3152
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3152
		local session = getSessionItem(request.sessionId) -- 3160
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3160
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3162
		end -- 3162
		if not session then -- 3162
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3162
		end -- 3162
		local rootSession = getRootSessionItem(session.id) -- 3167
		if not rootSession then -- 3167
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3167
		end -- 3167
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3171
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3172
		local limit = math.max( -- 3173
			1, -- 3173
			math.floor(tonumber(request.limit) or 5) -- 3173
		) -- 3173
		local offset = math.max( -- 3174
			0, -- 3174
			math.floor(tonumber(request.offset) or 0) -- 3174
		) -- 3174
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3175
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3176
		local runningSessions = {} -- 3183
		do -- 3183
			local i = 0 -- 3184
			while i < #rows do -- 3184
				do -- 3184
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3185
					if current.currentTaskStatus ~= "RUNNING" then -- 3185
						goto __continue517 -- 3187
					end -- 3187
					local spawnInfo = getSessionSpawnInfo(current) -- 3189
					runningSessions[#runningSessions + 1] = { -- 3190
						sessionId = current.id, -- 3191
						title = current.title, -- 3192
						parentSessionId = current.parentSessionId, -- 3193
						rootSessionId = current.rootSessionId, -- 3194
						status = "RUNNING", -- 3195
						currentTaskId = current.currentTaskId, -- 3196
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3197
						goal = spawnInfo and spawnInfo.goal, -- 3198
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3199
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3200
						createdAt = current.createdAt, -- 3201
						updatedAt = current.updatedAt -- 3202
					} -- 3202
				end -- 3202
				::__continue517:: -- 3202
				i = i + 1 -- 3184
			end -- 3184
		end -- 3184
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3205
		local completedSessions = __TS__ArrayMap( -- 3206
			completedRecords, -- 3206
			function(____, record) return { -- 3206
				sessionId = record.sessionId, -- 3207
				title = record.title, -- 3208
				parentSessionId = record.parentSessionId, -- 3209
				rootSessionId = record.rootSessionId, -- 3210
				status = record.status, -- 3211
				goal = record.goal, -- 3212
				expectedOutput = record.expectedOutput, -- 3213
				filesHint = record.filesHint, -- 3214
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3215
				success = record.success, -- 3216
				cleared = record.cleared, -- 3217
				resultFilePath = record.resultFilePath, -- 3218
				artifactDir = record.artifactDir, -- 3219
				finishedAt = record.finishedAt, -- 3220
				createdAt = record.createdAtTs, -- 3221
				updatedAt = record.finishedAtTs -- 3222
			} end -- 3222
		) -- 3222
		local merged = {} -- 3224
		if status == "running" then -- 3224
			merged = runningSessions -- 3226
		elseif status == "done" then -- 3226
			merged = __TS__ArrayFilter( -- 3228
				completedSessions, -- 3228
				function(____, item) return item.status == "DONE" end -- 3228
			) -- 3228
		elseif status == "failed" then -- 3228
			merged = __TS__ArrayFilter( -- 3230
				completedSessions, -- 3230
				function(____, item) return item.status == "FAILED" end -- 3230
			) -- 3230
		elseif status == "stopped" then -- 3230
			merged = __TS__ArrayFilter( -- 3232
				completedSessions, -- 3232
				function(____, item) return item.status == "STOPPED" end -- 3232
			) -- 3232
		elseif status == "all" then -- 3232
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3234
		else -- 3234
			local runningKeys = {} -- 3236
			do -- 3236
				local i = 0 -- 3237
				while i < #runningSessions do -- 3237
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3238
					i = i + 1 -- 3237
				end -- 3237
			end -- 3237
			local latestCompletedByKey = {} -- 3240
			do -- 3240
				local i = 0 -- 3241
				while i < #completedSessions do -- 3241
					do -- 3241
						local item = completedSessions[i + 1] -- 3242
						local key = getSubAgentDisplayKey(item) -- 3243
						if runningKeys[key] then -- 3243
							goto __continue532 -- 3245
						end -- 3245
						local current = latestCompletedByKey[key] -- 3247
						if not current or item.updatedAt > current.updatedAt then -- 3247
							latestCompletedByKey[key] = item -- 3249
						end -- 3249
					end -- 3249
					::__continue532:: -- 3249
					i = i + 1 -- 3241
				end -- 3241
			end -- 3241
			local latestCompleted = {} -- 3252
			for ____, item in pairs(latestCompletedByKey) do -- 3253
				latestCompleted[#latestCompleted + 1] = item -- 3254
			end -- 3254
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3256
		end -- 3256
		if query ~= "" then -- 3256
			merged = __TS__ArrayFilter( -- 3259
				merged, -- 3259
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3259
			) -- 3259
		end -- 3259
		__TS__ArraySort( -- 3265
			merged, -- 3265
			function(____, a, b) -- 3265
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3265
					return -1 -- 3266
				end -- 3266
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3266
					return 1 -- 3267
				end -- 3267
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3267
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3269
				end -- 3269
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3271
			end -- 3265
		) -- 3265
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3273
		return ____awaiter_resolve(nil, { -- 3273
			success = true, -- 3275
			rootSessionId = rootSession.id, -- 3276
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3277
			status = status, -- 3278
			limit = limit, -- 3279
			offset = offset, -- 3280
			hasMore = offset + limit < #merged, -- 3281
			sessions = paged -- 3282
		}) -- 3282
	end) -- 3282
end -- 3152
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 270
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 271
SPAWN_INFO_FILE = "SPAWN.json" -- 272
RESULT_FILE = "RESULT.md" -- 273
PENDING_HANDOFF_DIR = "pending-handoffs" -- 274
MAX_CONCURRENT_SUB_AGENTS = 4 -- 275
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 276
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 277
activeStopTokens = {} -- 327
finalizingSubSessionTaskIds = {} -- 328
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 329
now = function() return os.time() end -- 330
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 978
	if projectRoot == oldRoot then -- 978
		return newRoot -- 980
	end -- 980
	for ____, separator in ipairs({"/", "\\"}) do -- 982
		local prefix = oldRoot .. separator -- 983
		if __TS__StringStartsWith(projectRoot, prefix) then -- 983
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 985
		end -- 985
	end -- 985
	return nil -- 988
end -- 978
local function clearSessionAfterMessage(sessionId, message) -- 1503
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1504
	local removedStepIds = {} -- 1512
	do -- 1512
		local i = 0 -- 1513
		while i < #removedStepRows do -- 1513
			local row = removedStepRows[i + 1] -- 1514
			if type(row[1]) == "number" then -- 1514
				removedStepIds[#removedStepIds + 1] = row[1] -- 1516
			end -- 1516
			i = i + 1 -- 1513
		end -- 1513
	end -- 1513
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1519
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1527
	return removedStepIds -- 1532
end -- 1503
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1535
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1536
	local persisted = storage:readSessionState() -- 1537
	local userIndex = -1 -- 1538
	do -- 1538
		local i = #persisted.messages - 1 -- 1539
		while i >= 0 do -- 1539
			if persisted.messages[i + 1].role == "user" then -- 1539
				userIndex = i -- 1541
				break -- 1542
			end -- 1542
			i = i - 1 -- 1539
		end -- 1539
	end -- 1539
	if userIndex < 0 then -- 1539
		return -- 1545
	end -- 1545
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1546
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1547
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1548
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1553
end -- 1535
local function listCurrentTaskCheckpoints(sessionId) -- 1565
	local session = getSessionItem(sessionId) -- 1566
	local taskId = session and session.currentTaskId -- 1567
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1568
end -- 1565
local function getAgentStepCount(sessionId, taskId) -- 1675
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1676
		sessionId, -- 1681
		taskId, -- 1682
		"compress_memory", -- 1683
		"merge_memory", -- 1684
		"sub_agent_handoff", -- 1685
		"questionnaire_answer", -- 1686
		"message" -- 1687
	}) -- 1687
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1690
end -- 1675
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1693
	if status == nil then -- 1693
		status = "DONE" -- 1701
	end -- 1701
	local step = getNextStepNumber(sessionId, taskId) -- 1703
	upsertStep( -- 1704
		sessionId, -- 1704
		taskId, -- 1704
		step, -- 1704
		tool, -- 1704
		{status = status, reason = reason, params = params, result = result} -- 1704
	) -- 1704
	return getStepItem(sessionId, taskId, step) -- 1710
end -- 1693
local function sanitizeStoredSteps(sessionId) -- 1777
	DB:exec( -- 1778
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1778
		{ -- 1796
			now(), -- 1796
			sessionId -- 1796
		} -- 1796
	) -- 1796
end -- 1777
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2248
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2248
		return {success = false, message = "invalid projectRoot"} -- 2250
	end -- 2250
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2252
	for ____, row in ipairs(rows) do -- 2253
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2254
		if sessionId > 0 then -- 2254
			deleteSessionRecords(sessionId) -- 2256
		end -- 2256
	end -- 2256
	return {success = true, deleted = #rows} -- 2259
end -- 2248
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2262
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2262
		return {success = false, message = "invalid projectRoot"} -- 2264
	end -- 2264
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2266
	local renamed = 0 -- 2267
	for ____, row in ipairs(rows) do -- 2268
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2269
		local projectRoot = toStr(row[2]) -- 2270
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2271
		if sessionId > 0 and nextProjectRoot then -- 2271
			DB:exec( -- 2273
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2273
				{ -- 2275
					nextProjectRoot, -- 2275
					Path:getFilename(nextProjectRoot), -- 2275
					now(), -- 2275
					sessionId -- 2275
				} -- 2275
			) -- 2275
			renamed = renamed + 1 -- 2277
		end -- 2277
	end -- 2277
	return {success = true, renamed = renamed} -- 2280
end -- 2262
function ____exports.getSession(sessionId, view) -- 2283
	local session = getSessionItem(sessionId) -- 2284
	if not session then -- 2284
		return {success = false, message = "session not found"} -- 2286
	end -- 2286
	local restored = restorePendingQuestionnaireState(session) -- 2288
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2289
	local relatedSessions = listRelatedSessions(sessionId) -- 2290
	sanitizeStoredSteps(sessionId) -- 2291
	local firstMessageId = 0 -- 2292
	local hasEarlierMessages = false -- 2293
	if view then -- 2293
		local limit = math.max( -- 2295
			1, -- 2295
			math.min( -- 2295
				1000, -- 2295
				math.floor(view.recentRounds) -- 2295
			) -- 2295
		) -- 2295
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2296
		if #requests > limit then -- 2296
			firstMessageId = requests[limit][1] -- 2301
			hasEarlierMessages = true -- 2302
		end -- 2302
	end -- 2302
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2305
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2312
	local ____relatedSessions_62 = relatedSessions -- 2324
	local ____temp_61 -- 2325
	if normalizedSession.kind == "sub" then -- 2325
		____temp_61 = getSessionSpawnInfo(normalizedSession) -- 2325
	else -- 2325
		____temp_61 = nil -- 2325
	end -- 2325
	return { -- 2321
		success = true, -- 2322
		session = normalizedSession, -- 2323
		relatedSessions = ____relatedSessions_62, -- 2324
		spawnInfo = ____temp_61, -- 2325
		messages = __TS__ArrayMap( -- 2326
			messages, -- 2326
			function(____, row) return rowToMessage(row) end -- 2326
		), -- 2326
		hasEarlierMessages = hasEarlierMessages, -- 2327
		steps = __TS__ArrayMap( -- 2328
			steps, -- 2328
			function(____, row) return rowToStep(row) end -- 2328
		), -- 2328
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2329
		pendingQuestionnaire = restored.questionnaire, -- 2330
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2331
	} -- 2331
end -- 2283
function ____exports.setWorkMode(sessionId, workMode) -- 2336
	local session = getSessionItem(sessionId) -- 2337
	if not session then -- 2337
		return {success = false, message = "session not found"} -- 2338
	end -- 2338
	if session.kind ~= "main" then -- 2338
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2339
	end -- 2339
	if workMode ~= "code" and workMode ~= "plan" then -- 2339
		return {success = false, message = "invalid work mode"} -- 2340
	end -- 2340
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2341
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2341
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2343
	end -- 2343
	if getPendingQuestionnaire(sessionId) then -- 2343
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2346
	end -- 2346
	if normalizedSession.workMode ~= workMode then -- 2346
		DB:exec( -- 2349
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2349
			{ -- 2349
				workMode, -- 2349
				now(), -- 2349
				sessionId -- 2349
			} -- 2349
		) -- 2349
	end -- 2349
	local updated = getSessionItem(sessionId) -- 2351
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2352
	return { -- 2353
		success = true, -- 2353
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2353
	} -- 2353
end -- 2336
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2562
	local session = getSessionItem(sessionId) -- 2563
	if not session then -- 2563
		return {success = false, message = "session not found"} -- 2565
	end -- 2565
	if getPendingQuestionnaire(sessionId) then -- 2565
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2567
	end -- 2567
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2567
		return {success = false, message = "session task is finalizing"} -- 2569
	end -- 2569
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2569
		return {success = false, message = "session task is still stopping"} -- 2572
	end -- 2572
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2572
		return {success = false, message = "session task is not continuable"} -- 2575
	end -- 2575
	if session.currentTaskId == nil then -- 2575
		return {success = false, message = "session task not found"} -- 2578
	end -- 2578
	local taskId = session.currentTaskId -- 2580
	return startPromptTask( -- 2581
		session, -- 2582
		"", -- 2583
		nil, -- 2584
		normalizeDisabledAgentTools(disabledAgentTools), -- 2585
		{ -- 2586
			workMode = session.workMode, -- 2587
			persistUserMessage = false, -- 2588
			resumeConversation = true, -- 2589
			existingTaskId = taskId, -- 2590
			initialStep = math.max( -- 2591
				0, -- 2591
				getNextStepNumber(session.id, taskId) - 1 -- 2591
			), -- 2591
			initialAgentStepCount = getAgentStepCount(session.id, taskId), -- 2592
			llmConfigId = llmConfigId -- 2593
		} -- 2593
	) -- 2593
end -- 2562
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2740
	local session = getSessionItem(sessionId) -- 2741
	if not session then -- 2741
		return {success = false, message = "session not found"} -- 2743
	end -- 2743
	if session.kind ~= "sub" then -- 2743
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2746
	end -- 2746
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2746
		return {success = false, message = "session task is finalizing"} -- 2749
	end -- 2749
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2751
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2751
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2756
	end -- 2756
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2756
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2759
	end -- 2759
	local disabledAgentTools = __TS__ArrayFilter( -- 2761
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2761
		function(____, tool) return tool ~= "finish" end -- 2762
	) -- 2762
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2763
	return startPromptTask( -- 2766
		session, -- 2766
		prompt, -- 2766
		nil, -- 2766
		disabledAgentTools, -- 2766
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2766
	) -- 2766
end -- 2740
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2773
	local session = getSessionItem(sessionId) -- 2774
	if not session then -- 2774
		return {success = false, message = "session not found"} -- 2776
	end -- 2776
	if getPendingQuestionnaire(sessionId) then -- 2776
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2778
	end -- 2778
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2778
		return {success = false, message = "session task is finalizing"} -- 2780
	end -- 2780
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2780
		return {success = false, message = "session task is still running"} -- 2783
	end -- 2783
	local message = getMessageItem(messageId) -- 2785
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2785
		return {success = false, message = "message not found"} -- 2787
	end -- 2787
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2789
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2795
	if latestUserMessageId ~= messageId then -- 2795
		return {success = false, message = "only the latest user prompt can be edited"} -- 2797
	end -- 2797
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2799
	if normalizedPrompt == "" then -- 2799
		return {success = false, message = "prompt is empty"} -- 2801
	end -- 2801
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2803
	if session.workMode ~= nextWorkMode then -- 2803
		DB:exec( -- 2805
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2805
			{ -- 2805
				nextWorkMode, -- 2805
				now(), -- 2805
				session.id -- 2805
			} -- 2805
		) -- 2805
		session.workMode = nextWorkMode -- 2806
	end -- 2806
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2808
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2809
	local result = startPromptTask( -- 2810
		session, -- 2810
		normalizedPrompt, -- 2810
		messageId, -- 2810
		normalizeDisabledAgentTools(disabledAgentTools), -- 2810
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2810
	) -- 2810
	if result.success and #removedStepIds > 0 then -- 2810
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2812
	end -- 2812
	return result -- 2814
end -- 2773
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2819
	if status == "dismissed" then -- 2819
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2825
	end -- 2825
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2827
end -- 2819
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2830
	if status == "dismissed" then -- 2830
		return { -- 2836
			success = true, -- 2837
			status = "dismissed", -- 2838
			source = "user", -- 2839
			questionnaireId = questionnaire.id, -- 2840
			title = questionnaire.schema.title, -- 2841
			answers = {}, -- 2842
			responses = {}, -- 2843
			displayText = "用户关闭了调查问卷，未作答。", -- 2844
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2845
		} -- 2845
	end -- 2845
	local responses = {} -- 2848
	do -- 2848
		local i = 0 -- 2849
		while i < #questionnaire.schema.questions do -- 2849
			do -- 2849
				local question = questionnaire.schema.questions[i + 1] -- 2850
				local answer = __TS__ArrayFind( -- 2851
					answers, -- 2851
					function(____, item) return item.questionId == question.id end -- 2851
				) -- 2851
				if not answer or answer.status == "skipped" then -- 2851
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2853
					goto __continue443 -- 2858
				end -- 2858
				local selectedOptionLabels = {} -- 2860
				do -- 2860
					local j = 0 -- 2861
					while j < #(answer.selectedOptionIds or ({})) do -- 2861
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2862
						local option = __TS__ArrayFind( -- 2863
							question.options or ({}), -- 2863
							function(____, item) return item.id == optionId end -- 2863
						) -- 2863
						if option then -- 2863
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2864
						end -- 2864
						j = j + 1 -- 2861
					end -- 2861
				end -- 2861
				responses[#responses + 1] = { -- 2866
					questionId = question.id, -- 2867
					prompt = question.prompt, -- 2868
					status = "answered", -- 2869
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2870
					selectedOptionLabels = selectedOptionLabels, -- 2871
					otherText = answer.otherText, -- 2872
					text = answer.text -- 2873
				} -- 2873
			end -- 2873
			::__continue443:: -- 2873
			i = i + 1 -- 2849
		end -- 2849
	end -- 2849
	return { -- 2876
		success = true, -- 2877
		status = "answered", -- 2878
		source = "user", -- 2879
		questionnaireId = questionnaire.id, -- 2880
		title = questionnaire.schema.title, -- 2881
		answers = answers, -- 2882
		responses = responses, -- 2883
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2884
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2885
	} -- 2885
end -- 2830
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2911
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2917
	local persisted = storage:readSessionState() -- 2918
	local messages = __TS__ArraySlice(persisted.messages) -- 2919
	local toolResultIndex = -1 -- 2920
	local existingResult -- 2921
	do -- 2921
		local i = #messages - 1 -- 2922
		while i >= 0 do -- 2922
			do -- 2922
				local message = messages[i + 1] -- 2923
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2923
					goto __continue463 -- 2924
				end -- 2924
				local decoded = safeJsonDecode(message.content) -- 2925
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2925
					goto __continue463 -- 2926
				end -- 2926
				local row = decoded -- 2927
				if row.questionnaireId ~= questionnaire.id then -- 2927
					goto __continue463 -- 2928
				end -- 2928
				toolResultIndex = i -- 2929
				existingResult = row -- 2930
				break -- 2931
			end -- 2931
			::__continue463:: -- 2931
			i = i - 1 -- 2922
		end -- 2922
	end -- 2922
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2933
	local guidance = {} -- 2934
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2934
		guidance[#guidance + 1] = existingResult.guidance -- 2936
	end -- 2936
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2936
		guidance[#guidance + 1] = result.guidance -- 2939
	end -- 2939
	result.guidance = table.concat(guidance, "\n") -- 2941
	if toolResultIndex < 0 then -- 2941
		messages[#messages + 1] = { -- 2943
			role = "user", -- 2944
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 2945
		} -- 2945
		toolResultIndex = #messages - 1 -- 2947
	else -- 2947
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2949
			{}, -- 2949
			messages[toolResultIndex + 1], -- 2950
			{content = encodeJson(result)} -- 2949
		) -- 2949
	end -- 2949
	local pairStartIndex = toolResultIndex -- 2955
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2956
	if toolCallId and toolCallId ~= "" then -- 2956
		do -- 2956
			local i = toolResultIndex - 1 -- 2958
			while i >= 0 do -- 2958
				do -- 2958
					local message = messages[i + 1] -- 2959
					if message.role ~= "assistant" or not message.tool_calls then -- 2959
						goto __continue473 -- 2960
					end -- 2960
					if __TS__ArraySome( -- 2960
						message.tool_calls, -- 2961
						function(____, call) return call.id == toolCallId end -- 2961
					) then -- 2961
						pairStartIndex = i -- 2962
						break -- 2963
					end -- 2963
				end -- 2963
				::__continue473:: -- 2963
				i = i - 1 -- 2958
			end -- 2958
		end -- 2958
	end -- 2958
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2967
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2970
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2974
	upsertStep( -- 2976
		session.id, -- 2976
		questionnaire.taskId, -- 2976
		questionnaire.step, -- 2976
		"ask_user", -- 2976
		{status = "DONE", result = result} -- 2976
	) -- 2976
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 2980
	upsertStep( -- 2981
		session.id, -- 2981
		questionnaire.taskId, -- 2981
		answerStep, -- 2981
		"questionnaire_answer", -- 2981
		{status = "DONE", result = result} -- 2981
	) -- 2981
	return {success = true, answerStep = answerStep, result = result} -- 2985
end -- 2911
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 2988
	local session = getSessionItem(sessionId) -- 2989
	if not session then -- 2989
		return {success = false, message = "session not found"} -- 2990
	end -- 2990
	if session.kind ~= "main" then -- 2990
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2991
	end -- 2991
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2992
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2992
		return {success = false, message = "pending questionnaire not found or already handled"} -- 2994
	end -- 2994
	local llmConfigRes = getLLMConfig(llmConfigId) -- 2996
	if not llmConfigRes.success then -- 2996
		return {success = false, message = llmConfigRes.message} -- 2997
	end -- 2997
	if not removePendingQuestionnaire(session) then -- 2997
		return {success = false, message = "failed to consume questionnaire file"} -- 2998
	end -- 2998
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 2999
	if not replaced.success then -- 2999
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3001
		return replaced -- 3002
	end -- 3002
	local t = now() -- 3004
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3005
	session.workMode = "plan" -- 3006
	local result = startPromptTask( -- 3007
		session, -- 3007
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3007
		nil, -- 3007
		{}, -- 3007
		{ -- 3007
			workMode = "plan", -- 3008
			persistUserMessage = false, -- 3009
			resumeConversation = true, -- 3010
			existingTaskId = questionnaire.taskId, -- 3011
			initialStep = replaced.answerStep, -- 3012
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3013
			llmConfig = llmConfigRes.config -- 3014
		} -- 3014
	) -- 3014
	if not result.success then -- 3014
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3017
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3018
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3019
		emitAgentSessionPatch( -- 3020
			session.id, -- 3020
			{ -- 3020
				session = getSessionItem(session.id), -- 3021
				pendingQuestionnaire = questionnaire -- 3022
			} -- 3022
		) -- 3022
		return result -- 3024
	end -- 3024
	emitAgentSessionPatch( -- 3026
		sessionId, -- 3026
		{ -- 3026
			session = getSessionItem(sessionId), -- 3027
			pendingQuestionnaire = false -- 3028
		} -- 3028
	) -- 3028
	return result -- 3030
end -- 2988
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 3033
	local session = getSessionItem(sessionId) -- 3034
	if not session then -- 3034
		return {success = false, message = "session not found"} -- 3035
	end -- 3035
	if session.kind ~= "main" then -- 3035
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3036
	end -- 3036
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3037
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3037
		return {success = false, message = "pending questionnaire not found"} -- 3038
	end -- 3038
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3039
	if not validated.success then -- 3039
		return validated -- 3040
	end -- 3040
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3041
	if not llmConfigRes.success then -- 3041
		return {success = false, message = llmConfigRes.message} -- 3042
	end -- 3042
	local t = now() -- 3043
	if not removePendingQuestionnaire(session) then -- 3043
		return {success = false, message = "failed to consume questionnaire file"} -- 3044
	end -- 3044
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3045
	if not replaced.success then -- 3045
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3047
		return replaced -- 3048
	end -- 3048
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3050
	session.workMode = "plan" -- 3051
	local result = startPromptTask( -- 3052
		session, -- 3052
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3052
		nil, -- 3052
		{}, -- 3052
		{ -- 3052
			workMode = "plan", -- 3053
			persistUserMessage = false, -- 3054
			resumeConversation = true, -- 3055
			existingTaskId = questionnaire.taskId, -- 3056
			initialStep = replaced.answerStep, -- 3057
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3058
			llmConfig = llmConfigRes.config -- 3059
		} -- 3059
	) -- 3059
	if not result.success then -- 3059
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3062
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3063
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3064
		emitAgentSessionPatch( -- 3065
			session.id, -- 3065
			{ -- 3065
				session = getSessionItem(session.id), -- 3066
				pendingQuestionnaire = questionnaire -- 3067
			} -- 3067
		) -- 3067
		return result -- 3069
	end -- 3069
	emitAgentSessionPatch( -- 3071
		sessionId, -- 3071
		{ -- 3071
			session = getSessionItem(sessionId), -- 3072
			pendingQuestionnaire = false -- 3073
		} -- 3073
	) -- 3073
	return result -- 3075
end -- 3033
function ____exports.stopSessionTask(sessionId) -- 3078
	local session = getSessionItem(sessionId) -- 3079
	if not session or session.currentTaskId == nil then -- 3079
		return {success = false, message = "session task not found"} -- 3081
	end -- 3081
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3081
		return {success = false, message = "session task is finalizing"} -- 3084
	end -- 3084
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3086
	local stopToken = activeStopTokens[session.currentTaskId] -- 3087
	if not stopToken then -- 3087
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3087
			return {success = true, recovered = true} -- 3090
		end -- 3090
		return {success = false, message = "task is not running"} -- 3092
	end -- 3092
	if stopToken.stopped then -- 3092
		return {success = true, stopping = true} -- 3095
	end -- 3095
	stopToken.stopped = true -- 3097
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3098
	return {success = true, stopping = true} -- 3102
end -- 3078
function ____exports.getCurrentTaskId(sessionId) -- 3105
	local ____opt_126 = getSessionItem(sessionId) -- 3105
	return ____opt_126 and ____opt_126.currentTaskId -- 3106
end -- 3105
function ____exports.validateTaskAccess(sessionId, taskId) -- 3109
	local session = getSessionItem(sessionId) -- 3110
	if not session then -- 3110
		return {success = false, message = "session not found"} -- 3111
	end -- 3111
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3111
		getSessionOperableTaskIds(sessionId), -- 3112
		taskId -- 3112
	) < 0 then -- 3112
		return {success = false, message = "task is not operable for this session"} -- 3113
	end -- 3113
	return {success = true, session = session} -- 3115
end -- 3109
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3118
	if checkpointId <= 0 then -- 3118
		return {success = false, message = "invalid checkpointId"} -- 3120
	end -- 3120
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3122
	if not checkpoint then -- 3122
		return {success = false, message = "checkpoint not found"} -- 3124
	end -- 3124
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3126
	if not taskAccess.success then -- 3126
		return taskAccess -- 3127
	end -- 3127
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3128
end -- 3118
function ____exports.listRunningSessions() -- 3131
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3132
	local sessions = {} -- 3139
	do -- 3139
		local i = 0 -- 3140
		while i < #rows do -- 3140
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3141
			if session.currentTaskStatus == "RUNNING" then -- 3141
				sessions[#sessions + 1] = session -- 3143
			end -- 3143
			i = i + 1 -- 3140
		end -- 3140
	end -- 3140
	return {success = true, sessions = sessions} -- 3146
end -- 3131
return ____exports -- 3131