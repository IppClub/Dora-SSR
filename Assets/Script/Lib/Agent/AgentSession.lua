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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, SESSION_SELECT_COLUMNS, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____CodingAgent = require("Agent.CodingAgent") -- 4
local runCodingAgent = ____CodingAgent.runCodingAgent -- 4
local truncateAgentUserPrompt = ____CodingAgent.truncateAgentUserPrompt -- 4
local AgentToolRegistry = require("Agent.AgentToolRegistry") -- 6
local AgentRuntimePolicy = require("Agent.AgentRuntimePolicy") -- 7
local Tools = require("Agent.Tools") -- 8
local ____AgentStorage = require("Agent.AgentStorage") -- 9
local TABLE_SESSION = ____AgentStorage.TABLE_SESSION -- 10
local TABLE_MESSAGE = ____AgentStorage.TABLE_MESSAGE -- 11
local TABLE_STEP = ____AgentStorage.TABLE_STEP -- 12
local TABLE_TASK = ____AgentStorage.TABLE_TASK -- 13
local TABLE_TASK_REFERENCE = ____AgentStorage.TABLE_TASK_REFERENCE -- 14
local addTaskReference = ____AgentStorage.addTaskReference -- 15
local cleanupTaskHeavyData = ____AgentStorage.cleanupTaskHeavyData -- 16
local getSessionOperableTaskIds = ____AgentStorage.getSessionOperableTaskIds -- 17
local requireAgentStorage = ____AgentStorage.requireAgentStorage -- 18
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
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 25
local validateQuestionnaireAnswers = ____AgentQuestionnaire.validateQuestionnaireAnswers -- 25
function getDefaultUseChineseResponse() -- 329
	local zh = string.match(App.locale, "^zh") -- 330
	return zh ~= nil -- 331
end -- 331
function toStr(v) -- 334
	if v == false or v == nil then -- 334
		return "" -- 335
	end -- 335
	return tostring(v) -- 336
end -- 336
function encodeJson(value) -- 339
	local text = safeJsonEncode(value) -- 340
	return text or "" -- 341
end -- 341
function decodeJsonObject(text) -- 344
	if not text or text == "" then -- 344
		return nil -- 345
	end -- 345
	local value = safeJsonDecode(text) -- 346
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 346
		return value -- 348
	end -- 348
	return nil -- 350
end -- 350
function decodeJsonFiles(text) -- 353
	if not text or text == "" then -- 353
		return nil -- 354
	end -- 354
	local value = safeJsonDecode(text) -- 355
	if not value or not __TS__ArrayIsArray(value) then -- 355
		return nil -- 356
	end -- 356
	local files = {} -- 357
	do -- 357
		local i = 0 -- 358
		while i < #value do -- 358
			do -- 358
				local item = value[i + 1] -- 359
				if type(item) ~= "table" then -- 359
					goto __continue14 -- 360
				end -- 360
				files[#files + 1] = { -- 361
					path = sanitizeUTF8(toStr(item.path)), -- 362
					op = sanitizeUTF8(toStr(item.op)) -- 363
				} -- 363
			end -- 363
			::__continue14:: -- 363
			i = i + 1 -- 358
		end -- 358
	end -- 358
	return files -- 366
end -- 366
function decodeChangeSetSummary(value) -- 369
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 369
		return nil -- 370
	end -- 370
	local row = value -- 371
	if row.success ~= true then -- 371
		return nil -- 372
	end -- 372
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 373
	if taskId <= 0 then -- 373
		return nil -- 374
	end -- 374
	local files = {} -- 375
	if __TS__ArrayIsArray(row.files) then -- 375
		do -- 375
			local i = 0 -- 377
			while i < #row.files do -- 377
				do -- 377
					local file = row.files[i + 1] -- 378
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 378
						goto __continue22 -- 379
					end -- 379
					local fileRow = file -- 380
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 381
					if path == "" then -- 381
						goto __continue22 -- 382
					end -- 382
					local checkpointIds = {} -- 383
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 383
						do -- 383
							local j = 0 -- 385
							while j < #fileRow.checkpointIds do -- 385
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 386
								if checkpointId > 0 then -- 386
									checkpointIds[#checkpointIds + 1] = checkpointId -- 387
								end -- 387
								j = j + 1 -- 385
							end -- 385
						end -- 385
					end -- 385
					local op = toStr(fileRow.op) -- 390
					files[#files + 1] = { -- 391
						path = path, -- 392
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 393
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 394
						checkpointIds = checkpointIds -- 395
					} -- 395
				end -- 395
				::__continue22:: -- 395
				i = i + 1 -- 377
			end -- 377
		end -- 377
	end -- 377
	return { -- 399
		success = true, -- 400
		taskId = taskId, -- 401
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 402
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 403
		files = files, -- 404
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 405
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 406
	} -- 406
end -- 406
function decodeHandoffEvidence(value) -- 410
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 410
		return nil -- 411
	end -- 411
	local row = value -- 412
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 413
		__TS__ArrayFilter( -- 414
			row.modifiedFiles, -- 414
			function(____, item) return type(item) == "string" end -- 414
		), -- 414
		function(____, item) return sanitizeUTF8(item) end -- 414
	) or ({}) -- 414
	local lastBuild = nil -- 416
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 416
		local build = row.lastBuild -- 418
		lastBuild = { -- 419
			result = build.result == "passed" and "passed" or "failed", -- 420
			path = sanitizeUTF8(toStr(build.path)), -- 421
			evidence = takeUtf8Head( -- 422
				sanitizeUTF8(toStr(build.evidence)), -- 422
				600 -- 422
			) -- 422
		} -- 422
	end -- 422
	local commands = {} -- 425
	if __TS__ArrayIsArray(row.commands) then -- 425
		do -- 425
			local i = 0 -- 427
			while i < #row.commands and #commands < 8 do -- 427
				do -- 427
					local raw = row.commands[i + 1] -- 428
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 428
						goto __continue36 -- 429
					end -- 429
					local item = raw -- 430
					commands[#commands + 1] = { -- 431
						mode = sanitizeUTF8(toStr(item.mode)), -- 432
						command = takeUtf8Head( -- 433
							sanitizeUTF8(toStr(item.command)), -- 433
							600 -- 433
						), -- 433
						result = item.result == "passed" and "passed" or "failed", -- 434
						evidence = takeUtf8Head( -- 435
							sanitizeUTF8(toStr(item.evidence)), -- 435
							600 -- 435
						) -- 435
					} -- 435
				end -- 435
				::__continue36:: -- 435
				i = i + 1 -- 427
			end -- 427
		end -- 427
	end -- 427
	local authoritativeSources = {} -- 439
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 439
		do -- 439
			local i = 0 -- 441
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 441
				do -- 441
					local raw = row.authoritativeSources[i + 1] -- 442
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 442
						goto __continue40 -- 443
					end -- 443
					local item = raw -- 444
					authoritativeSources[#authoritativeSources + 1] = { -- 445
						tool = "search_dora_doc", -- 446
						query = takeUtf8Head( -- 447
							sanitizeUTF8(toStr(item.query)), -- 447
							300 -- 447
						), -- 447
						source = sanitizeUTF8(toStr(item.source)), -- 448
						result = item.result == "passed" and "passed" or "failed" -- 449
					} -- 449
				end -- 449
				::__continue40:: -- 449
				i = i + 1 -- 441
			end -- 441
		end -- 441
	end -- 441
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 453
end -- 453
function takeUtf8Head(text, maxChars) -- 456
	if maxChars <= 0 or text == "" then -- 456
		return "" -- 457
	end -- 457
	local nextPos = utf8.offset(text, maxChars + 1) -- 458
	if nextPos == nil then -- 458
		return text -- 459
	end -- 459
	return string.sub(text, 1, nextPos - 1) -- 460
end -- 460
function normalizeMemoryEntryEvidence(value) -- 463
	local evidence = {} -- 464
	if not __TS__ArrayIsArray(value) then -- 464
		return evidence -- 465
	end -- 465
	do -- 465
		local i = 0 -- 466
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 466
			do -- 466
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 467
				if item == "" then -- 467
					goto __continue48 -- 468
				end -- 468
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 468
					evidence[#evidence + 1] = item -- 470
				end -- 470
			end -- 470
			::__continue48:: -- 470
			i = i + 1 -- 466
		end -- 466
	end -- 466
	return evidence -- 473
end -- 473
function decodeSubAgentMemoryEntry(value) -- 476
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 476
		return nil -- 477
	end -- 477
	local row = value -- 478
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 479
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 480
	local content = takeUtf8Head( -- 481
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 481
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 481
	) -- 481
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 481
		return nil -- 482
	end -- 482
	return { -- 483
		sourceSessionId = sourceSessionId, -- 484
		sourceTaskId = sourceTaskId, -- 485
		content = content, -- 486
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 487
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 488
	} -- 488
end -- 488
function getTaskChangeSetSummary(taskId) -- 492
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 493
	return summary.success and summary or nil -- 494
end -- 494
function queryRows(sql, args) -- 497
	local ____args_0 -- 498
	if args then -- 498
		____args_0 = DB:query(sql, args) -- 498
	else -- 498
		____args_0 = DB:query(sql) -- 498
	end -- 498
	return ____args_0 -- 498
end -- 498
function queryOne(sql, args) -- 501
	local rows = queryRows(sql, args) -- 502
	if not rows or #rows == 0 then -- 502
		return nil -- 503
	end -- 503
	return rows[1] -- 504
end -- 504
function summarizeHandoffResult(result) -- 507
	local candidates = {result.output, result.message, result.state, result.phase} -- 508
	do -- 508
		local i = 0 -- 509
		while i < #candidates do -- 509
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 510
			if text ~= "" then -- 510
				return takeUtf8Head(text, 600) -- 511
			end -- 511
			i = i + 1 -- 509
		end -- 509
	end -- 509
	local messages = result.messages -- 513
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 513
		local parts = {} -- 515
		do -- 515
			local i = 0 -- 516
			while i < #messages and #parts < 4 do -- 516
				do -- 516
					local row = messages[i + 1] -- 517
					if not row or type(row) ~= "table" then -- 517
						goto __continue64 -- 518
					end -- 518
					local item = row -- 519
					local ____sanitizeUTF8_4 = sanitizeUTF8 -- 520
					local ____toStr_3 = toStr -- 520
					local ____item_message_1 = item.message -- 520
					if ____item_message_1 == nil then -- 520
						____item_message_1 = item.error -- 520
					end -- 520
					local ____item_message_1_2 = ____item_message_1 -- 520
					if ____item_message_1_2 == nil then -- 520
						____item_message_1_2 = item.file -- 520
					end -- 520
					local text = __TS__StringTrim(____sanitizeUTF8_4(____toStr_3(____item_message_1_2))) -- 520
					if text ~= "" then -- 520
						parts[#parts + 1] = text -- 521
					end -- 521
				end -- 521
				::__continue64:: -- 521
				i = i + 1 -- 516
			end -- 516
		end -- 516
		if #parts > 0 then -- 516
			return takeUtf8Head( -- 523
				table.concat(parts, "; "), -- 523
				600 -- 523
			) -- 523
		end -- 523
	end -- 523
	return result.success == true and "tool result success=true" or "tool result success=false" -- 525
end -- 525
function getTaskHandoffEvidence(taskId, changeSet) -- 528
	local ____opt_5 = changeSet -- 528
	local evidence = { -- 529
		modifiedFiles = ____opt_5 and __TS__ArrayMap( -- 530
			changeSet and changeSet.files, -- 530
			function(____, item) return item.path end -- 530
		) or ({}), -- 530
		commands = {}, -- 531
		authoritativeSources = {} -- 532
	} -- 532
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 534
	do -- 534
		local i = 0 -- 539
		while i < #rows do -- 539
			local tool = toStr(rows[i + 1][1]) -- 540
			local status = toStr(rows[i + 1][2]) -- 541
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 542
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 543
			local passed = status == "DONE" and result.success == true -- 544
			if tool == "build" then -- 544
				evidence.lastBuild = { -- 546
					result = passed and "passed" or "failed", -- 547
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 548
					evidence = summarizeHandoffResult(result) -- 549
				} -- 549
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 549
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 552
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 553
				local ____evidence_commands_9 = evidence.commands -- 553
				____evidence_commands_9[#____evidence_commands_9 + 1] = { -- 554
					mode = mode, -- 555
					command = takeUtf8Head( -- 556
						__TS__StringTrim(sanitizeUTF8(command)), -- 556
						600 -- 556
					), -- 556
					result = passed and "passed" or "failed", -- 557
					evidence = summarizeHandoffResult(result) -- 558
				} -- 558
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 558
				local ____evidence_authoritativeSources_10 = evidence.authoritativeSources -- 558
				____evidence_authoritativeSources_10[#____evidence_authoritativeSources_10 + 1] = { -- 561
					tool = "search_dora_doc", -- 562
					query = takeUtf8Head( -- 563
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 563
						300 -- 563
					), -- 563
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 564
					result = passed and "passed" or "failed" -- 565
				} -- 565
			end -- 565
			i = i + 1 -- 539
		end -- 539
	end -- 539
	return evidence -- 569
end -- 569
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 572
	local lastBuild = evidence.lastBuild -- 576
	if not lastBuild or lastBuild.result ~= "failed" then -- 576
		return completion -- 577
	end -- 577
	local validation = __TS__ArraySlice(completion.validation) -- 578
	local foundBuild = false -- 579
	do -- 579
		local i = 0 -- 580
		while i < #validation do -- 580
			do -- 580
				if validation[i + 1].kind ~= "build" then -- 580
					goto __continue78 -- 581
				end -- 581
				foundBuild = true -- 582
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 583
			end -- 583
			::__continue78:: -- 583
			i = i + 1 -- 580
		end -- 580
	end -- 580
	if not foundBuild then -- 580
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 590
	end -- 590
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 592
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 593
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 593
		knownIssues[#knownIssues + 1] = issue -- 594
	end -- 594
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 595
end -- 595
function getLastInsertRowId() -- 603
	local row = queryOne("SELECT last_insert_rowid()") -- 604
	return row and (row[1] or 0) or 0 -- 605
end -- 605
function isValidProjectRoot(path) -- 608
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 609
end -- 609
function rowToSession(row) -- 612
	return { -- 613
		id = row[1], -- 614
		projectRoot = toStr(row[2]), -- 615
		title = toStr(row[3]), -- 616
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 617
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 618
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 619
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 620
		status = toStr(row[8]), -- 621
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 622
		currentTaskStatus = toStr(row[10]), -- 623
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 624
		createdAt = row[11], -- 625
		updatedAt = row[12], -- 626
		metrics = decodeJsonObject(toStr(row[13])), -- 627
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 628
	} -- 628
end -- 628
function rowToMessage(row) -- 632
	local message = { -- 633
		id = row[1], -- 634
		sessionId = row[2], -- 635
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 636
		role = toStr(row[4]), -- 637
		content = toStr(row[5]), -- 638
		createdAt = row[7], -- 639
		updatedAt = row[8] -- 640
	} -- 640
	local displayContent = toStr(row[6]) -- 642
	if displayContent ~= "" then -- 642
		message.displayContent = displayContent -- 643
	end -- 643
	return message -- 644
end -- 644
function rowToStep(row) -- 647
	return { -- 648
		id = row[1], -- 649
		sessionId = row[2], -- 650
		taskId = row[3], -- 651
		step = row[4], -- 652
		tool = toStr(row[5]), -- 653
		status = toStr(row[6]), -- 654
		reason = toStr(row[7]), -- 655
		reasoningContent = toStr(row[8]), -- 656
		params = decodeJsonObject(toStr(row[9])), -- 657
		result = decodeJsonObject(toStr(row[10])), -- 658
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 659
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 660
		files = decodeJsonFiles(toStr(row[13])), -- 661
		createdAt = row[14], -- 662
		updatedAt = row[15] -- 663
	} -- 663
end -- 663
function getQuestionnairePath(projectRoot) -- 667
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 668
end -- 668
function decodeQuestionnaireFile(text) -- 671
	local value = decodeJsonObject(text) -- 672
	if not value then -- 672
		return nil -- 673
	end -- 673
	local schema = value.schema -- 674
	local id = type(value.id) == "number" and value.id or 0 -- 675
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 676
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 677
	local step = type(value.step) == "number" and value.step or 0 -- 678
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 679
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 679
		return nil -- 681
	end -- 681
	return { -- 683
		id = id, -- 683
		sessionId = sessionId, -- 683
		taskId = taskId, -- 683
		step = step, -- 683
		status = "PENDING", -- 683
		schema = schema, -- 683
		createdAt = createdAt -- 683
	} -- 683
end -- 683
function getPendingQuestionnaire(sessionId) -- 686
	local session = getSessionItem(sessionId) -- 687
	if not session or session.kind ~= "main" then -- 687
		return nil -- 688
	end -- 688
	local path = getQuestionnairePath(session.projectRoot) -- 689
	if not Content:exist(path) then -- 689
		return nil -- 690
	end -- 690
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 691
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 692
end -- 692
function restorePendingQuestionnaireState(session) -- 695
	local questionnaire = getPendingQuestionnaire(session.id) -- 696
	if not questionnaire then -- 696
		return {session = session} -- 697
	end -- 697
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 697
		local t = now() -- 704
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 705
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 711
		local restored = getSessionItem(session.id) -- 712
		if restored then -- 712
			session = restored -- 713
		end -- 713
	end -- 713
	return {session = session, questionnaire = questionnaire} -- 715
end -- 715
function savePendingQuestionnaire(projectRoot, questionnaire) -- 718
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 719
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 719
		return false -- 720
	end -- 720
	local path = getQuestionnairePath(projectRoot) -- 721
	local tempPath = path .. ".tmp" -- 722
	local backupPath = path .. ".bak" -- 723
	Content:remove(tempPath) -- 724
	Content:remove(backupPath) -- 725
	if not Content:save( -- 725
		tempPath, -- 726
		encodeJson(questionnaire) -- 726
	) then -- 726
		return false -- 726
	end -- 726
	local hadOriginal = Content:exist(path) -- 727
	if hadOriginal and not Content:move(path, backupPath) then -- 727
		Content:remove(tempPath) -- 729
		return false -- 730
	end -- 730
	if Content:move(tempPath, path) then -- 730
		Content:remove(backupPath) -- 733
		Tools.sendWebIDEFileUpdate( -- 734
			path, -- 734
			true, -- 734
			encodeJson(questionnaire) -- 734
		) -- 734
		return true -- 735
	end -- 735
	Content:remove(tempPath) -- 737
	if hadOriginal and Content:exist(backupPath) then -- 737
		Content:move(backupPath, path) -- 739
	end -- 739
	return false -- 741
end -- 741
function removePendingQuestionnaire(session) -- 744
	local path = getQuestionnairePath(session.projectRoot) -- 745
	if not Content:exist(path) then -- 745
		return true -- 746
	end -- 746
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 747
	if questionnaire and questionnaire.sessionId ~= session.id then -- 747
		return false -- 748
	end -- 748
	if not Content:remove(path) then -- 748
		return false -- 749
	end -- 749
	Tools.sendWebIDEFileUpdate(path, false, "") -- 750
	return true -- 751
end -- 751
function publishQuestionnaire(request) -- 754
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 754
		local session = getSessionItem(request.sessionId) -- 760
		if not session or session.kind ~= "main" then -- 760
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 760
		end -- 760
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 762
		if Content:exist(pendingPath) then -- 762
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 762
		end -- 762
		local questionnaire = { -- 764
			id = request.taskId, -- 765
			sessionId = request.sessionId, -- 766
			taskId = request.taskId, -- 767
			step = request.step, -- 768
			status = "PENDING", -- 769
			schema = request.schema, -- 770
			createdAt = now() -- 771
		} -- 771
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 771
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 771
		end -- 771
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 771
	end) -- 771
end -- 771
function getMessageItem(messageId) -- 779
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 780
	return row and rowToMessage(row) or nil -- 786
end -- 786
function getStepItem(sessionId, taskId, step) -- 789
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 790
	return row and rowToStep(row) or nil -- 796
end -- 796
function deleteMessageSteps(sessionId, taskId) -- 799
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 800
	local ids = {} -- 805
	do -- 805
		local i = 0 -- 806
		while i < #rows do -- 806
			local row = rows[i + 1] -- 807
			if type(row[1]) == "number" then -- 807
				ids[#ids + 1] = row[1] -- 809
			end -- 809
			i = i + 1 -- 806
		end -- 806
	end -- 806
	if #ids > 0 then -- 806
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 813
	end -- 813
	return ids -- 819
end -- 819
function normalizeDisabledAgentTools(value) -- 822
	if not __TS__ArrayIsArray(value) then -- 822
		return {} -- 823
	end -- 823
	local tools = {} -- 824
	do -- 824
		local i = 0 -- 825
		while i < #value do -- 825
			do -- 825
				local name = value[i + 1] -- 826
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 826
					goto __continue123 -- 827
				end -- 827
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 827
					tools[#tools + 1] = name -- 828
				end -- 828
			end -- 828
			::__continue123:: -- 828
			i = i + 1 -- 825
		end -- 825
	end -- 825
	return tools -- 830
end -- 830
function normalizeWorkMode(value, fallback) -- 833
	if fallback == nil then -- 833
		fallback = "code" -- 833
	end -- 833
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 834
end -- 834
function getSessionRow(sessionId) -- 837
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 838
end -- 838
function getSessionItem(sessionId) -- 846
	local row = getSessionRow(sessionId) -- 847
	return row and rowToSession(row) or nil -- 848
end -- 848
function getTaskPrompt(taskId) -- 851
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 852
	if not row or type(row[1]) ~= "string" then -- 852
		return nil -- 853
	end -- 853
	return toStr(row[1]) -- 854
end -- 854
function getLatestMainSessionByProjectRoot(projectRoot) -- 857
	if not isValidProjectRoot(projectRoot) then -- 857
		return nil -- 858
	end -- 858
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 859
	return row and rowToSession(row) or nil -- 867
end -- 867
function countRunningSubSessions(rootSessionId) -- 870
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 871
	local count = 0 -- 878
	do -- 878
		local i = 0 -- 879
		while i < #rows do -- 879
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 880
			if session.currentTaskStatus == "RUNNING" then -- 880
				count = count + 1 -- 882
			end -- 882
			i = i + 1 -- 879
		end -- 879
	end -- 879
	return count -- 885
end -- 885
function deleteSessionRecords(sessionId, preserveArtifacts) -- 888
	if preserveArtifacts == nil then -- 888
		preserveArtifacts = false -- 888
	end -- 888
	local session = getSessionItem(sessionId) -- 889
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 890
	local taskIds = {} -- 898
	do -- 898
		local i = 0 -- 899
		while i < #taskRows do -- 899
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 900
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 900
				taskIds[#taskIds + 1] = taskId -- 902
				local stopToken = activeStopTokens[taskId] -- 903
				if stopToken ~= nil then -- 903
					stopToken.stopped = true -- 905
					stopToken.reason = "session deleted" -- 906
				end -- 906
			end -- 906
			i = i + 1 -- 899
		end -- 899
	end -- 899
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 910
	do -- 910
		local i = 0 -- 911
		while i < #children do -- 911
			local row = children[i + 1] -- 912
			if type(row[1]) == "number" and row[1] > 0 then -- 912
				deleteSessionRecords(row[1], preserveArtifacts) -- 914
			end -- 914
			i = i + 1 -- 911
		end -- 911
	end -- 911
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 917
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 918
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 919
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 920
	if session and session.kind == "main" then -- 920
		removePendingQuestionnaire(session) -- 922
	end -- 922
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 922
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 922
			Tools.sendWebIDERefreshTree() -- 926
		end -- 926
	end -- 926
	do -- 926
		local i = 0 -- 929
		while i < #taskIds do -- 929
			cleanupTaskHeavyData(taskIds[i + 1]) -- 930
			i = i + 1 -- 929
		end -- 929
	end -- 929
end -- 929
function getSessionRootId(session) -- 934
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 935
end -- 935
function getRootSessionItem(sessionId) -- 938
	local session = getSessionItem(sessionId) -- 939
	if not session then -- 939
		return nil -- 940
	end -- 940
	return getSessionItem(getSessionRootId(session)) or session -- 941
end -- 941
function listRelatedSessions(sessionId) -- 944
	local root = getRootSessionItem(sessionId) -- 945
	if not root then -- 945
		return {} -- 946
	end -- 946
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 947
	return __TS__ArrayMap( -- 956
		rows, -- 956
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 956
	) -- 956
end -- 956
function getSessionSpawnInfo(session) -- 959
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 960
	if not info then -- 960
		return nil -- 961
	end -- 961
	local ____temp_16 = type(info.sessionId) == "number" and info.sessionId or nil -- 963
	local ____temp_17 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 964
	local ____temp_18 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 965
	local ____temp_19 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 966
	local ____temp_20 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 967
	local ____temp_21 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 968
	local ____temp_22 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 969
	local ____temp_23 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 970
		__TS__ArrayFilter( -- 971
			info.filesHint, -- 971
			function(____, item) return type(item) == "string" end -- 971
		), -- 971
		function(____, item) return sanitizeUTF8(item) end -- 971
	) or nil -- 971
	local ____temp_24 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 973
	local ____temp_14 -- 976
	if info.success == true then -- 976
		____temp_14 = true -- 976
	else -- 976
		local ____temp_13 -- 976
		if info.success == false then -- 976
			____temp_13 = false -- 976
		else -- 976
			____temp_13 = nil -- 976
		end -- 976
		____temp_14 = ____temp_13 -- 976
	end -- 976
	local ____temp_15 -- 977
	if info.cleared == true then -- 977
		____temp_15 = true -- 977
	else -- 977
		____temp_15 = nil -- 977
	end -- 977
	return { -- 962
		sessionId = ____temp_16, -- 963
		rootSessionId = ____temp_17, -- 964
		parentSessionId = ____temp_18, -- 965
		title = ____temp_19, -- 966
		prompt = ____temp_20, -- 967
		goal = ____temp_21, -- 968
		expectedOutput = ____temp_22, -- 969
		filesHint = ____temp_23, -- 970
		status = ____temp_24, -- 973
		success = ____temp_14, -- 976
		cleared = ____temp_15, -- 977
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 978
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 979
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 980
		changeSet = decodeChangeSetSummary(info.changeSet), -- 981
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 982
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 983
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 984
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 985
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 988
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 989
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 990
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 991
	} -- 991
end -- 991
function ensureDirRecursive(dir) -- 1008
	if not dir or dir == "" then -- 1008
		return false -- 1009
	end -- 1009
	if Content:exist(dir) then -- 1009
		return Content:isdir(dir) -- 1010
	end -- 1010
	local parent = Path:getPath(dir) -- 1011
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1011
		if not ensureDirRecursive(parent) then -- 1011
			return false -- 1014
		end -- 1014
	end -- 1014
	return Content:mkdir(dir) -- 1017
end -- 1017
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1020
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1021
	if not Content:exist(dir) then -- 1021
		ensureDirRecursive(dir) -- 1023
	end -- 1023
	local path = Path(dir, SPAWN_INFO_FILE) -- 1025
	local text = safeJsonEncode(value) -- 1026
	if not text then -- 1026
		return false -- 1027
	end -- 1027
	local content = text .. "\n" -- 1028
	if not Content:save(path, content) then -- 1028
		return false -- 1030
	end -- 1030
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1032
	return true -- 1033
end -- 1033
function readSpawnInfo(projectRoot, memoryScope) -- 1036
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1037
	if not Content:exist(path) then -- 1037
		return nil -- 1038
	end -- 1038
	local text = Content:load(path) -- 1039
	if not text or __TS__StringTrim(text) == "" then -- 1039
		return nil -- 1040
	end -- 1040
	local value = safeJsonDecode(text) -- 1041
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1041
		return value -- 1043
	end -- 1043
	return nil -- 1045
end -- 1045
function getArtifactRelativeDir(memoryScope) -- 1048
	return Path(".agent", memoryScope) -- 1049
end -- 1049
function getArtifactDir(projectRoot, memoryScope) -- 1052
	return Path( -- 1053
		projectRoot, -- 1053
		getArtifactRelativeDir(memoryScope) -- 1053
	) -- 1053
end -- 1053
function getResultRelativePath(memoryScope) -- 1056
	return Path( -- 1057
		getArtifactRelativeDir(memoryScope), -- 1057
		RESULT_FILE -- 1057
	) -- 1057
end -- 1057
function getResultPath(projectRoot, memoryScope) -- 1060
	return Path( -- 1061
		projectRoot, -- 1061
		getResultRelativePath(memoryScope) -- 1061
	) -- 1061
end -- 1061
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1064
	if not resultFilePath or resultFilePath == "" then -- 1064
		return "" -- 1065
	end -- 1065
	local path = Path(projectRoot, resultFilePath) -- 1066
	if not Content:exist(path) then -- 1066
		return "" -- 1067
	end -- 1067
	local text = sanitizeUTF8(Content:load(path)) -- 1068
	if not text or __TS__StringTrim(text) == "" then -- 1068
		return "" -- 1069
	end -- 1069
	local marker = "\n## Summary\n" -- 1070
	local start = string.find(text, marker, 1, true) -- 1071
	if start ~= nil then -- 1071
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1073
	end -- 1073
	return __TS__StringTrim(text) -- 1075
end -- 1075
function buildStructuredSubAgentMemoryEntry(record) -- 1078
	local hasPassedValidation = false -- 1079
	do -- 1079
		local i = 0 -- 1080
		while i < #record.completion.validation do -- 1080
			local result = record.completion.validation[i + 1].result -- 1081
			if result == "failed" then -- 1081
				return nil -- 1086
			end -- 1086
			if result == "passed" then -- 1086
				hasPassedValidation = true -- 1088
			end -- 1088
			i = i + 1 -- 1080
		end -- 1080
	end -- 1080
	if not hasPassedValidation then -- 1080
		return nil -- 1091
	end -- 1091
	local candidates = record.completion.learningCandidates -- 1092
	local claims = {} -- 1093
	local evidence = {} -- 1094
	do -- 1094
		local i = 0 -- 1095
		while i < #candidates do -- 1095
			do -- 1095
				local candidate = candidates[i + 1] -- 1096
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1096
					goto __continue194 -- 1097
				end -- 1097
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1098
				do -- 1098
					local j = 0 -- 1099
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1099
						local item = candidate.evidence[j + 1] -- 1100
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1100
							evidence[#evidence + 1] = item -- 1101
						end -- 1101
						j = j + 1 -- 1099
					end -- 1099
				end -- 1099
			end -- 1099
			::__continue194:: -- 1099
			i = i + 1 -- 1095
		end -- 1095
	end -- 1095
	local content = takeUtf8Head( -- 1104
		table.concat(claims, "\n"), -- 1104
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1104
	) -- 1104
	if content == "" then -- 1104
		return nil -- 1105
	end -- 1105
	return { -- 1106
		sourceSessionId = record.sessionId, -- 1107
		sourceTaskId = record.sourceTaskId, -- 1108
		content = content, -- 1109
		evidence = evidence, -- 1110
		createdAt = record.finishedAt -- 1111
	} -- 1111
end -- 1111
function containsNormalizedText(text, query) -- 1115
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1116
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1117
	if normalizedQuery == "" then -- 1117
		return true -- 1118
	end -- 1118
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1119
end -- 1119
function getSubAgentDisplayKey(item) -- 1122
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1128
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1129
	local label = goal ~= "" and goal or title -- 1130
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1131
end -- 1131
function writeSubAgentResultFile(session, record, resultText) -- 1134
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1135
	if not Content:exist(dir) then -- 1135
		ensureDirRecursive(dir) -- 1137
	end -- 1137
	local ____array_33 = __TS__SparseArrayNew( -- 1137
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1140
		"- Status: " .. record.status, -- 1141
		"- Success: " .. (record.success and "true" or "false"), -- 1142
		"- Outcome: " .. record.completion.outcome, -- 1143
		"- Session ID: " .. tostring(record.sessionId), -- 1144
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1145
		"- Goal: " .. record.goal, -- 1146
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1147
	) -- 1147
	__TS__SparseArrayPush( -- 1147
		____array_33, -- 1147
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1148
	) -- 1148
	__TS__SparseArrayPush( -- 1148
		____array_33, -- 1148
		"- Finished At: " .. record.finishedAt, -- 1149
		"", -- 1150
		"## Validation", -- 1151
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1152
			record.completion.validation, -- 1153
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1153
		) or ({"- Not reported"})) -- 1153
	) -- 1153
	__TS__SparseArrayPush(____array_33, "", "## Recorded Evidence") -- 1153
	local ____opt_25 = record.handoffEvidence -- 1153
	__TS__SparseArrayPush( -- 1153
		____array_33, -- 1153
		table.unpack(____opt_25 and #____opt_25.modifiedFiles and __TS__ArrayMap( -- 1157
			record.handoffEvidence.modifiedFiles, -- 1158
			function(____, item) return "- modified: " .. item end -- 1158
		) or ({"- modified: none recorded"})) -- 1158
	) -- 1158
	local ____opt_27 = record.handoffEvidence -- 1158
	__TS__SparseArrayPush( -- 1158
		____array_33, -- 1158
		table.unpack(____opt_27 and ____opt_27.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1160
	) -- 1160
	local ____opt_29 = record.handoffEvidence -- 1160
	__TS__SparseArrayPush( -- 1160
		____array_33, -- 1160
		table.unpack(__TS__ArrayMap( -- 1163
			____opt_29 and ____opt_29.commands or ({}), -- 1163
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1163
		)) -- 1163
	) -- 1163
	local ____opt_31 = record.handoffEvidence -- 1163
	__TS__SparseArrayPush( -- 1163
		____array_33, -- 1163
		table.unpack(__TS__ArrayMap( -- 1164
			____opt_31 and ____opt_31.authoritativeSources or ({}), -- 1164
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1164
		)) -- 1164
	) -- 1164
	__TS__SparseArrayPush( -- 1164
		____array_33, -- 1164
		"", -- 1165
		"## Known Issues", -- 1166
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1167
			record.completion.knownIssues, -- 1167
			function(____, item) return "- " .. item end -- 1167
		) or ({"- None reported"})) -- 1167
	) -- 1167
	__TS__SparseArrayPush( -- 1167
		____array_33, -- 1167
		"", -- 1168
		"## Assumptions", -- 1169
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1170
			record.completion.assumptions, -- 1170
			function(____, item) return "- " .. item end -- 1170
		) or ({"- None reported"})) -- 1170
	) -- 1170
	__TS__SparseArrayPush(____array_33, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1170
	local lines = {__TS__SparseArraySpread(____array_33)} -- 1139
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1175
	local content = table.concat(lines, "\n") .. "\n" -- 1176
	if not Content:save(path, content) then -- 1176
		return false -- 1178
	end -- 1178
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1180
	return true -- 1181
end -- 1181
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1184
	local dir = Path(projectRoot, ".agent", "subagents") -- 1185
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1185
		return {} -- 1186
	end -- 1186
	local items = {} -- 1187
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1188
		do -- 1188
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1189
			if not Content:exist(path) or not Content:isdir(path) then -- 1189
				goto __continue214 -- 1190
			end -- 1190
			local info = readSpawnInfo( -- 1191
				projectRoot, -- 1191
				Path( -- 1191
					"subagents", -- 1191
					Path:getFilename(path) -- 1191
				) -- 1191
			) -- 1191
			if not info then -- 1191
				goto __continue214 -- 1192
			end -- 1192
			local sessionId = tonumber(info.sessionId) -- 1193
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1194
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1195
			local status = sanitizeUTF8(toStr(info.status)) -- 1196
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1196
				goto __continue214 -- 1197
			end -- 1197
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1197
				goto __continue214 -- 1198
			end -- 1198
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1199
			items[#items + 1] = { -- 1200
				sessionId = sessionId, -- 1201
				rootSessionId = infoRootSessionId, -- 1202
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1203
				title = sanitizeUTF8(toStr(info.title)), -- 1204
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1205
				goal = sanitizeUTF8(toStr(info.goal)), -- 1206
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1207
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1208
					__TS__ArrayFilter( -- 1209
						info.filesHint, -- 1209
						function(____, item) return type(item) == "string" end -- 1209
					), -- 1209
					function(____, item) return sanitizeUTF8(item) end -- 1209
				) or ({}), -- 1209
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1211
				success = info.success == true, -- 1212
				cleared = info.cleared == true, -- 1213
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1214
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1215
					"subagents", -- 1215
					Path:getFilename(path) -- 1215
				)), -- 1215
				sourceTaskId = sourceTaskId or 0, -- 1216
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1217
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1218
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1219
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1220
				completion = normalizeAgentCompletionReport(info.completion), -- 1221
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1222
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1223
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1224
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1225
			} -- 1225
		end -- 1225
		::__continue214:: -- 1225
	end -- 1225
	__TS__ArraySort( -- 1228
		items, -- 1228
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1228
	) -- 1228
	return items -- 1229
end -- 1229
function getPendingHandoffDir(projectRoot, memoryScope) -- 1232
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1233
end -- 1233
function writePendingHandoff(projectRoot, memoryScope, value) -- 1236
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1237
	if not Content:exist(dir) then -- 1237
		ensureDirRecursive(dir) -- 1239
	end -- 1239
	local path = Path(dir, value.id .. ".json") -- 1241
	local text = safeJsonEncode(value) -- 1242
	if not text then -- 1242
		return false -- 1243
	end -- 1243
	local content = text .. "\n" -- 1244
	if not Content:save(path, content) then -- 1244
		return false -- 1245
	end -- 1245
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1246
	return true -- 1247
end -- 1247
function listPendingHandoffs(projectRoot, memoryScope) -- 1250
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1251
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1251
		return {} -- 1252
	end -- 1252
	local items = {} -- 1253
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1254
		do -- 1254
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1255
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1255
				goto __continue230 -- 1256
			end -- 1256
			local text = Content:load(path) -- 1257
			if not text or __TS__StringTrim(text) == "" then -- 1257
				goto __continue230 -- 1258
			end -- 1258
			local obj = safeJsonDecode(text) -- 1259
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1259
				goto __continue230 -- 1260
			end -- 1260
			local value = obj -- 1261
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1262
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1263
			local id = sanitizeUTF8(toStr(value.id)) -- 1264
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1265
			local message = sanitizeUTF8(toStr(value.message)) -- 1266
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1267
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1268
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1269
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1269
				goto __continue230 -- 1271
			end -- 1271
			items[#items + 1] = { -- 1273
				id = id, -- 1274
				sourceSessionId = sourceSessionId, -- 1275
				sourceTitle = sourceTitle, -- 1276
				sourceTaskId = sourceTaskId, -- 1277
				message = message, -- 1278
				prompt = prompt, -- 1279
				goal = goal, -- 1280
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1281
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1282
					__TS__ArrayFilter( -- 1283
						value.filesHint, -- 1283
						function(____, item) return type(item) == "string" end -- 1283
					), -- 1283
					function(____, item) return sanitizeUTF8(item) end -- 1283
				) or ({}), -- 1283
				success = value.success == true, -- 1285
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1286
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1287
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1288
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1289
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1290
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1291
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1292
				createdAt = createdAt -- 1295
			} -- 1295
		end -- 1295
		::__continue230:: -- 1295
	end -- 1295
	__TS__ArraySort( -- 1298
		items, -- 1298
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1298
	) -- 1298
	return items -- 1299
end -- 1299
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1302
	local path = Path( -- 1303
		getPendingHandoffDir(projectRoot, memoryScope), -- 1303
		id .. ".json" -- 1303
	) -- 1303
	if Content:exist(path) then -- 1303
		if Content:remove(path) then -- 1303
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1306
		end -- 1306
	end -- 1306
end -- 1306
function normalizePromptText(prompt) -- 1311
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1312
end -- 1312
function normalizePromptTextSafe(prompt) -- 1315
	if type(prompt) == "string" then -- 1315
		local normalized = normalizePromptText(prompt) -- 1317
		if normalized ~= "" then -- 1317
			return normalized -- 1318
		end -- 1318
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1319
		if sanitized ~= "" then -- 1319
			return truncateAgentUserPrompt(sanitized) -- 1321
		end -- 1321
		return "" -- 1323
	end -- 1323
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1325
	if text == "" then -- 1325
		return "" -- 1326
	end -- 1326
	return truncateAgentUserPrompt(text) -- 1327
end -- 1327
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1330
	local sections = {} -- 1331
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1332
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1333
	local normalizedFiles = __TS__ArrayFilter( -- 1334
		__TS__ArrayMap( -- 1334
			__TS__ArrayFilter( -- 1334
				filesHint or ({}), -- 1334
				function(____, item) return type(item) == "string" end -- 1335
			), -- 1335
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1336
		), -- 1336
		function(____, item) return item ~= "" end -- 1337
	) -- 1337
	if normalizedTitle ~= "" then -- 1337
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1339
	end -- 1339
	if normalizedExpected ~= "" then -- 1339
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1342
	end -- 1342
	if #normalizedFiles > 0 then -- 1342
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1345
	end -- 1345
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1347
end -- 1347
function normalizeSessionRuntimeState(session) -- 1350
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1350
		return session -- 1352
	end -- 1352
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1352
		return session -- 1355
	end -- 1355
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1357
	if #pendingToolRows > 0 then -- 1357
		local t = now() -- 1363
		do -- 1363
			local i = 0 -- 1364
			while i < #pendingToolRows do -- 1364
				local row = pendingToolRows[i + 1] -- 1365
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1366
				result.success = false -- 1367
				result.state = "failed" -- 1368
				result.interrupted = true -- 1369
				result.message = "tool call was interrupted because the program exited before it completed." -- 1370
				DB:exec( -- 1371
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1371
					{ -- 1373
						encodeJson(result), -- 1373
						t, -- 1373
						row[1] -- 1373
					} -- 1373
				) -- 1373
				i = i + 1 -- 1364
			end -- 1364
		end -- 1364
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1376
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1377
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1378
	end -- 1378
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1385
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1386
	return __TS__ObjectAssign( -- 1387
		{}, -- 1387
		session, -- 1388
		{ -- 1387
			status = "STOPPED", -- 1389
			currentTaskStatus = "STOPPED", -- 1390
			updatedAt = now() -- 1391
		} -- 1391
	) -- 1391
end -- 1391
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1395
	DB:exec( -- 1396
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1396
		{ -- 1400
			status, -- 1401
			currentTaskId or 0, -- 1402
			currentTaskStatus or status, -- 1403
			now(), -- 1404
			sessionId -- 1405
		} -- 1405
	) -- 1405
end -- 1405
function mergeAgentMetrics(current, next) -- 1410
	return __TS__ObjectAssign({}, current or ({}), next) -- 1411
end -- 1411
function updateSessionMetrics(sessionId, metrics) -- 1417
	local session = getSessionItem(sessionId) -- 1418
	if not session then -- 1418
		return nil -- 1419
	end -- 1419
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1420
	DB:exec( -- 1421
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1421
		{ -- 1425
			encodeJson(merged), -- 1426
			now(), -- 1427
			sessionId -- 1428
		} -- 1428
	) -- 1428
	return merged -- 1431
end -- 1431
function clearSessionTokenUsage(sessionId) -- 1434
	local session = getSessionItem(sessionId) -- 1435
	if not session then -- 1435
		return nil -- 1436
	end -- 1436
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1437
	__TS__Delete(metrics, "usage") -- 1438
	DB:exec( -- 1439
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1439
		{ -- 1443
			encodeJson(metrics), -- 1444
			now(), -- 1445
			sessionId -- 1446
		} -- 1446
	) -- 1446
	return metrics -- 1449
end -- 1449
function getInitialTokenUsage(session) -- 1452
	local ____opt_34 = session.metrics -- 1452
	local usage = ____opt_34 and ____opt_34.usage -- 1453
	if not usage or (usage.requestCount or 0) <= 0 then -- 1453
		return nil -- 1454
	end -- 1454
	return { -- 1455
		inputTokens = usage.inputTokens or 0, -- 1456
		outputTokens = usage.outputTokens or 0, -- 1457
		totalTokens = usage.totalTokens, -- 1458
		cachedInputTokens = usage.cachedInputTokens, -- 1459
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1460
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1461
		requestCount = usage.requestCount or 0, -- 1462
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1463
		model = usage.model or "", -- 1464
		phase = usage.phase or "", -- 1465
		step = usage.step or 0, -- 1466
		updatedAt = usage.updatedAt or now() -- 1467
	} -- 1467
end -- 1467
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1471
	if taskId == nil or taskId <= 0 then -- 1471
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1473
		return -- 1474
	end -- 1474
	local row = getSessionRow(sessionId) -- 1476
	if not row then -- 1476
		return -- 1477
	end -- 1477
	local session = rowToSession(row) -- 1478
	if session.currentTaskId ~= taskId then -- 1478
		Log( -- 1480
			"Info", -- 1480
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1480
		) -- 1480
		return -- 1481
	end -- 1481
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1483
end -- 1483
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1486
	local t = now() -- 1487
	DB:exec( -- 1488
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1488
		{ -- 1491
			sessionId, -- 1492
			taskId or 0, -- 1493
			role, -- 1494
			sanitizeUTF8(content), -- 1495
			displayContent and sanitizeUTF8(displayContent) or "", -- 1496
			t, -- 1497
			t -- 1498
		} -- 1498
	) -- 1498
	return getLastInsertRowId() -- 1501
end -- 1501
function updateMessage(messageId, content) -- 1504
	DB:exec( -- 1505
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1505
		{ -- 1507
			sanitizeUTF8(content), -- 1507
			now(), -- 1507
			messageId -- 1507
		} -- 1507
	) -- 1507
end -- 1507
function updateUserMessageForTask(messageId, content, taskId) -- 1511
	DB:exec( -- 1512
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1512
		{ -- 1516
			sanitizeUTF8(content), -- 1516
			taskId, -- 1516
			now(), -- 1516
			messageId -- 1516
		} -- 1516
	) -- 1516
end -- 1516
function removeContinuableTaskSummary(session) -- 1573
	local taskId = session.currentTaskId -- 1574
	if taskId == nil then -- 1574
		return -- 1575
	end -- 1575
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1576
end -- 1576
function upsertAssistantMessage(sessionId, taskId, content) -- 1588
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1589
	if row and type(row[1]) == "number" then -- 1589
		updateMessage(row[1], content) -- 1596
		return row[1] -- 1597
	end -- 1597
	return insertMessage(sessionId, "assistant", content, taskId) -- 1599
end -- 1599
function upsertStep(sessionId, taskId, step, tool, patch) -- 1602
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1612
	local reason = sanitizeUTF8(patch.reason or "") -- 1616
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1617
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1618
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1619
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1620
	local statusPatch = patch.status or "" -- 1621
	local status = patch.status or "PENDING" -- 1622
	if not row then -- 1622
		local t = now() -- 1624
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1625
			sessionId, -- 1629
			taskId, -- 1630
			step, -- 1631
			tool, -- 1632
			status, -- 1633
			reason, -- 1634
			reasoningContent, -- 1635
			paramsJson, -- 1636
			resultJson, -- 1637
			patch.checkpointId or 0, -- 1638
			patch.checkpointSeq or 0, -- 1639
			filesJson, -- 1640
			t, -- 1641
			t -- 1642
		}) -- 1642
		return -- 1645
	end -- 1645
	DB:exec( -- 1647
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1647
		{ -- 1659
			tool, -- 1660
			statusPatch, -- 1661
			status, -- 1662
			reason, -- 1663
			reason, -- 1664
			reasoningContent, -- 1665
			reasoningContent, -- 1666
			paramsJson, -- 1667
			paramsJson, -- 1668
			resultJson, -- 1669
			resultJson, -- 1670
			patch.checkpointId or 0, -- 1671
			patch.checkpointId or 0, -- 1672
			patch.checkpointSeq or 0, -- 1673
			patch.checkpointSeq or 0, -- 1674
			filesJson, -- 1675
			filesJson, -- 1676
			now(), -- 1677
			row[1] -- 1678
		} -- 1678
	) -- 1678
end -- 1678
function getNextStepNumber(sessionId, taskId) -- 1683
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1684
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1688
	return math.max(0, current) + 1 -- 1689
end -- 1689
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1730
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1738
	local t = now() -- 1739
	local sqls = { -- 1740
		{ -- 1741
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1741
			{{ -- 1744
				sessionId, -- 1745
				ownerTaskId, -- 1746
				step, -- 1747
				"sub_agent_handoff", -- 1748
				"DONE", -- 1749
				sanitizeUTF8(reason), -- 1750
				encodeJson(params), -- 1751
				encodeJson(result), -- 1752
				t, -- 1753
				t -- 1754
			}} -- 1754
		}, -- 1754
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1757
	} -- 1757
	if not DB:transaction(sqls) then -- 1757
		return nil -- 1763
	end -- 1763
	return getStepItem(sessionId, ownerTaskId, step) -- 1764
end -- 1764
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1767
	if taskId <= 0 then -- 1767
		return -- 1768
	end -- 1768
	if finalSteps ~= nil and finalSteps >= 0 then -- 1768
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1770
	end -- 1770
	if not finalStatus then -- 1770
		return -- 1776
	end -- 1776
	if finalSteps ~= nil and finalSteps >= 0 then -- 1776
		DB:exec( -- 1778
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1778
			{ -- 1782
				finalStatus, -- 1782
				now(), -- 1782
				sessionId, -- 1782
				taskId, -- 1782
				finalSteps -- 1782
			} -- 1782
		) -- 1782
		return -- 1784
	end -- 1784
	DB:exec( -- 1786
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1786
		{ -- 1790
			finalStatus, -- 1790
			now(), -- 1790
			sessionId, -- 1790
			taskId -- 1790
		} -- 1790
	) -- 1790
end -- 1790
function emitAgentSessionPatch(sessionId, patch) -- 1817
	if HttpServer.wsConnectionCount == 0 then -- 1817
		return -- 1819
	end -- 1819
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1821
	if not text then -- 1821
		return -- 1826
	end -- 1826
	emit("AppWS", "Send", text) -- 1827
end -- 1827
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1830
	emitAgentSessionPatch( -- 1831
		sessionId, -- 1831
		{ -- 1831
			sessionDeleted = true, -- 1832
			relatedSessions = listRelatedSessions(rootSessionId) -- 1833
		} -- 1833
	) -- 1833
	local rootSession = getSessionItem(rootSessionId) -- 1835
	if rootSession then -- 1835
		emitAgentSessionPatch( -- 1837
			rootSessionId, -- 1837
			{ -- 1837
				session = rootSession, -- 1838
				relatedSessions = listRelatedSessions(rootSessionId) -- 1839
			} -- 1839
		) -- 1839
	end -- 1839
end -- 1839
function flushPendingSubAgentHandoffs(rootSession) -- 1844
	if rootSession.kind ~= "main" then -- 1844
		return -- 1845
	end -- 1845
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1845
		return -- 1847
	end -- 1847
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1849
	if #items == 0 then -- 1849
		return -- 1850
	end -- 1850
	local handoffTaskId = 0 -- 1851
	local previousTaskId = rootSession.currentTaskId -- 1852
	local ____rootSession_currentTaskId_38 -- 1853
	if rootSession.currentTaskId then -- 1853
		____rootSession_currentTaskId_38 = getTaskPrompt(rootSession.currentTaskId) -- 1853
	else -- 1853
		____rootSession_currentTaskId_38 = nil -- 1853
	end -- 1853
	local currentTaskPrompt = ____rootSession_currentTaskId_38 -- 1853
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1853
		handoffTaskId = rootSession.currentTaskId -- 1861
	else -- 1861
		local taskRes = Tools.createTask( -- 1863
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1863
			"code" -- 1863
		) -- 1863
		if not taskRes.success then -- 1863
			Log( -- 1865
				"Warn", -- 1865
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1865
			) -- 1865
			return -- 1866
		end -- 1866
		handoffTaskId = taskRes.taskId -- 1868
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1869
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1870
		emitAgentSessionPatch( -- 1871
			rootSession.id, -- 1871
			{session = getSessionItem(rootSession.id)} -- 1871
		) -- 1871
	end -- 1871
	do -- 1871
		local i = 0 -- 1875
		while i < #items do -- 1875
			local item = items[i + 1] -- 1876
			local step = appendHandoffSystemStep( -- 1877
				rootSession.id, -- 1878
				handoffTaskId, -- 1879
				item.sourceTaskId, -- 1880
				item.message, -- 1881
				{ -- 1882
					sourceSessionId = item.sourceSessionId, -- 1883
					sourceTitle = item.sourceTitle, -- 1884
					sourceTaskId = item.sourceTaskId, -- 1885
					success = item.success == true, -- 1886
					summary = item.message, -- 1887
					resultFilePath = item.resultFilePath or "", -- 1888
					artifactDir = item.artifactDir or "", -- 1889
					finishedAt = item.finishedAt or "", -- 1890
					changeSet = item.changeSet, -- 1891
					handoffEvidence = item.handoffEvidence, -- 1892
					memoryEntry = item.memoryEntry, -- 1893
					completion = item.completion -- 1894
				}, -- 1894
				{ -- 1896
					sourceSessionId = item.sourceSessionId, -- 1897
					sourceTitle = item.sourceTitle, -- 1898
					sourceTaskId = item.sourceTaskId, -- 1899
					prompt = item.prompt, -- 1900
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1901
					expectedOutput = item.expectedOutput or "", -- 1902
					filesHint = item.filesHint or ({}), -- 1903
					resultFilePath = item.resultFilePath or "", -- 1904
					artifactDir = item.artifactDir or "", -- 1905
					changeSet = item.changeSet, -- 1906
					handoffEvidence = item.handoffEvidence, -- 1907
					memoryEntry = item.memoryEntry, -- 1908
					completion = item.completion -- 1909
				} -- 1909
			) -- 1909
			if step then -- 1909
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1913
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1914
			else -- 1914
				Log( -- 1916
					"Warn", -- 1916
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1916
				) -- 1916
			end -- 1916
			i = i + 1 -- 1875
		end -- 1875
	end -- 1875
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1875
		cleanupTaskHeavyData(previousTaskId) -- 1920
	end -- 1920
end -- 1920
function applyEvent(sessionId, event) -- 1932
	if not getSessionItem(sessionId) then -- 1932
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 1932
			__TS__Delete(activeStopTokens, event.taskId) -- 1935
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 1936
		end -- 1936
		return -- 1938
	end -- 1938
	repeat -- 1938
		local ____switch323 = event.type -- 1938
		local metrics, startedSession -- 1938
		local ____cond323 = ____switch323 == "task_started" -- 1938
		if ____cond323 then -- 1938
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1942
			local ____event_resumed_41 -- 1943
			if event.resumed then -- 1943
				local ____opt_39 = getSessionItem(sessionId) -- 1943
				____event_resumed_41 = ____opt_39 and ____opt_39.metrics -- 1944
			else -- 1944
				____event_resumed_41 = clearSessionTokenUsage(sessionId) -- 1945
			end -- 1945
			metrics = ____event_resumed_41 -- 1943
			startedSession = getSessionItem(sessionId) -- 1946
			emitAgentSessionPatch( -- 1947
				sessionId, -- 1947
				{ -- 1947
					session = startedSession, -- 1948
					metrics = metrics, -- 1949
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1950
				} -- 1950
			) -- 1950
			break -- 1954
		end -- 1954
		____cond323 = ____cond323 or ____switch323 == "decision_made" -- 1954
		if ____cond323 then -- 1954
			upsertStep( -- 1956
				sessionId, -- 1956
				event.taskId, -- 1956
				event.step, -- 1956
				event.tool, -- 1956
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1956
			) -- 1956
			emitAgentSessionPatch( -- 1964
				sessionId, -- 1964
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1964
			) -- 1964
			break -- 1967
		end -- 1967
		____cond323 = ____cond323 or ____switch323 == "tool_started" -- 1967
		if ____cond323 then -- 1967
			upsertStep( -- 1969
				sessionId, -- 1969
				event.taskId, -- 1969
				event.step, -- 1969
				event.tool, -- 1969
				{status = "RUNNING"} -- 1969
			) -- 1969
			emitAgentSessionPatch( -- 1972
				sessionId, -- 1972
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1972
			) -- 1972
			break -- 1975
		end -- 1975
		____cond323 = ____cond323 or ____switch323 == "tool_finished" -- 1975
		if ____cond323 then -- 1975
			do -- 1975
				local ____temp_44 = event.result.success ~= true -- 1977
				if ____temp_44 then -- 1977
					local ____opt_42 = activeStopTokens[event.taskId] -- 1977
					____temp_44 = (____opt_42 and ____opt_42.stopped) == true -- 1977
				end -- 1977
				local stopped = ____temp_44 -- 1977
				upsertStep( -- 1979
					sessionId, -- 1979
					event.taskId, -- 1979
					event.step, -- 1979
					event.tool, -- 1979
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1979
				) -- 1979
				emitAgentSessionPatch( -- 1987
					sessionId, -- 1987
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1987
				) -- 1987
				break -- 1990
			end -- 1990
		end -- 1990
		____cond323 = ____cond323 or ____switch323 == "tool_progress" -- 1990
		if ____cond323 then -- 1990
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
		____cond323 = ____cond323 or ____switch323 == "checkpoint_created" -- 2006
		if ____cond323 then -- 2006
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
		____cond323 = ____cond323 or ____switch323 == "memory_compression_started" -- 2017
		if ____cond323 then -- 2017
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
		____cond323 = ____cond323 or ____switch323 == "memory_compression_finished" -- 2027
		if ____cond323 then -- 2027
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
		____cond323 = ____cond323 or ____switch323 == "metrics_updated" -- 2037
		if ____cond323 then -- 2037
			do -- 2037
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2039
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2040
				break -- 2043
			end -- 2043
		end -- 2043
		____cond323 = ____cond323 or ____switch323 == "assistant_message_updated" -- 2043
		if ____cond323 then -- 2043
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
		____cond323 = ____cond323 or ____switch323 == "assistant_message_finished" -- 2054
		if ____cond323 then -- 2054
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
		____cond323 = ____cond323 or ____switch323 == "task_waiting_for_user" -- 2066
		if ____cond323 then -- 2066
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
		____cond323 = ____cond323 or ____switch323 == "task_finished" -- 2075
		if ____cond323 then -- 2075
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
				local ____opt_45 = activeStopTokens[event.taskId or -1] -- 2082
				local stopped = (____opt_45 and ____opt_45.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2084
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2086
				local isSubSession = (session and session.kind) == "sub" -- 2089
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2090
				if isSubSession and event.taskId ~= nil then -- 2090
					finalizingSubSessionTaskIds[event.taskId] = true -- 2092
				end -- 2092
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2094
				if event.taskId ~= nil then -- 2094
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2096
					local ____finalizeTaskSteps_51 = finalizeTaskSteps -- 2097
					local ____array_50 = __TS__SparseArrayNew( -- 2097
						sessionId, -- 2098
						event.taskId, -- 2099
						type(event.steps) == "number" and math.max( -- 2100
							0, -- 2100
							math.floor(event.steps) -- 2100
						) or nil -- 2100
					) -- 2100
					local ____event_success_49 -- 2101
					if event.success then -- 2101
						____event_success_49 = nil -- 2101
					else -- 2101
						____event_success_49 = stopped and "STOPPED" or "FAILED" -- 2101
					end -- 2101
					__TS__SparseArrayPush(____array_50, ____event_success_49) -- 2101
					____finalizeTaskSteps_51(__TS__SparseArraySpread(____array_50)) -- 2097
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
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 2139
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
	local t = now() -- 2161
	DB:exec( -- 2162
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2162
		{ -- 2165
			parent.projectRoot, -- 2165
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2165
			rootId, -- 2165
			parent.id, -- 2165
			t, -- 2165
			t -- 2165
		} -- 2165
	) -- 2165
	local sessionId = getLastInsertRowId() -- 2167
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2168
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2169
	local session = getSessionItem(sessionId) -- 2170
	if not session then -- 2170
		return {success = false, message = "failed to create sub session"} -- 2172
	end -- 2172
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2174
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2175
	subStorage:writeMemory(parentStorage:readMemory()) -- 2176
	return {success = true, session = session} -- 2177
end -- 2153
function spawnSubAgentSession(request) -- 2180
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2180
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2193
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2194
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2195
		if normalizedPrompt == "" then -- 2195
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2197
		end -- 2197
		if normalizedPrompt == "" then -- 2197
			local ____Log_57 = Log -- 2204
			local ____temp_54 = #normalizedTitle -- 2204
			local ____temp_55 = #rawPrompt -- 2204
			local ____temp_56 = #toStr(request.expectedOutput) -- 2204
			local ____opt_52 = request.filesHint -- 2204
			____Log_57( -- 2204
				"Warn", -- 2204
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_54)) .. " raw_prompt_len=") .. tostring(____temp_55)) .. " expected_len=") .. tostring(____temp_56)) .. " files_hint_count=") .. tostring(____opt_52 and #____opt_52 or 0) -- 2204
			) -- 2204
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2204
		end -- 2204
		Log( -- 2207
			"Info", -- 2207
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2207
		) -- 2207
		local parentSessionId = request.parentSessionId -- 2208
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2208
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2210
			if not fallbackParent then -- 2210
				local createdMain = ____exports.createSession(request.projectRoot) -- 2212
				if createdMain.success then -- 2212
					fallbackParent = createdMain.session -- 2214
				end -- 2214
			end -- 2214
			if fallbackParent then -- 2214
				Log( -- 2218
					"Warn", -- 2218
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2218
				) -- 2218
				parentSessionId = fallbackParent.id -- 2219
			end -- 2219
		end -- 2219
		local parentSession = getSessionItem(parentSessionId) -- 2222
		if not parentSession then -- 2222
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2222
		end -- 2222
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2226
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2226
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2226
		end -- 2226
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2230
		if not created.success then -- 2230
			return ____awaiter_resolve(nil, created) -- 2230
		end -- 2230
		writeSpawnInfo( -- 2234
			created.session.projectRoot, -- 2234
			created.session.memoryScope, -- 2234
			{ -- 2234
				sessionId = created.session.id, -- 2235
				rootSessionId = created.session.rootSessionId, -- 2236
				parentSessionId = created.session.parentSessionId, -- 2237
				title = created.session.title, -- 2238
				prompt = normalizedPrompt, -- 2239
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2240
				expectedOutput = request.expectedOutput or "", -- 2241
				filesHint = request.filesHint or ({}), -- 2242
				status = "RUNNING", -- 2243
				success = false, -- 2244
				resultFilePath = "", -- 2245
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2246
				sourceTaskId = 0, -- 2247
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2248
				createdAtTs = created.session.createdAt, -- 2249
				finishedAt = "", -- 2250
				finishedAtTs = 0 -- 2251
			} -- 2251
		) -- 2251
		local sent = ____exports.sendPrompt( -- 2253
			created.session.id, -- 2253
			normalizedPrompt, -- 2253
			request.disabledAgentTools, -- 2253
			nil, -- 2253
			nil, -- 2253
			request.llmConfig -- 2253
		) -- 2253
		if not sent.success then -- 2253
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2253
		end -- 2253
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2253
	end) -- 2253
end -- 2253
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2358
	local rootSession = getRootSessionItem(session.id) -- 2359
	if not rootSession then -- 2359
		return -- 2360
	end -- 2360
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2361
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2362
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2363
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2364
	local queueResult = writePendingHandoff( -- 2365
		rootSession.projectRoot, -- 2365
		rootSession.memoryScope, -- 2365
		{ -- 2365
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2366
			sourceSessionId = session.id, -- 2367
			sourceTitle = session.title, -- 2368
			sourceTaskId = taskId, -- 2369
			message = summary, -- 2370
			prompt = result.prompt, -- 2371
			goal = result.goal, -- 2372
			expectedOutput = result.expectedOutput or "", -- 2373
			filesHint = result.filesHint or ({}), -- 2374
			success = result.success, -- 2375
			resultFilePath = result.resultFilePath, -- 2376
			artifactDir = result.artifactDir, -- 2377
			finishedAt = result.finishedAt, -- 2378
			changeSet = changeSet, -- 2379
			handoffEvidence = result.handoffEvidence, -- 2380
			memoryEntry = result.memoryEntry, -- 2381
			completion = result.completion, -- 2382
			createdAt = createdAt -- 2383
		} -- 2383
	) -- 2383
	if not queueResult then -- 2383
		Log( -- 2386
			"Warn", -- 2386
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2386
		) -- 2386
		return -- 2387
	end -- 2387
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2387
		addTaskReference(rootSession.currentTaskId, taskId) -- 2390
	end -- 2390
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2390
		flushPendingSubAgentHandoffs(rootSession) -- 2393
	end -- 2393
end -- 2393
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2397
	if forceHandoff == nil then -- 2397
		forceHandoff = false -- 2403
	end -- 2403
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2403
		local rootSessionId = getSessionRootId(session) -- 2405
		local rootSession = getRootSessionItem(session.id) -- 2406
		if not rootSession then -- 2406
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2406
		end -- 2406
		local spawnInfo = getSessionSpawnInfo(session) -- 2410
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2411
		local finishedAtTs = now() -- 2412
		local resultText = sanitizeUTF8(message) -- 2413
		local changeSet = getTaskChangeSetSummary(taskId) -- 2414
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2415
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2416
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2420
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2420
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2422
		end -- 2422
		local completed = success and completionReport.outcome == "completed" -- 2430
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2431
		local record = { -- 2434
			sessionId = session.id, -- 2435
			rootSessionId = rootSessionId, -- 2436
			parentSessionId = session.parentSessionId, -- 2437
			title = session.title, -- 2438
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2439
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2440
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2441
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2442
			status = recordStatus, -- 2443
			success = completed, -- 2444
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2445
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2446
			sourceTaskId = taskId, -- 2447
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2448
			finishedAt = finishedAt, -- 2449
			createdAtTs = session.createdAt, -- 2450
			finishedAtTs = finishedAtTs, -- 2451
			changeSet = changeSet, -- 2452
			handoffEvidence = handoffEvidence, -- 2453
			completion = completionReport -- 2454
		} -- 2454
		local ____record_success_70 -- 2456
		if record.success then -- 2456
			____record_success_70 = buildStructuredSubAgentMemoryEntry(record) -- 2456
		else -- 2456
			____record_success_70 = nil -- 2456
		end -- 2456
		record.memoryEntry = ____record_success_70 -- 2456
		if not writeSubAgentResultFile(session, record, resultText) then -- 2456
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2456
		end -- 2456
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2456
			sessionId = record.sessionId, -- 2461
			rootSessionId = record.rootSessionId, -- 2462
			parentSessionId = record.parentSessionId, -- 2463
			title = record.title, -- 2464
			prompt = record.prompt, -- 2465
			goal = record.goal, -- 2466
			expectedOutput = record.expectedOutput or "", -- 2467
			filesHint = record.filesHint or ({}), -- 2468
			status = record.status, -- 2469
			success = record.success, -- 2470
			resultFilePath = record.resultFilePath, -- 2471
			artifactDir = record.artifactDir, -- 2472
			sourceTaskId = record.sourceTaskId, -- 2473
			createdAt = record.createdAt, -- 2474
			finishedAt = record.finishedAt, -- 2475
			createdAtTs = record.createdAtTs, -- 2476
			finishedAtTs = record.finishedAtTs, -- 2477
			changeSet = record.changeSet, -- 2478
			handoffEvidence = record.handoffEvidence, -- 2479
			memoryEntry = record.memoryEntry, -- 2480
			memoryEntryError = record.memoryEntryError, -- 2481
			completion = record.completion -- 2482
		}) then -- 2482
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2482
		end -- 2482
		if success or forceHandoff then -- 2482
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2487
			deleteSessionRecords(session.id, true) -- 2488
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2489
		end -- 2489
		return ____awaiter_resolve(nil, {success = true}) -- 2489
	end) -- 2489
end -- 2489
function stopClearedSubSession(session, taskId) -- 2494
	local spawnInfo = getSessionSpawnInfo(session) -- 2495
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2496
	local rootSessionId = getSessionRootId(session) -- 2497
	Tools.setTaskStatus(taskId, "STOPPED") -- 2498
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2499
	if not writeSpawnInfo( -- 2499
		session.projectRoot, -- 2500
		session.memoryScope, -- 2500
		{ -- 2500
			sessionId = session.id, -- 2501
			rootSessionId = rootSessionId, -- 2502
			parentSessionId = session.parentSessionId, -- 2503
			title = session.title, -- 2504
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2505
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2506
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2507
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2508
			status = "STOPPED", -- 2509
			success = false, -- 2510
			cleared = true, -- 2511
			resultFilePath = "", -- 2512
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2513
			sourceTaskId = taskId, -- 2514
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2515
			finishedAt = finishedAt, -- 2516
			createdAtTs = session.createdAt, -- 2517
			finishedAtTs = now() -- 2518
		} -- 2518
	) then -- 2518
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2520
	end -- 2520
	deleteSessionRecords(session.id, true) -- 2522
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2523
	return {success = true} -- 2524
end -- 2524
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2527
	local session = getSessionItem(sessionId) -- 2528
	if not session then -- 2528
		return {success = false, message = "session not found"} -- 2530
	end -- 2530
	if getPendingQuestionnaire(sessionId) then -- 2530
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2532
	end -- 2532
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2532
		return {success = false, message = "session task is finalizing"} -- 2534
	end -- 2534
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2534
		return {success = false, message = "session task is still running"} -- 2537
	end -- 2537
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2539
	if normalizedPrompt == "" and session.kind == "sub" then -- 2539
		local spawnInfo = getSessionSpawnInfo(session) -- 2541
		if spawnInfo then -- 2541
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2543
			if normalizedPrompt == "" then -- 2543
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2545
			end -- 2545
		end -- 2545
	end -- 2545
	if normalizedPrompt == "" then -- 2545
		return {success = false, message = "prompt is empty"} -- 2554
	end -- 2554
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2556
	if session.workMode ~= nextWorkMode then -- 2556
		DB:exec( -- 2558
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2558
			{ -- 2558
				nextWorkMode, -- 2558
				now(), -- 2558
				session.id -- 2558
			} -- 2558
		) -- 2558
		session.workMode = nextWorkMode -- 2559
	end -- 2559
	return startPromptTask( -- 2561
		session, -- 2561
		normalizedPrompt, -- 2561
		nil, -- 2561
		normalizeDisabledAgentTools(disabledAgentTools), -- 2561
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2561
	) -- 2561
end -- 2527
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2614
	if disabledAgentTools == nil then -- 2614
		disabledAgentTools = {} -- 2618
	end -- 2618
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2621
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2622
	if not llmConfigRes.success then -- 2622
		return {success = false, message = llmConfigRes.message} -- 2626
	end -- 2626
	local llmConfig = llmConfigRes.config -- 2628
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2629
	if not llmConfigValidation.success then -- 2629
		return llmConfigValidation -- 2631
	end -- 2631
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2633
	if not taskRes.success then -- 2633
		return {success = false, message = taskRes.message} -- 2636
	end -- 2636
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2636
		removeContinuableTaskSummary(session) -- 2638
	end -- 2638
	local taskId = taskRes.taskId -- 2640
	local ____temp_91 -- 2641
	if (options and options.existingTaskId) == nil then -- 2641
		____temp_91 = session.currentTaskId -- 2641
	else -- 2641
		____temp_91 = nil -- 2641
	end -- 2641
	local previousTaskId = ____temp_91 -- 2641
	local useChineseResponse = getDefaultUseChineseResponse() -- 2642
	if existingUserMessageId ~= nil then -- 2642
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2644
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2644
		insertMessage( -- 2646
			session.id, -- 2646
			"user", -- 2646
			normalizedPrompt, -- 2646
			taskId, -- 2646
			options and options.displayContent -- 2646
		) -- 2646
	end -- 2646
	local stopToken = {stopped = false} -- 2648
	activeStopTokens[taskId] = stopToken -- 2649
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2650
	if previousTaskId and previousTaskId ~= taskId then -- 2650
		cleanupTaskHeavyData(previousTaskId) -- 2652
	end -- 2652
	local ____runCodingAgent_120 = runCodingAgent -- 2654
	local ____normalizedPrompt_113 = normalizedPrompt -- 2655
	local ____temp_114 = options and options.resumeConversation -- 2656
	local ____temp_115 = (options and options.existingTaskId) ~= nil -- 2657
	local ____temp_116 = options and options.initialStep -- 2658
	local ____temp_117 = options and options.initialAgentStepCount -- 2659
	local ____temp_108 -- 2660
	if (options and options.existingTaskId) ~= nil then -- 2660
		____temp_108 = getInitialTokenUsage(session) -- 2660
	else -- 2660
		____temp_108 = nil -- 2660
	end -- 2660
	____runCodingAgent_120( -- 2654
		{ -- 2654
			prompt = ____normalizedPrompt_113, -- 2655
			resumeConversation = ____temp_114, -- 2656
			resumeTask = ____temp_115, -- 2657
			initialStep = ____temp_116, -- 2658
			initialAgentStepCount = ____temp_117, -- 2659
			initialTokenUsage = ____temp_108, -- 2660
			workDir = session.projectRoot, -- 2661
			useChineseResponse = useChineseResponse, -- 2662
			taskId = taskId, -- 2663
			sessionId = session.id, -- 2664
			memoryScope = session.memoryScope, -- 2665
			role = session.kind, -- 2666
			maxSteps = options and options.maxSteps, -- 2667
			disabledAgentTools = disabledAgentTools, -- 2668
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2669
			llmConfig = llmConfig, -- 2670
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2671
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2674
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2677
			stopToken = stopToken, -- 2678
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2679
		}, -- 2679
		function(result) -- 2680
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2680
				local nextSession = getSessionItem(session.id) -- 2681
				if nextSession and nextSession.kind == "sub" then -- 2681
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2681
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2684
						if not stopped.success then -- 2684
							Log( -- 2686
								"Warn", -- 2686
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2686
							) -- 2686
							emitAgentSessionPatch( -- 2687
								session.id, -- 2687
								{session = getSessionItem(session.id)} -- 2687
							) -- 2687
						end -- 2687
						__TS__Delete(activeStopTokens, taskId) -- 2691
						return ____awaiter_resolve(nil) -- 2691
					end -- 2691
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2694
					emitAgentSessionPatch( -- 2695
						session.id, -- 2695
						{session = getSessionItem(session.id)} -- 2695
					) -- 2695
					local finalized = __TS__Await(finalizeSubSession( -- 2698
						nextSession, -- 2699
						taskId, -- 2700
						result.success, -- 2701
						result.message, -- 2702
						result.completion, -- 2703
						(options and options.forceSubAgentHandoff) == true -- 2704
					)) -- 2704
					if not finalized.success then -- 2704
						Log( -- 2707
							"Warn", -- 2707
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2707
						) -- 2707
					end -- 2707
					local finalizedSession = getSessionItem(session.id) -- 2709
					if finalizedSession then -- 2709
						local stopped = stopToken.stopped == true -- 2711
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2712
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2715
						emitAgentSessionPatch( -- 2716
							session.id, -- 2716
							{session = getSessionItem(session.id)} -- 2716
						) -- 2716
					end -- 2716
					__TS__Delete(activeStopTokens, taskId) -- 2720
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2721
				end -- 2721
				local fallbackSession = getSessionItem(session.id) -- 2723
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2723
					applyEvent(session.id, { -- 2729
						type = "task_finished", -- 2730
						sessionId = session.id, -- 2731
						taskId = result.taskId, -- 2732
						success = false, -- 2733
						message = result.message, -- 2734
						steps = result.steps -- 2735
					}) -- 2735
				end -- 2735
			end) -- 2735
		end -- 2680
	) -- 2680
	return {success = true, sessionId = session.id, taskId = taskId} -- 2739
end -- 2739
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2891
	local lines = {} -- 2892
	do -- 2892
		local i = 0 -- 2893
		while i < #questionnaire.schema.questions do -- 2893
			local question = questionnaire.schema.questions[i + 1] -- 2894
			local answer = __TS__ArrayFind( -- 2895
				answers, -- 2895
				function(____, item) return item.questionId == question.id end -- 2895
			) -- 2895
			local answerText = "已跳过" -- 2896
			if answer and answer.status == "answered" then -- 2896
				local parts = {} -- 2898
				do -- 2898
					local j = 0 -- 2899
					while j < #(answer.selectedOptionIds or ({})) do -- 2899
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2900
						local option = __TS__ArrayFind( -- 2901
							question.options or ({}), -- 2901
							function(____, item) return item.id == optionId end -- 2901
						) -- 2901
						if option then -- 2901
							parts[#parts + 1] = option.label -- 2902
						end -- 2902
						j = j + 1 -- 2899
					end -- 2899
				end -- 2899
				if answer.otherText then -- 2899
					parts[#parts + 1] = answer.otherText -- 2904
				end -- 2904
				if answer.text then -- 2904
					parts[#parts + 1] = answer.text -- 2905
				end -- 2905
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2906
			end -- 2906
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2908
			i = i + 1 -- 2893
		end -- 2893
	end -- 2893
	return table.concat(lines, "\n\n") -- 2910
end -- 2910
function ____exports.listRunningSubAgents(request) -- 3154
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3154
		local session = getSessionItem(request.sessionId) -- 3162
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3162
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3164
		end -- 3164
		if not session then -- 3164
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3164
		end -- 3164
		local rootSession = getRootSessionItem(session.id) -- 3169
		if not rootSession then -- 3169
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3169
		end -- 3169
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3173
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3174
		local limit = math.max( -- 3175
			1, -- 3175
			math.floor(tonumber(request.limit) or 5) -- 3175
		) -- 3175
		local offset = math.max( -- 3176
			0, -- 3176
			math.floor(tonumber(request.offset) or 0) -- 3176
		) -- 3176
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3177
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3178
		local runningSessions = {} -- 3185
		do -- 3185
			local i = 0 -- 3186
			while i < #rows do -- 3186
				do -- 3186
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3187
					if current.currentTaskStatus ~= "RUNNING" then -- 3187
						goto __continue521 -- 3189
					end -- 3189
					local spawnInfo = getSessionSpawnInfo(current) -- 3191
					runningSessions[#runningSessions + 1] = { -- 3192
						sessionId = current.id, -- 3193
						title = current.title, -- 3194
						parentSessionId = current.parentSessionId, -- 3195
						rootSessionId = current.rootSessionId, -- 3196
						status = "RUNNING", -- 3197
						currentTaskId = current.currentTaskId, -- 3198
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3199
						goal = spawnInfo and spawnInfo.goal, -- 3200
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3201
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3202
						createdAt = current.createdAt, -- 3203
						updatedAt = current.updatedAt -- 3204
					} -- 3204
				end -- 3204
				::__continue521:: -- 3204
				i = i + 1 -- 3186
			end -- 3186
		end -- 3186
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3207
		local completedSessions = __TS__ArrayMap( -- 3208
			completedRecords, -- 3208
			function(____, record) return { -- 3208
				sessionId = record.sessionId, -- 3209
				title = record.title, -- 3210
				parentSessionId = record.parentSessionId, -- 3211
				rootSessionId = record.rootSessionId, -- 3212
				status = record.status, -- 3213
				goal = record.goal, -- 3214
				expectedOutput = record.expectedOutput, -- 3215
				filesHint = record.filesHint, -- 3216
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3217
				success = record.success, -- 3218
				cleared = record.cleared, -- 3219
				resultFilePath = record.resultFilePath, -- 3220
				artifactDir = record.artifactDir, -- 3221
				finishedAt = record.finishedAt, -- 3222
				createdAt = record.createdAtTs, -- 3223
				updatedAt = record.finishedAtTs -- 3224
			} end -- 3224
		) -- 3224
		local merged = {} -- 3226
		if status == "running" then -- 3226
			merged = runningSessions -- 3228
		elseif status == "done" then -- 3228
			merged = __TS__ArrayFilter( -- 3230
				completedSessions, -- 3230
				function(____, item) return item.status == "DONE" end -- 3230
			) -- 3230
		elseif status == "failed" then -- 3230
			merged = __TS__ArrayFilter( -- 3232
				completedSessions, -- 3232
				function(____, item) return item.status == "FAILED" end -- 3232
			) -- 3232
		elseif status == "stopped" then -- 3232
			merged = __TS__ArrayFilter( -- 3234
				completedSessions, -- 3234
				function(____, item) return item.status == "STOPPED" end -- 3234
			) -- 3234
		elseif status == "all" then -- 3234
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3236
		else -- 3236
			local runningKeys = {} -- 3238
			do -- 3238
				local i = 0 -- 3239
				while i < #runningSessions do -- 3239
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3240
					i = i + 1 -- 3239
				end -- 3239
			end -- 3239
			local latestCompletedByKey = {} -- 3242
			do -- 3242
				local i = 0 -- 3243
				while i < #completedSessions do -- 3243
					do -- 3243
						local item = completedSessions[i + 1] -- 3244
						local key = getSubAgentDisplayKey(item) -- 3245
						if runningKeys[key] then -- 3245
							goto __continue536 -- 3247
						end -- 3247
						local current = latestCompletedByKey[key] -- 3249
						if not current or item.updatedAt > current.updatedAt then -- 3249
							latestCompletedByKey[key] = item -- 3251
						end -- 3251
					end -- 3251
					::__continue536:: -- 3251
					i = i + 1 -- 3243
				end -- 3243
			end -- 3243
			local latestCompleted = {} -- 3254
			for ____, item in pairs(latestCompletedByKey) do -- 3255
				latestCompleted[#latestCompleted + 1] = item -- 3256
			end -- 3256
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3258
		end -- 3258
		if query ~= "" then -- 3258
			merged = __TS__ArrayFilter( -- 3261
				merged, -- 3261
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3261
			) -- 3261
		end -- 3261
		__TS__ArraySort( -- 3267
			merged, -- 3267
			function(____, a, b) -- 3267
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3267
					return -1 -- 3268
				end -- 3268
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3268
					return 1 -- 3269
				end -- 3269
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3269
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3271
				end -- 3271
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3273
			end -- 3267
		) -- 3267
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3275
		return ____awaiter_resolve(nil, { -- 3275
			success = true, -- 3277
			rootSessionId = rootSession.id, -- 3278
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3279
			status = status, -- 3280
			limit = limit, -- 3281
			offset = offset, -- 3282
			hasMore = offset + limit < #merged, -- 3283
			sessions = paged -- 3284
		}) -- 3284
	end) -- 3284
end -- 3154
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 267
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 268
SPAWN_INFO_FILE = "SPAWN.json" -- 269
RESULT_FILE = "RESULT.md" -- 270
PENDING_HANDOFF_DIR = "pending-handoffs" -- 271
MAX_CONCURRENT_SUB_AGENTS = 4 -- 272
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 273
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 274
activeStopTokens = {} -- 324
finalizingSubSessionTaskIds = {} -- 325
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 326
now = function() return os.time() end -- 327
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 995
	if projectRoot == oldRoot then -- 995
		return newRoot -- 997
	end -- 997
	for ____, separator in ipairs({"/", "\\"}) do -- 999
		local prefix = oldRoot .. separator -- 1000
		if __TS__StringStartsWith(projectRoot, prefix) then -- 1000
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1002
		end -- 1002
	end -- 1002
	return nil -- 1005
end -- 995
local function clearSessionAfterMessage(sessionId, message) -- 1520
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1521
	local removedStepIds = {} -- 1529
	do -- 1529
		local i = 0 -- 1530
		while i < #removedStepRows do -- 1530
			local row = removedStepRows[i + 1] -- 1531
			if type(row[1]) == "number" then -- 1531
				removedStepIds[#removedStepIds + 1] = row[1] -- 1533
			end -- 1533
			i = i + 1 -- 1530
		end -- 1530
	end -- 1530
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1536
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1544
	return removedStepIds -- 1549
end -- 1520
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1552
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1553
	local persisted = storage:readSessionState() -- 1554
	local userIndex = -1 -- 1555
	do -- 1555
		local i = #persisted.messages - 1 -- 1556
		while i >= 0 do -- 1556
			if persisted.messages[i + 1].role == "user" then -- 1556
				userIndex = i -- 1558
				break -- 1559
			end -- 1559
			i = i - 1 -- 1556
		end -- 1556
	end -- 1556
	if userIndex < 0 then -- 1556
		return -- 1562
	end -- 1562
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1563
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1564
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1565
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1570
end -- 1552
local function listCurrentTaskCheckpoints(sessionId) -- 1582
	local session = getSessionItem(sessionId) -- 1583
	local taskId = session and session.currentTaskId -- 1584
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1585
end -- 1582
local function getAgentStepCount(sessionId, taskId) -- 1692
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1693
		sessionId, -- 1698
		taskId, -- 1699
		"compress_memory", -- 1700
		"merge_memory", -- 1701
		"sub_agent_handoff", -- 1702
		"questionnaire_answer", -- 1703
		"message" -- 1704
	}) -- 1704
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1707
end -- 1692
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1710
	if status == nil then -- 1710
		status = "DONE" -- 1718
	end -- 1718
	local step = getNextStepNumber(sessionId, taskId) -- 1720
	upsertStep( -- 1721
		sessionId, -- 1721
		taskId, -- 1721
		step, -- 1721
		tool, -- 1721
		{status = status, reason = reason, params = params, result = result} -- 1721
	) -- 1721
	return getStepItem(sessionId, taskId, step) -- 1727
end -- 1710
local function sanitizeStoredSteps(sessionId) -- 1794
	DB:exec( -- 1795
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1795
		{ -- 1813
			now(), -- 1813
			sessionId -- 1813
		} -- 1813
	) -- 1813
end -- 1794
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2265
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2265
		return {success = false, message = "invalid projectRoot"} -- 2267
	end -- 2267
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2269
	for ____, row in ipairs(rows) do -- 2270
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2271
		if sessionId > 0 then -- 2271
			deleteSessionRecords(sessionId) -- 2273
		end -- 2273
	end -- 2273
	return {success = true, deleted = #rows} -- 2276
end -- 2265
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2279
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2279
		return {success = false, message = "invalid projectRoot"} -- 2281
	end -- 2281
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2283
	local renamed = 0 -- 2284
	for ____, row in ipairs(rows) do -- 2285
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2286
		local projectRoot = toStr(row[2]) -- 2287
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2288
		if sessionId > 0 and nextProjectRoot then -- 2288
			DB:exec( -- 2290
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2290
				{ -- 2292
					nextProjectRoot, -- 2292
					Path:getFilename(nextProjectRoot), -- 2292
					now(), -- 2292
					sessionId -- 2292
				} -- 2292
			) -- 2292
			renamed = renamed + 1 -- 2294
		end -- 2294
	end -- 2294
	return {success = true, renamed = renamed} -- 2297
end -- 2279
function ____exports.getSession(sessionId) -- 2300
	local session = getSessionItem(sessionId) -- 2301
	if not session then -- 2301
		return {success = false, message = "session not found"} -- 2303
	end -- 2303
	local restored = restorePendingQuestionnaireState(session) -- 2305
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2306
	local relatedSessions = listRelatedSessions(sessionId) -- 2307
	sanitizeStoredSteps(sessionId) -- 2308
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2309
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2316
	local ____relatedSessions_59 = relatedSessions -- 2327
	local ____temp_58 -- 2328
	if normalizedSession.kind == "sub" then -- 2328
		____temp_58 = getSessionSpawnInfo(normalizedSession) -- 2328
	else -- 2328
		____temp_58 = nil -- 2328
	end -- 2328
	return { -- 2324
		success = true, -- 2325
		session = normalizedSession, -- 2326
		relatedSessions = ____relatedSessions_59, -- 2327
		spawnInfo = ____temp_58, -- 2328
		messages = __TS__ArrayMap( -- 2329
			messages, -- 2329
			function(____, row) return rowToMessage(row) end -- 2329
		), -- 2329
		steps = __TS__ArrayMap( -- 2330
			steps, -- 2330
			function(____, row) return rowToStep(row) end -- 2330
		), -- 2330
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2331
		pendingQuestionnaire = restored.questionnaire, -- 2332
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2333
	} -- 2333
end -- 2300
function ____exports.setWorkMode(sessionId, workMode) -- 2338
	local session = getSessionItem(sessionId) -- 2339
	if not session then -- 2339
		return {success = false, message = "session not found"} -- 2340
	end -- 2340
	if session.kind ~= "main" then -- 2340
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2341
	end -- 2341
	if workMode ~= "code" and workMode ~= "plan" then -- 2341
		return {success = false, message = "invalid work mode"} -- 2342
	end -- 2342
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2343
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2343
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2345
	end -- 2345
	if getPendingQuestionnaire(sessionId) then -- 2345
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2348
	end -- 2348
	if normalizedSession.workMode ~= workMode then -- 2348
		DB:exec( -- 2351
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2351
			{ -- 2351
				workMode, -- 2351
				now(), -- 2351
				sessionId -- 2351
			} -- 2351
		) -- 2351
	end -- 2351
	local updated = getSessionItem(sessionId) -- 2353
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2354
	return { -- 2355
		success = true, -- 2355
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2355
	} -- 2355
end -- 2338
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2564
	local session = getSessionItem(sessionId) -- 2565
	if not session then -- 2565
		return {success = false, message = "session not found"} -- 2567
	end -- 2567
	if getPendingQuestionnaire(sessionId) then -- 2567
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2569
	end -- 2569
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2569
		return {success = false, message = "session task is finalizing"} -- 2571
	end -- 2571
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2571
		return {success = false, message = "session task is still stopping"} -- 2574
	end -- 2574
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2574
		return {success = false, message = "session task is not continuable"} -- 2577
	end -- 2577
	if session.currentTaskId == nil then -- 2577
		return {success = false, message = "session task not found"} -- 2580
	end -- 2580
	local taskId = session.currentTaskId -- 2582
	return startPromptTask( -- 2583
		session, -- 2584
		"", -- 2585
		nil, -- 2586
		normalizeDisabledAgentTools(disabledAgentTools), -- 2587
		{ -- 2588
			workMode = session.workMode, -- 2589
			persistUserMessage = false, -- 2590
			resumeConversation = true, -- 2591
			existingTaskId = taskId, -- 2592
			initialStep = math.max( -- 2593
				0, -- 2593
				getNextStepNumber(session.id, taskId) - 1 -- 2593
			), -- 2593
			initialAgentStepCount = getAgentStepCount(session.id, taskId), -- 2594
			llmConfigId = llmConfigId -- 2595
		} -- 2595
	) -- 2595
end -- 2564
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2742
	local session = getSessionItem(sessionId) -- 2743
	if not session then -- 2743
		return {success = false, message = "session not found"} -- 2745
	end -- 2745
	if session.kind ~= "sub" then -- 2745
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2748
	end -- 2748
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2748
		return {success = false, message = "session task is finalizing"} -- 2751
	end -- 2751
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2753
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2753
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2758
	end -- 2758
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2758
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2761
	end -- 2761
	local disabledAgentTools = __TS__ArrayFilter( -- 2763
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2763
		function(____, tool) return tool ~= "finish" end -- 2764
	) -- 2764
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2765
	return startPromptTask( -- 2768
		session, -- 2768
		prompt, -- 2768
		nil, -- 2768
		disabledAgentTools, -- 2768
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2768
	) -- 2768
end -- 2742
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2775
	local session = getSessionItem(sessionId) -- 2776
	if not session then -- 2776
		return {success = false, message = "session not found"} -- 2778
	end -- 2778
	if getPendingQuestionnaire(sessionId) then -- 2778
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2780
	end -- 2780
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2780
		return {success = false, message = "session task is finalizing"} -- 2782
	end -- 2782
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2782
		return {success = false, message = "session task is still running"} -- 2785
	end -- 2785
	local message = getMessageItem(messageId) -- 2787
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2787
		return {success = false, message = "message not found"} -- 2789
	end -- 2789
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2791
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2797
	if latestUserMessageId ~= messageId then -- 2797
		return {success = false, message = "only the latest user prompt can be edited"} -- 2799
	end -- 2799
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2801
	if normalizedPrompt == "" then -- 2801
		return {success = false, message = "prompt is empty"} -- 2803
	end -- 2803
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2805
	if session.workMode ~= nextWorkMode then -- 2805
		DB:exec( -- 2807
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2807
			{ -- 2807
				nextWorkMode, -- 2807
				now(), -- 2807
				session.id -- 2807
			} -- 2807
		) -- 2807
		session.workMode = nextWorkMode -- 2808
	end -- 2808
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2810
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2811
	local result = startPromptTask( -- 2812
		session, -- 2812
		normalizedPrompt, -- 2812
		messageId, -- 2812
		normalizeDisabledAgentTools(disabledAgentTools), -- 2812
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2812
	) -- 2812
	if result.success and #removedStepIds > 0 then -- 2812
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2814
	end -- 2814
	return result -- 2816
end -- 2775
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2821
	if status == "dismissed" then -- 2821
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2827
	end -- 2827
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2829
end -- 2821
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2832
	if status == "dismissed" then -- 2832
		return { -- 2838
			success = true, -- 2839
			status = "dismissed", -- 2840
			source = "user", -- 2841
			questionnaireId = questionnaire.id, -- 2842
			title = questionnaire.schema.title, -- 2843
			answers = {}, -- 2844
			responses = {}, -- 2845
			displayText = "用户关闭了调查问卷，未作答。", -- 2846
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2847
		} -- 2847
	end -- 2847
	local responses = {} -- 2850
	do -- 2850
		local i = 0 -- 2851
		while i < #questionnaire.schema.questions do -- 2851
			do -- 2851
				local question = questionnaire.schema.questions[i + 1] -- 2852
				local answer = __TS__ArrayFind( -- 2853
					answers, -- 2853
					function(____, item) return item.questionId == question.id end -- 2853
				) -- 2853
				if not answer or answer.status == "skipped" then -- 2853
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2855
					goto __continue447 -- 2860
				end -- 2860
				local selectedOptionLabels = {} -- 2862
				do -- 2862
					local j = 0 -- 2863
					while j < #(answer.selectedOptionIds or ({})) do -- 2863
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2864
						local option = __TS__ArrayFind( -- 2865
							question.options or ({}), -- 2865
							function(____, item) return item.id == optionId end -- 2865
						) -- 2865
						if option then -- 2865
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2866
						end -- 2866
						j = j + 1 -- 2863
					end -- 2863
				end -- 2863
				responses[#responses + 1] = { -- 2868
					questionId = question.id, -- 2869
					prompt = question.prompt, -- 2870
					status = "answered", -- 2871
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2872
					selectedOptionLabels = selectedOptionLabels, -- 2873
					otherText = answer.otherText, -- 2874
					text = answer.text -- 2875
				} -- 2875
			end -- 2875
			::__continue447:: -- 2875
			i = i + 1 -- 2851
		end -- 2851
	end -- 2851
	return { -- 2878
		success = true, -- 2879
		status = "answered", -- 2880
		source = "user", -- 2881
		questionnaireId = questionnaire.id, -- 2882
		title = questionnaire.schema.title, -- 2883
		answers = answers, -- 2884
		responses = responses, -- 2885
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2886
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2887
	} -- 2887
end -- 2832
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2913
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2919
	local persisted = storage:readSessionState() -- 2920
	local messages = __TS__ArraySlice(persisted.messages) -- 2921
	local toolResultIndex = -1 -- 2922
	local existingResult -- 2923
	do -- 2923
		local i = #messages - 1 -- 2924
		while i >= 0 do -- 2924
			do -- 2924
				local message = messages[i + 1] -- 2925
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2925
					goto __continue467 -- 2926
				end -- 2926
				local decoded = safeJsonDecode(message.content) -- 2927
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2927
					goto __continue467 -- 2928
				end -- 2928
				local row = decoded -- 2929
				if row.questionnaireId ~= questionnaire.id then -- 2929
					goto __continue467 -- 2930
				end -- 2930
				toolResultIndex = i -- 2931
				existingResult = row -- 2932
				break -- 2933
			end -- 2933
			::__continue467:: -- 2933
			i = i - 1 -- 2924
		end -- 2924
	end -- 2924
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2935
	local guidance = {} -- 2936
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2936
		guidance[#guidance + 1] = existingResult.guidance -- 2938
	end -- 2938
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2938
		guidance[#guidance + 1] = result.guidance -- 2941
	end -- 2941
	result.guidance = table.concat(guidance, "\n") -- 2943
	if toolResultIndex < 0 then -- 2943
		messages[#messages + 1] = { -- 2945
			role = "user", -- 2946
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 2947
		} -- 2947
		toolResultIndex = #messages - 1 -- 2949
	else -- 2949
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2951
			{}, -- 2951
			messages[toolResultIndex + 1], -- 2952
			{content = encodeJson(result)} -- 2951
		) -- 2951
	end -- 2951
	local pairStartIndex = toolResultIndex -- 2957
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2958
	if toolCallId and toolCallId ~= "" then -- 2958
		do -- 2958
			local i = toolResultIndex - 1 -- 2960
			while i >= 0 do -- 2960
				do -- 2960
					local message = messages[i + 1] -- 2961
					if message.role ~= "assistant" or not message.tool_calls then -- 2961
						goto __continue477 -- 2962
					end -- 2962
					if __TS__ArraySome( -- 2962
						message.tool_calls, -- 2963
						function(____, call) return call.id == toolCallId end -- 2963
					) then -- 2963
						pairStartIndex = i -- 2964
						break -- 2965
					end -- 2965
				end -- 2965
				::__continue477:: -- 2965
				i = i - 1 -- 2960
			end -- 2960
		end -- 2960
	end -- 2960
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2969
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2972
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2976
	upsertStep( -- 2978
		session.id, -- 2978
		questionnaire.taskId, -- 2978
		questionnaire.step, -- 2978
		"ask_user", -- 2978
		{status = "DONE", result = result} -- 2978
	) -- 2978
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 2982
	upsertStep( -- 2983
		session.id, -- 2983
		questionnaire.taskId, -- 2983
		answerStep, -- 2983
		"questionnaire_answer", -- 2983
		{status = "DONE", result = result} -- 2983
	) -- 2983
	return {success = true, answerStep = answerStep, result = result} -- 2987
end -- 2913
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 2990
	local session = getSessionItem(sessionId) -- 2991
	if not session then -- 2991
		return {success = false, message = "session not found"} -- 2992
	end -- 2992
	if session.kind ~= "main" then -- 2992
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2993
	end -- 2993
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2994
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2994
		return {success = false, message = "pending questionnaire not found or already handled"} -- 2996
	end -- 2996
	local llmConfigRes = getLLMConfig(llmConfigId) -- 2998
	if not llmConfigRes.success then -- 2998
		return {success = false, message = llmConfigRes.message} -- 2999
	end -- 2999
	if not removePendingQuestionnaire(session) then -- 2999
		return {success = false, message = "failed to consume questionnaire file"} -- 3000
	end -- 3000
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3001
	if not replaced.success then -- 3001
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3003
		return replaced -- 3004
	end -- 3004
	local t = now() -- 3006
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3007
	session.workMode = "plan" -- 3008
	local result = startPromptTask( -- 3009
		session, -- 3009
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3009
		nil, -- 3009
		{}, -- 3009
		{ -- 3009
			workMode = "plan", -- 3010
			persistUserMessage = false, -- 3011
			resumeConversation = true, -- 3012
			existingTaskId = questionnaire.taskId, -- 3013
			initialStep = replaced.answerStep, -- 3014
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3015
			llmConfig = llmConfigRes.config -- 3016
		} -- 3016
	) -- 3016
	if not result.success then -- 3016
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3019
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3020
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3021
		emitAgentSessionPatch( -- 3022
			session.id, -- 3022
			{ -- 3022
				session = getSessionItem(session.id), -- 3023
				pendingQuestionnaire = questionnaire -- 3024
			} -- 3024
		) -- 3024
		return result -- 3026
	end -- 3026
	emitAgentSessionPatch( -- 3028
		sessionId, -- 3028
		{ -- 3028
			session = getSessionItem(sessionId), -- 3029
			pendingQuestionnaire = false -- 3030
		} -- 3030
	) -- 3030
	return result -- 3032
end -- 2990
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 3035
	local session = getSessionItem(sessionId) -- 3036
	if not session then -- 3036
		return {success = false, message = "session not found"} -- 3037
	end -- 3037
	if session.kind ~= "main" then -- 3037
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3038
	end -- 3038
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3039
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3039
		return {success = false, message = "pending questionnaire not found"} -- 3040
	end -- 3040
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3041
	if not validated.success then -- 3041
		return validated -- 3042
	end -- 3042
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3043
	if not llmConfigRes.success then -- 3043
		return {success = false, message = llmConfigRes.message} -- 3044
	end -- 3044
	local t = now() -- 3045
	if not removePendingQuestionnaire(session) then -- 3045
		return {success = false, message = "failed to consume questionnaire file"} -- 3046
	end -- 3046
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3047
	if not replaced.success then -- 3047
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3049
		return replaced -- 3050
	end -- 3050
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3052
	session.workMode = "plan" -- 3053
	local result = startPromptTask( -- 3054
		session, -- 3054
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3054
		nil, -- 3054
		{}, -- 3054
		{ -- 3054
			workMode = "plan", -- 3055
			persistUserMessage = false, -- 3056
			resumeConversation = true, -- 3057
			existingTaskId = questionnaire.taskId, -- 3058
			initialStep = replaced.answerStep, -- 3059
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3060
			llmConfig = llmConfigRes.config -- 3061
		} -- 3061
	) -- 3061
	if not result.success then -- 3061
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3064
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3065
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3066
		emitAgentSessionPatch( -- 3067
			session.id, -- 3067
			{ -- 3067
				session = getSessionItem(session.id), -- 3068
				pendingQuestionnaire = questionnaire -- 3069
			} -- 3069
		) -- 3069
		return result -- 3071
	end -- 3071
	emitAgentSessionPatch( -- 3073
		sessionId, -- 3073
		{ -- 3073
			session = getSessionItem(sessionId), -- 3074
			pendingQuestionnaire = false -- 3075
		} -- 3075
	) -- 3075
	return result -- 3077
end -- 3035
function ____exports.stopSessionTask(sessionId) -- 3080
	local session = getSessionItem(sessionId) -- 3081
	if not session or session.currentTaskId == nil then -- 3081
		return {success = false, message = "session task not found"} -- 3083
	end -- 3083
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3083
		return {success = false, message = "session task is finalizing"} -- 3086
	end -- 3086
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3088
	local stopToken = activeStopTokens[session.currentTaskId] -- 3089
	if not stopToken then -- 3089
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3089
			return {success = true, recovered = true} -- 3092
		end -- 3092
		return {success = false, message = "task is not running"} -- 3094
	end -- 3094
	if stopToken.stopped then -- 3094
		return {success = true, stopping = true} -- 3097
	end -- 3097
	stopToken.stopped = true -- 3099
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3100
	return {success = true, stopping = true} -- 3104
end -- 3080
function ____exports.getCurrentTaskId(sessionId) -- 3107
	local ____opt_123 = getSessionItem(sessionId) -- 3107
	return ____opt_123 and ____opt_123.currentTaskId -- 3108
end -- 3107
function ____exports.validateTaskAccess(sessionId, taskId) -- 3111
	local session = getSessionItem(sessionId) -- 3112
	if not session then -- 3112
		return {success = false, message = "session not found"} -- 3113
	end -- 3113
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3113
		getSessionOperableTaskIds(sessionId), -- 3114
		taskId -- 3114
	) < 0 then -- 3114
		return {success = false, message = "task is not operable for this session"} -- 3115
	end -- 3115
	return {success = true, session = session} -- 3117
end -- 3111
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3120
	if checkpointId <= 0 then -- 3120
		return {success = false, message = "invalid checkpointId"} -- 3122
	end -- 3122
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3124
	if not checkpoint then -- 3124
		return {success = false, message = "checkpoint not found"} -- 3126
	end -- 3126
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3128
	if not taskAccess.success then -- 3128
		return taskAccess -- 3129
	end -- 3129
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3130
end -- 3120
function ____exports.listRunningSessions() -- 3133
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3134
	local sessions = {} -- 3141
	do -- 3141
		local i = 0 -- 3142
		while i < #rows do -- 3142
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3143
			if session.currentTaskStatus == "RUNNING" then -- 3143
				sessions[#sessions + 1] = session -- 3145
			end -- 3145
			i = i + 1 -- 3142
		end -- 3142
	end -- 3142
	return {success = true, sessions = sessions} -- 3148
end -- 3133
return ____exports -- 3133