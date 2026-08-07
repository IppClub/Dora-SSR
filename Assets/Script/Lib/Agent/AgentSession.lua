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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
local cleanupOrphanHeavyDataBatch = ____AgentStorage.cleanupOrphanHeavyDataBatch -- 16
local cleanupTaskHeavyData = ____AgentStorage.cleanupTaskHeavyData -- 17
local getSessionOperableTaskIds = ____AgentStorage.getSessionOperableTaskIds -- 18
local requireAgentStorage = ____AgentStorage.requireAgentStorage -- 19
local ____Memory = require("Agent.Memory") -- 21
local DualLayerStorage = ____Memory.DualLayerStorage -- 21
local ____Utils = require("Agent.Utils") -- 22
local Log = ____Utils.Log -- 22
local getLLMConfig = ____Utils.getLLMConfig -- 22
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 22
local safeJsonDecode = ____Utils.safeJsonDecode -- 22
local safeJsonEncode = ____Utils.safeJsonEncode -- 22
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 22
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 26
local validateQuestionnaireAnswers = ____AgentQuestionnaire.validateQuestionnaireAnswers -- 26
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
	Content:remove(tempPath) -- 723
	if not Content:save( -- 723
		tempPath, -- 724
		encodeJson(questionnaire) -- 724
	) then -- 724
		return false -- 724
	end -- 724
	if Content:exist(path) then -- 724
		Content:remove(path) -- 725
	end -- 725
	if Content:move(tempPath, path) then -- 725
		Tools.sendWebIDEFileUpdate( -- 727
			path, -- 727
			true, -- 727
			encodeJson(questionnaire) -- 727
		) -- 727
		return true -- 728
	end -- 728
	Content:remove(tempPath) -- 730
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
					goto __continue122 -- 817
				end -- 817
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 817
					tools[#tools + 1] = name -- 818
				end -- 818
			end -- 818
			::__continue122:: -- 818
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
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 828
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
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 849
	return row and rowToSession(row) or nil -- 857
end -- 857
function countRunningSubSessions(rootSessionId) -- 860
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 861
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
				taskIds[#taskIds + 1] = taskId -- 891
			end -- 891
			i = i + 1 -- 889
		end -- 889
	end -- 889
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
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 930
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
	local ____temp_16 = type(info.sessionId) == "number" and info.sessionId or nil -- 946
	local ____temp_17 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 947
	local ____temp_18 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 948
	local ____temp_19 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 949
	local ____temp_20 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 950
	local ____temp_21 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 951
	local ____temp_22 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 952
	local ____temp_23 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 953
		__TS__ArrayFilter( -- 954
			info.filesHint, -- 954
			function(____, item) return type(item) == "string" end -- 954
		), -- 954
		function(____, item) return sanitizeUTF8(item) end -- 954
	) or nil -- 954
	local ____temp_24 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 956
	local ____temp_14 -- 959
	if info.success == true then -- 959
		____temp_14 = true -- 959
	else -- 959
		local ____temp_13 -- 959
		if info.success == false then -- 959
			____temp_13 = false -- 959
		else -- 959
			____temp_13 = nil -- 959
		end -- 959
		____temp_14 = ____temp_13 -- 959
	end -- 959
	local ____temp_15 -- 960
	if info.cleared == true then -- 960
		____temp_15 = true -- 960
	else -- 960
		____temp_15 = nil -- 960
	end -- 960
	return { -- 945
		sessionId = ____temp_16, -- 946
		rootSessionId = ____temp_17, -- 947
		parentSessionId = ____temp_18, -- 948
		title = ____temp_19, -- 949
		prompt = ____temp_20, -- 950
		goal = ____temp_21, -- 951
		expectedOutput = ____temp_22, -- 952
		filesHint = ____temp_23, -- 953
		status = ____temp_24, -- 956
		success = ____temp_14, -- 959
		cleared = ____temp_15, -- 960
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
					goto __continue192 -- 1080
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
			::__continue192:: -- 1082
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
	local ____array_33 = __TS__SparseArrayNew( -- 1120
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
		____array_33, -- 1130
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1131
	) -- 1131
	__TS__SparseArrayPush( -- 1131
		____array_33, -- 1131
		"- Finished At: " .. record.finishedAt, -- 1132
		"", -- 1133
		"## Validation", -- 1134
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1135
			record.completion.validation, -- 1136
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1136
		) or ({"- Not reported"})) -- 1136
	) -- 1136
	__TS__SparseArrayPush(____array_33, "", "## Recorded Evidence") -- 1136
	local ____opt_25 = record.handoffEvidence -- 1136
	__TS__SparseArrayPush( -- 1136
		____array_33, -- 1136
		table.unpack(____opt_25 and #____opt_25.modifiedFiles and __TS__ArrayMap( -- 1140
			record.handoffEvidence.modifiedFiles, -- 1141
			function(____, item) return "- modified: " .. item end -- 1141
		) or ({"- modified: none recorded"})) -- 1141
	) -- 1141
	local ____opt_27 = record.handoffEvidence -- 1141
	__TS__SparseArrayPush( -- 1141
		____array_33, -- 1141
		table.unpack(____opt_27 and ____opt_27.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1143
	) -- 1143
	local ____opt_29 = record.handoffEvidence -- 1143
	__TS__SparseArrayPush( -- 1143
		____array_33, -- 1143
		table.unpack(__TS__ArrayMap( -- 1146
			____opt_29 and ____opt_29.commands or ({}), -- 1146
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1146
		)) -- 1146
	) -- 1146
	local ____opt_31 = record.handoffEvidence -- 1146
	__TS__SparseArrayPush( -- 1146
		____array_33, -- 1146
		table.unpack(__TS__ArrayMap( -- 1147
			____opt_31 and ____opt_31.authoritativeSources or ({}), -- 1147
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1147
		)) -- 1147
	) -- 1147
	__TS__SparseArrayPush( -- 1147
		____array_33, -- 1147
		"", -- 1148
		"## Known Issues", -- 1149
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1150
			record.completion.knownIssues, -- 1150
			function(____, item) return "- " .. item end -- 1150
		) or ({"- None reported"})) -- 1150
	) -- 1150
	__TS__SparseArrayPush( -- 1150
		____array_33, -- 1150
		"", -- 1151
		"## Assumptions", -- 1152
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1153
			record.completion.assumptions, -- 1153
			function(____, item) return "- " .. item end -- 1153
		) or ({"- None reported"})) -- 1153
	) -- 1153
	__TS__SparseArrayPush(____array_33, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1153
	local lines = {__TS__SparseArraySpread(____array_33)} -- 1122
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
				goto __continue212 -- 1173
			end -- 1173
			local info = readSpawnInfo( -- 1174
				projectRoot, -- 1174
				Path( -- 1174
					"subagents", -- 1174
					Path:getFilename(path) -- 1174
				) -- 1174
			) -- 1174
			if not info then -- 1174
				goto __continue212 -- 1175
			end -- 1175
			local sessionId = tonumber(info.sessionId) -- 1176
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1177
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1178
			local status = sanitizeUTF8(toStr(info.status)) -- 1179
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1179
				goto __continue212 -- 1180
			end -- 1180
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1180
				goto __continue212 -- 1181
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
		::__continue212:: -- 1208
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
				goto __continue228 -- 1239
			end -- 1239
			local text = Content:load(path) -- 1240
			if not text or __TS__StringTrim(text) == "" then -- 1240
				goto __continue228 -- 1241
			end -- 1241
			local obj = safeJsonDecode(text) -- 1242
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1242
				goto __continue228 -- 1243
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
				goto __continue228 -- 1254
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
		::__continue228:: -- 1278
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
	local ____opt_34 = session.metrics -- 1435
	local usage = ____opt_34 and ____opt_34.usage -- 1436
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
	local ____rootSession_currentTaskId_38 -- 1836
	if rootSession.currentTaskId then -- 1836
		____rootSession_currentTaskId_38 = getTaskPrompt(rootSession.currentTaskId) -- 1836
	else -- 1836
		____rootSession_currentTaskId_38 = nil -- 1836
	end -- 1836
	local currentTaskPrompt = ____rootSession_currentTaskId_38 -- 1836
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
	repeat -- 1915
		local ____switch319 = event.type -- 1915
		local metrics, startedSession -- 1915
		local ____cond319 = ____switch319 == "task_started" -- 1915
		if ____cond319 then -- 1915
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1918
			local ____event_resumed_41 -- 1919
			if event.resumed then -- 1919
				local ____opt_39 = getSessionItem(sessionId) -- 1919
				____event_resumed_41 = ____opt_39 and ____opt_39.metrics -- 1920
			else -- 1920
				____event_resumed_41 = clearSessionTokenUsage(sessionId) -- 1921
			end -- 1921
			metrics = ____event_resumed_41 -- 1919
			startedSession = getSessionItem(sessionId) -- 1922
			emitAgentSessionPatch( -- 1923
				sessionId, -- 1923
				{ -- 1923
					session = startedSession, -- 1924
					metrics = metrics, -- 1925
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1926
				} -- 1926
			) -- 1926
			break -- 1930
		end -- 1930
		____cond319 = ____cond319 or ____switch319 == "decision_made" -- 1930
		if ____cond319 then -- 1930
			upsertStep( -- 1932
				sessionId, -- 1932
				event.taskId, -- 1932
				event.step, -- 1932
				event.tool, -- 1932
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1932
			) -- 1932
			emitAgentSessionPatch( -- 1940
				sessionId, -- 1940
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1940
			) -- 1940
			break -- 1943
		end -- 1943
		____cond319 = ____cond319 or ____switch319 == "tool_started" -- 1943
		if ____cond319 then -- 1943
			upsertStep( -- 1945
				sessionId, -- 1945
				event.taskId, -- 1945
				event.step, -- 1945
				event.tool, -- 1945
				{status = "RUNNING"} -- 1945
			) -- 1945
			emitAgentSessionPatch( -- 1948
				sessionId, -- 1948
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1948
			) -- 1948
			break -- 1951
		end -- 1951
		____cond319 = ____cond319 or ____switch319 == "tool_finished" -- 1951
		if ____cond319 then -- 1951
			do -- 1951
				local ____temp_44 = event.result.success ~= true -- 1953
				if ____temp_44 then -- 1953
					local ____opt_42 = activeStopTokens[event.taskId] -- 1953
					____temp_44 = (____opt_42 and ____opt_42.stopped) == true -- 1953
				end -- 1953
				local stopped = ____temp_44 -- 1953
				upsertStep( -- 1955
					sessionId, -- 1955
					event.taskId, -- 1955
					event.step, -- 1955
					event.tool, -- 1955
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1955
				) -- 1955
				emitAgentSessionPatch( -- 1963
					sessionId, -- 1963
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1963
				) -- 1963
				break -- 1966
			end -- 1966
		end -- 1966
		____cond319 = ____cond319 or ____switch319 == "tool_progress" -- 1966
		if ____cond319 then -- 1966
			do -- 1966
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1970
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1970
					break -- 1972
				end -- 1972
			end -- 1972
			upsertStep( -- 1975
				sessionId, -- 1975
				event.taskId, -- 1975
				event.step, -- 1975
				event.tool, -- 1975
				{status = "RUNNING", result = event.result} -- 1975
			) -- 1975
			emitAgentSessionPatch( -- 1979
				sessionId, -- 1979
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1979
			) -- 1979
			break -- 1982
		end -- 1982
		____cond319 = ____cond319 or ____switch319 == "checkpoint_created" -- 1982
		if ____cond319 then -- 1982
			upsertStep( -- 1984
				sessionId, -- 1984
				event.taskId, -- 1984
				event.step, -- 1984
				event.tool, -- 1984
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1984
			) -- 1984
			emitAgentSessionPatch( -- 1989
				sessionId, -- 1989
				{ -- 1989
					step = getStepItem(sessionId, event.taskId, event.step), -- 1990
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 1991
				} -- 1991
			) -- 1991
			break -- 1993
		end -- 1993
		____cond319 = ____cond319 or ____switch319 == "memory_compression_started" -- 1993
		if ____cond319 then -- 1993
			upsertStep( -- 1995
				sessionId, -- 1995
				event.taskId, -- 1995
				event.step, -- 1995
				event.tool, -- 1995
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1995
			) -- 1995
			emitAgentSessionPatch( -- 2000
				sessionId, -- 2000
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2000
			) -- 2000
			break -- 2003
		end -- 2003
		____cond319 = ____cond319 or ____switch319 == "memory_compression_finished" -- 2003
		if ____cond319 then -- 2003
			upsertStep( -- 2005
				sessionId, -- 2005
				event.taskId, -- 2005
				event.step, -- 2005
				event.tool, -- 2005
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2005
			) -- 2005
			emitAgentSessionPatch( -- 2010
				sessionId, -- 2010
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2010
			) -- 2010
			break -- 2013
		end -- 2013
		____cond319 = ____cond319 or ____switch319 == "metrics_updated" -- 2013
		if ____cond319 then -- 2013
			do -- 2013
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2015
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2016
				break -- 2019
			end -- 2019
		end -- 2019
		____cond319 = ____cond319 or ____switch319 == "assistant_message_updated" -- 2019
		if ____cond319 then -- 2019
			do -- 2019
				upsertStep( -- 2022
					sessionId, -- 2022
					event.taskId, -- 2022
					event.step, -- 2022
					"message", -- 2022
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2022
				) -- 2022
				emitAgentSessionPatch( -- 2027
					sessionId, -- 2027
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2027
				) -- 2027
				break -- 2030
			end -- 2030
		end -- 2030
		____cond319 = ____cond319 or ____switch319 == "task_waiting_for_user" -- 2030
		if ____cond319 then -- 2030
			do -- 2030
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2033
				__TS__Delete(activeStopTokens, event.taskId) -- 2034
				emitAgentSessionPatch( -- 2035
					sessionId, -- 2035
					{ -- 2035
						session = getSessionItem(sessionId), -- 2036
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2037
					} -- 2037
				) -- 2037
				break -- 2039
			end -- 2039
		end -- 2039
		____cond319 = ____cond319 or ____switch319 == "task_finished" -- 2039
		if ____cond319 then -- 2039
			do -- 2039
				local session = getSessionItem(sessionId) -- 2042
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2042
					__TS__Delete(activeStopTokens, event.taskId) -- 2044
					Log( -- 2045
						"Info", -- 2045
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2045
					) -- 2045
					break -- 2046
				end -- 2046
				local ____opt_45 = activeStopTokens[event.taskId or -1] -- 2046
				local stopped = (____opt_45 and ____opt_45.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2048
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2050
				local isSubSession = (session and session.kind) == "sub" -- 2053
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2054
				if isSubSession and event.taskId ~= nil then -- 2054
					finalizingSubSessionTaskIds[event.taskId] = true -- 2056
				end -- 2056
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2058
				if event.taskId ~= nil then -- 2058
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2060
					local ____finalizeTaskSteps_51 = finalizeTaskSteps -- 2061
					local ____array_50 = __TS__SparseArrayNew( -- 2061
						sessionId, -- 2062
						event.taskId, -- 2063
						type(event.steps) == "number" and math.max( -- 2064
							0, -- 2064
							math.floor(event.steps) -- 2064
						) or nil -- 2064
					) -- 2064
					local ____event_success_49 -- 2065
					if event.success then -- 2065
						____event_success_49 = nil -- 2065
					else -- 2065
						____event_success_49 = stopped and "STOPPED" or "FAILED" -- 2065
					end -- 2065
					__TS__SparseArrayPush(____array_50, ____event_success_49) -- 2065
					____finalizeTaskSteps_51(__TS__SparseArraySpread(____array_50)) -- 2061
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2067
					if not isSubSession then -- 2067
						__TS__Delete(activeStopTokens, event.taskId) -- 2069
					end -- 2069
					emitAgentSessionPatch( -- 2071
						sessionId, -- 2071
						{ -- 2071
							session = getSessionItem(sessionId), -- 2072
							message = getMessageItem(messageId), -- 2073
							removedStepIds = removedStepIds -- 2074
						} -- 2074
					) -- 2074
				end -- 2074
				if session and session.kind == "main" then -- 2074
					flushPendingSubAgentHandoffs(session) -- 2078
				end -- 2078
				break -- 2080
			end -- 2080
		end -- 2080
	until true -- 2080
end -- 2080
function ____exports.createSession(projectRoot, title) -- 2085
	if title == nil then -- 2085
		title = "" -- 2085
	end -- 2085
	local storage = requireAgentStorage() -- 2086
	if not storage.success then -- 2086
		return storage -- 2087
	end -- 2087
	if not isValidProjectRoot(projectRoot) then -- 2087
		return {success = false, message = "invalid projectRoot"} -- 2089
	end -- 2089
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2091
	if row then -- 2091
		return { -- 2100
			success = true, -- 2100
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2100
		} -- 2100
	end -- 2100
	local t = now() -- 2102
	DB:exec( -- 2103
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 2103
		{ -- 2106
			projectRoot, -- 2106
			title ~= "" and title or Path:getFilename(projectRoot), -- 2106
			t, -- 2106
			t -- 2106
		} -- 2106
	) -- 2106
	local sessionId = getLastInsertRowId() -- 2108
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2109
	local session = getSessionItem(sessionId) -- 2110
	if not session then -- 2110
		return {success = false, message = "failed to create session"} -- 2112
	end -- 2112
	return {success = true, session = session} -- 2114
end -- 2085
function ____exports.createSubSession(parentSessionId, title) -- 2117
	if title == nil then -- 2117
		title = "" -- 2117
	end -- 2117
	local storage = requireAgentStorage() -- 2118
	if not storage.success then -- 2118
		return storage -- 2119
	end -- 2119
	local parent = getSessionItem(parentSessionId) -- 2120
	if not parent then -- 2120
		return {success = false, message = "parent session not found"} -- 2122
	end -- 2122
	local rootId = getSessionRootId(parent) -- 2124
	local t = now() -- 2125
	DB:exec( -- 2126
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2126
		{ -- 2129
			parent.projectRoot, -- 2129
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2129
			rootId, -- 2129
			parent.id, -- 2129
			t, -- 2129
			t -- 2129
		} -- 2129
	) -- 2129
	local sessionId = getLastInsertRowId() -- 2131
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2132
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2133
	local session = getSessionItem(sessionId) -- 2134
	if not session then -- 2134
		return {success = false, message = "failed to create sub session"} -- 2136
	end -- 2136
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2138
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2139
	subStorage:writeMemory(parentStorage:readMemory()) -- 2140
	return {success = true, session = session} -- 2141
end -- 2117
function spawnSubAgentSession(request) -- 2144
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2144
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2157
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2158
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2159
		if normalizedPrompt == "" then -- 2159
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2161
		end -- 2161
		if normalizedPrompt == "" then -- 2161
			local ____Log_57 = Log -- 2168
			local ____temp_54 = #normalizedTitle -- 2168
			local ____temp_55 = #rawPrompt -- 2168
			local ____temp_56 = #toStr(request.expectedOutput) -- 2168
			local ____opt_52 = request.filesHint -- 2168
			____Log_57( -- 2168
				"Warn", -- 2168
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_54)) .. " raw_prompt_len=") .. tostring(____temp_55)) .. " expected_len=") .. tostring(____temp_56)) .. " files_hint_count=") .. tostring(____opt_52 and #____opt_52 or 0) -- 2168
			) -- 2168
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2168
		end -- 2168
		Log( -- 2171
			"Info", -- 2171
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2171
		) -- 2171
		local parentSessionId = request.parentSessionId -- 2172
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2172
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2174
			if not fallbackParent then -- 2174
				local createdMain = ____exports.createSession(request.projectRoot) -- 2176
				if createdMain.success then -- 2176
					fallbackParent = createdMain.session -- 2178
				end -- 2178
			end -- 2178
			if fallbackParent then -- 2178
				Log( -- 2182
					"Warn", -- 2182
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2182
				) -- 2182
				parentSessionId = fallbackParent.id -- 2183
			end -- 2183
		end -- 2183
		local parentSession = getSessionItem(parentSessionId) -- 2186
		if not parentSession then -- 2186
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2186
		end -- 2186
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2190
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2190
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2190
		end -- 2190
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2194
		if not created.success then -- 2194
			return ____awaiter_resolve(nil, created) -- 2194
		end -- 2194
		writeSpawnInfo( -- 2198
			created.session.projectRoot, -- 2198
			created.session.memoryScope, -- 2198
			{ -- 2198
				sessionId = created.session.id, -- 2199
				rootSessionId = created.session.rootSessionId, -- 2200
				parentSessionId = created.session.parentSessionId, -- 2201
				title = created.session.title, -- 2202
				prompt = normalizedPrompt, -- 2203
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2204
				expectedOutput = request.expectedOutput or "", -- 2205
				filesHint = request.filesHint or ({}), -- 2206
				status = "RUNNING", -- 2207
				success = false, -- 2208
				resultFilePath = "", -- 2209
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2210
				sourceTaskId = 0, -- 2211
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2212
				createdAtTs = created.session.createdAt, -- 2213
				finishedAt = "", -- 2214
				finishedAtTs = 0 -- 2215
			} -- 2215
		) -- 2215
		local sent = ____exports.sendPrompt( -- 2217
			created.session.id, -- 2217
			normalizedPrompt, -- 2217
			true, -- 2217
			request.disabledAgentTools, -- 2217
			nil, -- 2217
			nil, -- 2217
			request.llmConfig -- 2217
		) -- 2217
		if not sent.success then -- 2217
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2217
		end -- 2217
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2217
	end) -- 2217
end -- 2217
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2323
	local rootSession = getRootSessionItem(session.id) -- 2324
	if not rootSession then -- 2324
		return -- 2325
	end -- 2325
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2326
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2327
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2328
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2329
	local queueResult = writePendingHandoff( -- 2330
		rootSession.projectRoot, -- 2330
		rootSession.memoryScope, -- 2330
		{ -- 2330
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2331
			sourceSessionId = session.id, -- 2332
			sourceTitle = session.title, -- 2333
			sourceTaskId = taskId, -- 2334
			message = summary, -- 2335
			prompt = result.prompt, -- 2336
			goal = result.goal, -- 2337
			expectedOutput = result.expectedOutput or "", -- 2338
			filesHint = result.filesHint or ({}), -- 2339
			success = result.success, -- 2340
			resultFilePath = result.resultFilePath, -- 2341
			artifactDir = result.artifactDir, -- 2342
			finishedAt = result.finishedAt, -- 2343
			changeSet = changeSet, -- 2344
			handoffEvidence = result.handoffEvidence, -- 2345
			memoryEntry = result.memoryEntry, -- 2346
			completion = result.completion, -- 2347
			createdAt = createdAt -- 2348
		} -- 2348
	) -- 2348
	if not queueResult then -- 2348
		Log( -- 2351
			"Warn", -- 2351
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2351
		) -- 2351
		return -- 2352
	end -- 2352
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2352
		addTaskReference(rootSession.currentTaskId, taskId) -- 2355
	end -- 2355
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2355
		flushPendingSubAgentHandoffs(rootSession) -- 2358
	end -- 2358
end -- 2358
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2362
	if forceHandoff == nil then -- 2362
		forceHandoff = false -- 2368
	end -- 2368
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2368
		local rootSessionId = getSessionRootId(session) -- 2370
		local rootSession = getRootSessionItem(session.id) -- 2371
		if not rootSession then -- 2371
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2371
		end -- 2371
		local spawnInfo = getSessionSpawnInfo(session) -- 2375
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2376
		local finishedAtTs = now() -- 2377
		local resultText = sanitizeUTF8(message) -- 2378
		local changeSet = getTaskChangeSetSummary(taskId) -- 2379
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2380
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2381
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2385
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2385
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2387
		end -- 2387
		local completed = success and completionReport.outcome == "completed" -- 2395
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2396
		local record = { -- 2399
			sessionId = session.id, -- 2400
			rootSessionId = rootSessionId, -- 2401
			parentSessionId = session.parentSessionId, -- 2402
			title = session.title, -- 2403
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2404
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2405
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2406
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2407
			status = recordStatus, -- 2408
			success = completed, -- 2409
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2410
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2411
			sourceTaskId = taskId, -- 2412
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2413
			finishedAt = finishedAt, -- 2414
			createdAtTs = session.createdAt, -- 2415
			finishedAtTs = finishedAtTs, -- 2416
			changeSet = changeSet, -- 2417
			handoffEvidence = handoffEvidence, -- 2418
			completion = completionReport -- 2419
		} -- 2419
		local ____record_success_70 -- 2421
		if record.success then -- 2421
			____record_success_70 = buildStructuredSubAgentMemoryEntry(record) -- 2421
		else -- 2421
			____record_success_70 = nil -- 2421
		end -- 2421
		record.memoryEntry = ____record_success_70 -- 2421
		if not writeSubAgentResultFile(session, record, resultText) then -- 2421
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2421
		end -- 2421
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2421
			sessionId = record.sessionId, -- 2426
			rootSessionId = record.rootSessionId, -- 2427
			parentSessionId = record.parentSessionId, -- 2428
			title = record.title, -- 2429
			prompt = record.prompt, -- 2430
			goal = record.goal, -- 2431
			expectedOutput = record.expectedOutput or "", -- 2432
			filesHint = record.filesHint or ({}), -- 2433
			status = record.status, -- 2434
			success = record.success, -- 2435
			resultFilePath = record.resultFilePath, -- 2436
			artifactDir = record.artifactDir, -- 2437
			sourceTaskId = record.sourceTaskId, -- 2438
			createdAt = record.createdAt, -- 2439
			finishedAt = record.finishedAt, -- 2440
			createdAtTs = record.createdAtTs, -- 2441
			finishedAtTs = record.finishedAtTs, -- 2442
			changeSet = record.changeSet, -- 2443
			handoffEvidence = record.handoffEvidence, -- 2444
			memoryEntry = record.memoryEntry, -- 2445
			memoryEntryError = record.memoryEntryError, -- 2446
			completion = record.completion -- 2447
		}) then -- 2447
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2447
		end -- 2447
		if success or forceHandoff then -- 2447
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2452
			deleteSessionRecords(session.id, true) -- 2453
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2454
		end -- 2454
		return ____awaiter_resolve(nil, {success = true}) -- 2454
	end) -- 2454
end -- 2454
function stopClearedSubSession(session, taskId) -- 2459
	local spawnInfo = getSessionSpawnInfo(session) -- 2460
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2461
	local rootSessionId = getSessionRootId(session) -- 2462
	Tools.setTaskStatus(taskId, "STOPPED") -- 2463
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2464
	if not writeSpawnInfo( -- 2464
		session.projectRoot, -- 2465
		session.memoryScope, -- 2465
		{ -- 2465
			sessionId = session.id, -- 2466
			rootSessionId = rootSessionId, -- 2467
			parentSessionId = session.parentSessionId, -- 2468
			title = session.title, -- 2469
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2470
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2471
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2472
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2473
			status = "STOPPED", -- 2474
			success = false, -- 2475
			cleared = true, -- 2476
			resultFilePath = "", -- 2477
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2478
			sourceTaskId = taskId, -- 2479
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2480
			finishedAt = finishedAt, -- 2481
			createdAtTs = session.createdAt, -- 2482
			finishedAtTs = now() -- 2483
		} -- 2483
	) then -- 2483
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2485
	end -- 2485
	deleteSessionRecords(session.id, true) -- 2487
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2488
	return {success = true} -- 2489
end -- 2489
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2492
	if allowSubSessionStart == nil then -- 2492
		allowSubSessionStart = false -- 2492
	end -- 2492
	local session = getSessionItem(sessionId) -- 2493
	if not session then -- 2493
		return {success = false, message = "session not found"} -- 2495
	end -- 2495
	if getPendingQuestionnaire(sessionId) then -- 2495
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2497
	end -- 2497
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2497
		return {success = false, message = "session task is finalizing"} -- 2499
	end -- 2499
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2499
		return {success = false, message = "session task is still running"} -- 2502
	end -- 2502
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2504
	if normalizedPrompt == "" and session.kind == "sub" then -- 2504
		local spawnInfo = getSessionSpawnInfo(session) -- 2506
		if spawnInfo then -- 2506
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2508
			if normalizedPrompt == "" then -- 2508
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2510
			end -- 2510
		end -- 2510
	end -- 2510
	if normalizedPrompt == "" then -- 2510
		return {success = false, message = "prompt is empty"} -- 2519
	end -- 2519
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2521
	if session.workMode ~= nextWorkMode then -- 2521
		DB:exec( -- 2523
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2523
			{ -- 2523
				nextWorkMode, -- 2523
				now(), -- 2523
				session.id -- 2523
			} -- 2523
		) -- 2523
		session.workMode = nextWorkMode -- 2524
	end -- 2524
	return startPromptTask( -- 2526
		session, -- 2526
		normalizedPrompt, -- 2526
		nil, -- 2526
		normalizeDisabledAgentTools(disabledAgentTools), -- 2526
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2526
	) -- 2526
end -- 2492
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2579
	if disabledAgentTools == nil then -- 2579
		disabledAgentTools = {} -- 2583
	end -- 2583
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2586
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2587
	if not llmConfigRes.success then -- 2587
		return {success = false, message = llmConfigRes.message} -- 2591
	end -- 2591
	local llmConfig = llmConfigRes.config -- 2593
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2594
	if not taskRes.success then -- 2594
		return {success = false, message = taskRes.message} -- 2597
	end -- 2597
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2597
		removeContinuableTaskSummary(session) -- 2599
	end -- 2599
	local taskId = taskRes.taskId -- 2601
	local ____temp_91 -- 2602
	if (options and options.existingTaskId) == nil then -- 2602
		____temp_91 = session.currentTaskId -- 2602
	else -- 2602
		____temp_91 = nil -- 2602
	end -- 2602
	local previousTaskId = ____temp_91 -- 2602
	local useChineseResponse = getDefaultUseChineseResponse() -- 2603
	if existingUserMessageId ~= nil then -- 2603
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2605
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2605
		insertMessage( -- 2607
			session.id, -- 2607
			"user", -- 2607
			normalizedPrompt, -- 2607
			taskId, -- 2607
			options and options.displayContent -- 2607
		) -- 2607
	end -- 2607
	local stopToken = {stopped = false} -- 2609
	activeStopTokens[taskId] = stopToken -- 2610
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2611
	if previousTaskId and previousTaskId ~= taskId then -- 2611
		cleanupTaskHeavyData(previousTaskId) -- 2613
	end -- 2613
	local ____runCodingAgent_120 = runCodingAgent -- 2615
	local ____normalizedPrompt_113 = normalizedPrompt -- 2616
	local ____temp_114 = options and options.resumeConversation -- 2617
	local ____temp_115 = (options and options.existingTaskId) ~= nil -- 2618
	local ____temp_116 = options and options.initialStep -- 2619
	local ____temp_117 = options and options.initialAgentStepCount -- 2620
	local ____temp_108 -- 2621
	if (options and options.existingTaskId) ~= nil then -- 2621
		____temp_108 = getInitialTokenUsage(session) -- 2621
	else -- 2621
		____temp_108 = nil -- 2621
	end -- 2621
	____runCodingAgent_120( -- 2615
		{ -- 2615
			prompt = ____normalizedPrompt_113, -- 2616
			resumeConversation = ____temp_114, -- 2617
			resumeTask = ____temp_115, -- 2618
			initialStep = ____temp_116, -- 2619
			initialAgentStepCount = ____temp_117, -- 2620
			initialTokenUsage = ____temp_108, -- 2621
			workDir = session.projectRoot, -- 2622
			useChineseResponse = useChineseResponse, -- 2623
			taskId = taskId, -- 2624
			sessionId = session.id, -- 2625
			memoryScope = session.memoryScope, -- 2626
			role = session.kind, -- 2627
			maxSteps = options and options.maxSteps, -- 2628
			disabledAgentTools = disabledAgentTools, -- 2629
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2630
			llmConfig = llmConfig, -- 2631
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2632
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2635
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2638
			stopToken = stopToken, -- 2639
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2640
		}, -- 2640
		function(result) -- 2641
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2641
				local nextSession = getSessionItem(session.id) -- 2642
				if nextSession and nextSession.kind == "sub" then -- 2642
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2642
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2645
						if not stopped.success then -- 2645
							Log( -- 2647
								"Warn", -- 2647
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2647
							) -- 2647
							emitAgentSessionPatch( -- 2648
								session.id, -- 2648
								{session = getSessionItem(session.id)} -- 2648
							) -- 2648
						end -- 2648
						__TS__Delete(activeStopTokens, taskId) -- 2652
						return ____awaiter_resolve(nil) -- 2652
					end -- 2652
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2655
					emitAgentSessionPatch( -- 2656
						session.id, -- 2656
						{session = getSessionItem(session.id)} -- 2656
					) -- 2656
					local finalized = __TS__Await(finalizeSubSession( -- 2659
						nextSession, -- 2660
						taskId, -- 2661
						result.success, -- 2662
						result.message, -- 2663
						result.completion, -- 2664
						(options and options.forceSubAgentHandoff) == true -- 2665
					)) -- 2665
					if not finalized.success then -- 2665
						Log( -- 2668
							"Warn", -- 2668
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2668
						) -- 2668
					end -- 2668
					local finalizedSession = getSessionItem(session.id) -- 2670
					if finalizedSession then -- 2670
						local stopped = stopToken.stopped == true -- 2672
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2673
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2676
						emitAgentSessionPatch( -- 2677
							session.id, -- 2677
							{session = getSessionItem(session.id)} -- 2677
						) -- 2677
					end -- 2677
					__TS__Delete(activeStopTokens, taskId) -- 2681
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2682
				end -- 2682
				local fallbackSession = getSessionItem(session.id) -- 2684
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2684
					applyEvent(session.id, { -- 2690
						type = "task_finished", -- 2691
						sessionId = session.id, -- 2692
						taskId = result.taskId, -- 2693
						success = false, -- 2694
						message = result.message, -- 2695
						steps = result.steps -- 2696
					}) -- 2696
				end -- 2696
			end) -- 2696
		end -- 2641
	) -- 2641
	return {success = true, sessionId = session.id, taskId = taskId} -- 2700
end -- 2700
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2852
	local lines = {} -- 2853
	do -- 2853
		local i = 0 -- 2854
		while i < #questionnaire.schema.questions do -- 2854
			local question = questionnaire.schema.questions[i + 1] -- 2855
			local answer = __TS__ArrayFind( -- 2856
				answers, -- 2856
				function(____, item) return item.questionId == question.id end -- 2856
			) -- 2856
			local answerText = "已跳过" -- 2857
			if answer and answer.status == "answered" then -- 2857
				local parts = {} -- 2859
				do -- 2859
					local j = 0 -- 2860
					while j < #(answer.selectedOptionIds or ({})) do -- 2860
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2861
						local option = __TS__ArrayFind( -- 2862
							question.options or ({}), -- 2862
							function(____, item) return item.id == optionId end -- 2862
						) -- 2862
						if option then -- 2862
							parts[#parts + 1] = option.label -- 2863
						end -- 2863
						j = j + 1 -- 2860
					end -- 2860
				end -- 2860
				if answer.otherText then -- 2860
					parts[#parts + 1] = answer.otherText -- 2865
				end -- 2865
				if answer.text then -- 2865
					parts[#parts + 1] = answer.text -- 2866
				end -- 2866
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2867
			end -- 2867
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2869
			i = i + 1 -- 2854
		end -- 2854
	end -- 2854
	return table.concat(lines, "\n\n") -- 2871
end -- 2871
function ____exports.listRunningSubAgents(request) -- 3110
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3110
		local session = getSessionItem(request.sessionId) -- 3118
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3118
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3120
		end -- 3120
		if not session then -- 3120
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3120
		end -- 3120
		local rootSession = getRootSessionItem(session.id) -- 3125
		if not rootSession then -- 3125
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3125
		end -- 3125
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3129
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3130
		local limit = math.max( -- 3131
			1, -- 3131
			math.floor(tonumber(request.limit) or 5) -- 3131
		) -- 3131
		local offset = math.max( -- 3132
			0, -- 3132
			math.floor(tonumber(request.offset) or 0) -- 3132
		) -- 3132
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3133
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3134
		local runningSessions = {} -- 3141
		do -- 3141
			local i = 0 -- 3142
			while i < #rows do -- 3142
				do -- 3142
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3143
					if current.currentTaskStatus ~= "RUNNING" then -- 3143
						goto __continue514 -- 3145
					end -- 3145
					local spawnInfo = getSessionSpawnInfo(current) -- 3147
					runningSessions[#runningSessions + 1] = { -- 3148
						sessionId = current.id, -- 3149
						title = current.title, -- 3150
						parentSessionId = current.parentSessionId, -- 3151
						rootSessionId = current.rootSessionId, -- 3152
						status = "RUNNING", -- 3153
						currentTaskId = current.currentTaskId, -- 3154
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3155
						goal = spawnInfo and spawnInfo.goal, -- 3156
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3157
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3158
						createdAt = current.createdAt, -- 3159
						updatedAt = current.updatedAt -- 3160
					} -- 3160
				end -- 3160
				::__continue514:: -- 3160
				i = i + 1 -- 3142
			end -- 3142
		end -- 3142
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3163
		local completedSessions = __TS__ArrayMap( -- 3164
			completedRecords, -- 3164
			function(____, record) return { -- 3164
				sessionId = record.sessionId, -- 3165
				title = record.title, -- 3166
				parentSessionId = record.parentSessionId, -- 3167
				rootSessionId = record.rootSessionId, -- 3168
				status = record.status, -- 3169
				goal = record.goal, -- 3170
				expectedOutput = record.expectedOutput, -- 3171
				filesHint = record.filesHint, -- 3172
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3173
				success = record.success, -- 3174
				cleared = record.cleared, -- 3175
				resultFilePath = record.resultFilePath, -- 3176
				artifactDir = record.artifactDir, -- 3177
				finishedAt = record.finishedAt, -- 3178
				createdAt = record.createdAtTs, -- 3179
				updatedAt = record.finishedAtTs -- 3180
			} end -- 3180
		) -- 3180
		local merged = {} -- 3182
		if status == "running" then -- 3182
			merged = runningSessions -- 3184
		elseif status == "done" then -- 3184
			merged = __TS__ArrayFilter( -- 3186
				completedSessions, -- 3186
				function(____, item) return item.status == "DONE" end -- 3186
			) -- 3186
		elseif status == "failed" then -- 3186
			merged = __TS__ArrayFilter( -- 3188
				completedSessions, -- 3188
				function(____, item) return item.status == "FAILED" end -- 3188
			) -- 3188
		elseif status == "stopped" then -- 3188
			merged = __TS__ArrayFilter( -- 3190
				completedSessions, -- 3190
				function(____, item) return item.status == "STOPPED" end -- 3190
			) -- 3190
		elseif status == "all" then -- 3190
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3192
		else -- 3192
			local runningKeys = {} -- 3194
			do -- 3194
				local i = 0 -- 3195
				while i < #runningSessions do -- 3195
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3196
					i = i + 1 -- 3195
				end -- 3195
			end -- 3195
			local latestCompletedByKey = {} -- 3198
			do -- 3198
				local i = 0 -- 3199
				while i < #completedSessions do -- 3199
					do -- 3199
						local item = completedSessions[i + 1] -- 3200
						local key = getSubAgentDisplayKey(item) -- 3201
						if runningKeys[key] then -- 3201
							goto __continue529 -- 3203
						end -- 3203
						local current = latestCompletedByKey[key] -- 3205
						if not current or item.updatedAt > current.updatedAt then -- 3205
							latestCompletedByKey[key] = item -- 3207
						end -- 3207
					end -- 3207
					::__continue529:: -- 3207
					i = i + 1 -- 3199
				end -- 3199
			end -- 3199
			local latestCompleted = {} -- 3210
			for ____, item in pairs(latestCompletedByKey) do -- 3211
				latestCompleted[#latestCompleted + 1] = item -- 3212
			end -- 3212
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3214
		end -- 3214
		if query ~= "" then -- 3214
			merged = __TS__ArrayFilter( -- 3217
				merged, -- 3217
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3217
			) -- 3217
		end -- 3217
		__TS__ArraySort( -- 3223
			merged, -- 3223
			function(____, a, b) -- 3223
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3223
					return -1 -- 3224
				end -- 3224
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3224
					return 1 -- 3225
				end -- 3225
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3225
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3227
				end -- 3227
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3229
			end -- 3223
		) -- 3223
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3231
		return ____awaiter_resolve(nil, { -- 3231
			success = true, -- 3233
			rootSessionId = rootSession.id, -- 3234
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3235
			status = status, -- 3236
			limit = limit, -- 3237
			offset = offset, -- 3238
			hasMore = offset + limit < #merged, -- 3239
			sessions = paged -- 3240
		}) -- 3240
	end) -- 3240
end -- 3110
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
now = function() return os.time() end -- 327
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
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2229
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2229
		return {success = false, message = "invalid projectRoot"} -- 2231
	end -- 2231
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2233
	for ____, row in ipairs(rows) do -- 2234
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2235
		if sessionId > 0 then -- 2235
			deleteSessionRecords(sessionId) -- 2237
		end -- 2237
	end -- 2237
	return {success = true, deleted = #rows} -- 2240
end -- 2229
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2243
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2243
		return {success = false, message = "invalid projectRoot"} -- 2245
	end -- 2245
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2247
	local renamed = 0 -- 2248
	for ____, row in ipairs(rows) do -- 2249
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2250
		local projectRoot = toStr(row[2]) -- 2251
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2252
		if sessionId > 0 and nextProjectRoot then -- 2252
			DB:exec( -- 2254
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2254
				{ -- 2256
					nextProjectRoot, -- 2256
					Path:getFilename(nextProjectRoot), -- 2256
					now(), -- 2256
					sessionId -- 2256
				} -- 2256
			) -- 2256
			renamed = renamed + 1 -- 2258
		end -- 2258
	end -- 2258
	return {success = true, renamed = renamed} -- 2261
end -- 2243
function ____exports.getSession(sessionId) -- 2264
	local session = getSessionItem(sessionId) -- 2265
	if not session then -- 2265
		return {success = false, message = "session not found"} -- 2267
	end -- 2267
	local restored = restorePendingQuestionnaireState(session) -- 2269
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2270
	cleanupOrphanHeavyDataBatch() -- 2271
	local relatedSessions = listRelatedSessions(sessionId) -- 2272
	sanitizeStoredSteps(sessionId) -- 2273
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2274
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2281
	local ____relatedSessions_59 = relatedSessions -- 2292
	local ____temp_58 -- 2293
	if normalizedSession.kind == "sub" then -- 2293
		____temp_58 = getSessionSpawnInfo(normalizedSession) -- 2293
	else -- 2293
		____temp_58 = nil -- 2293
	end -- 2293
	return { -- 2289
		success = true, -- 2290
		session = normalizedSession, -- 2291
		relatedSessions = ____relatedSessions_59, -- 2292
		spawnInfo = ____temp_58, -- 2293
		messages = __TS__ArrayMap( -- 2294
			messages, -- 2294
			function(____, row) return rowToMessage(row) end -- 2294
		), -- 2294
		steps = __TS__ArrayMap( -- 2295
			steps, -- 2295
			function(____, row) return rowToStep(row) end -- 2295
		), -- 2295
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2296
		pendingQuestionnaire = restored.questionnaire, -- 2297
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2298
	} -- 2298
end -- 2264
function ____exports.setWorkMode(sessionId, workMode) -- 2303
	local session = getSessionItem(sessionId) -- 2304
	if not session then -- 2304
		return {success = false, message = "session not found"} -- 2305
	end -- 2305
	if session.kind ~= "main" then -- 2305
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2306
	end -- 2306
	if workMode ~= "code" and workMode ~= "plan" then -- 2306
		return {success = false, message = "invalid work mode"} -- 2307
	end -- 2307
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2308
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2308
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2310
	end -- 2310
	if getPendingQuestionnaire(sessionId) then -- 2310
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2313
	end -- 2313
	if normalizedSession.workMode ~= workMode then -- 2313
		DB:exec( -- 2316
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2316
			{ -- 2316
				workMode, -- 2316
				now(), -- 2316
				sessionId -- 2316
			} -- 2316
		) -- 2316
	end -- 2316
	local updated = getSessionItem(sessionId) -- 2318
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2319
	return { -- 2320
		success = true, -- 2320
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2320
	} -- 2320
end -- 2303
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2529
	local session = getSessionItem(sessionId) -- 2530
	if not session then -- 2530
		return {success = false, message = "session not found"} -- 2532
	end -- 2532
	if getPendingQuestionnaire(sessionId) then -- 2532
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2534
	end -- 2534
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2534
		return {success = false, message = "session task is finalizing"} -- 2536
	end -- 2536
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2536
		return {success = false, message = "session task is still stopping"} -- 2539
	end -- 2539
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2539
		return {success = false, message = "session task is not continuable"} -- 2542
	end -- 2542
	if session.currentTaskId == nil then -- 2542
		return {success = false, message = "session task not found"} -- 2545
	end -- 2545
	local taskId = session.currentTaskId -- 2547
	return startPromptTask( -- 2548
		session, -- 2549
		"", -- 2550
		nil, -- 2551
		normalizeDisabledAgentTools(disabledAgentTools), -- 2552
		{ -- 2553
			workMode = session.workMode, -- 2554
			persistUserMessage = false, -- 2555
			resumeConversation = true, -- 2556
			existingTaskId = taskId, -- 2557
			initialStep = math.max( -- 2558
				0, -- 2558
				getNextStepNumber(session.id, taskId) - 1 -- 2558
			), -- 2558
			initialAgentStepCount = 0, -- 2559
			llmConfigId = llmConfigId -- 2560
		} -- 2560
	) -- 2560
end -- 2529
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2703
	local session = getSessionItem(sessionId) -- 2704
	if not session then -- 2704
		return {success = false, message = "session not found"} -- 2706
	end -- 2706
	if session.kind ~= "sub" then -- 2706
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2709
	end -- 2709
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2709
		return {success = false, message = "session task is finalizing"} -- 2712
	end -- 2712
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2714
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2714
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2719
	end -- 2719
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2719
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2722
	end -- 2722
	local disabledAgentTools = __TS__ArrayFilter( -- 2724
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2724
		function(____, tool) return tool ~= "finish" end -- 2725
	) -- 2725
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2726
	return startPromptTask( -- 2729
		session, -- 2729
		prompt, -- 2729
		nil, -- 2729
		disabledAgentTools, -- 2729
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2729
	) -- 2729
end -- 2703
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2736
	local session = getSessionItem(sessionId) -- 2737
	if not session then -- 2737
		return {success = false, message = "session not found"} -- 2739
	end -- 2739
	if getPendingQuestionnaire(sessionId) then -- 2739
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2741
	end -- 2741
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2741
		return {success = false, message = "session task is finalizing"} -- 2743
	end -- 2743
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2743
		return {success = false, message = "session task is still running"} -- 2746
	end -- 2746
	local message = getMessageItem(messageId) -- 2748
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2748
		return {success = false, message = "message not found"} -- 2750
	end -- 2750
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2752
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2758
	if latestUserMessageId ~= messageId then -- 2758
		return {success = false, message = "only the latest user prompt can be edited"} -- 2760
	end -- 2760
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2762
	if normalizedPrompt == "" then -- 2762
		return {success = false, message = "prompt is empty"} -- 2764
	end -- 2764
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2766
	if session.workMode ~= nextWorkMode then -- 2766
		DB:exec( -- 2768
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2768
			{ -- 2768
				nextWorkMode, -- 2768
				now(), -- 2768
				session.id -- 2768
			} -- 2768
		) -- 2768
		session.workMode = nextWorkMode -- 2769
	end -- 2769
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2771
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2772
	local result = startPromptTask( -- 2773
		session, -- 2773
		normalizedPrompt, -- 2773
		messageId, -- 2773
		normalizeDisabledAgentTools(disabledAgentTools), -- 2773
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2773
	) -- 2773
	if result.success and #removedStepIds > 0 then -- 2773
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2775
	end -- 2775
	return result -- 2777
end -- 2736
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2782
	if status == "dismissed" then -- 2782
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2788
	end -- 2788
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2790
end -- 2782
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2793
	if status == "dismissed" then -- 2793
		return { -- 2799
			success = true, -- 2800
			status = "dismissed", -- 2801
			source = "user", -- 2802
			questionnaireId = questionnaire.id, -- 2803
			title = questionnaire.schema.title, -- 2804
			answers = {}, -- 2805
			responses = {}, -- 2806
			displayText = "用户关闭了调查问卷，未作答。", -- 2807
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2808
		} -- 2808
	end -- 2808
	local responses = {} -- 2811
	do -- 2811
		local i = 0 -- 2812
		while i < #questionnaire.schema.questions do -- 2812
			do -- 2812
				local question = questionnaire.schema.questions[i + 1] -- 2813
				local answer = __TS__ArrayFind( -- 2814
					answers, -- 2814
					function(____, item) return item.questionId == question.id end -- 2814
				) -- 2814
				if not answer or answer.status == "skipped" then -- 2814
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2816
					goto __continue441 -- 2821
				end -- 2821
				local selectedOptionLabels = {} -- 2823
				do -- 2823
					local j = 0 -- 2824
					while j < #(answer.selectedOptionIds or ({})) do -- 2824
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2825
						local option = __TS__ArrayFind( -- 2826
							question.options or ({}), -- 2826
							function(____, item) return item.id == optionId end -- 2826
						) -- 2826
						if option then -- 2826
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2827
						end -- 2827
						j = j + 1 -- 2824
					end -- 2824
				end -- 2824
				responses[#responses + 1] = { -- 2829
					questionId = question.id, -- 2830
					prompt = question.prompt, -- 2831
					status = "answered", -- 2832
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2833
					selectedOptionLabels = selectedOptionLabels, -- 2834
					otherText = answer.otherText, -- 2835
					text = answer.text -- 2836
				} -- 2836
			end -- 2836
			::__continue441:: -- 2836
			i = i + 1 -- 2812
		end -- 2812
	end -- 2812
	return { -- 2839
		success = true, -- 2840
		status = "answered", -- 2841
		source = "user", -- 2842
		questionnaireId = questionnaire.id, -- 2843
		title = questionnaire.schema.title, -- 2844
		answers = answers, -- 2845
		responses = responses, -- 2846
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2847
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2848
	} -- 2848
end -- 2793
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2874
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2880
	local persisted = storage:readSessionState() -- 2881
	local messages = __TS__ArraySlice(persisted.messages) -- 2882
	local toolResultIndex = -1 -- 2883
	local existingResult -- 2884
	do -- 2884
		local i = #messages - 1 -- 2885
		while i >= 0 do -- 2885
			do -- 2885
				local message = messages[i + 1] -- 2886
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2886
					goto __continue461 -- 2887
				end -- 2887
				local decoded = safeJsonDecode(message.content) -- 2888
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2888
					goto __continue461 -- 2889
				end -- 2889
				local row = decoded -- 2890
				if row.questionnaireId ~= questionnaire.id then -- 2890
					goto __continue461 -- 2891
				end -- 2891
				toolResultIndex = i -- 2892
				existingResult = row -- 2893
				break -- 2894
			end -- 2894
			::__continue461:: -- 2894
			i = i - 1 -- 2885
		end -- 2885
	end -- 2885
	if toolResultIndex < 0 then -- 2885
		return {success = false, message = "matching ask_user tool result not found"} -- 2897
	end -- 2897
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2899
	local guidance = {} -- 2900
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2900
		guidance[#guidance + 1] = existingResult.guidance -- 2902
	end -- 2902
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2902
		guidance[#guidance + 1] = result.guidance -- 2905
	end -- 2905
	result.guidance = table.concat(guidance, "\n") -- 2907
	messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2908
		{}, -- 2908
		messages[toolResultIndex + 1], -- 2909
		{content = encodeJson(result)} -- 2908
	) -- 2908
	local pairStartIndex = toolResultIndex -- 2913
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2914
	if toolCallId and toolCallId ~= "" then -- 2914
		do -- 2914
			local i = toolResultIndex - 1 -- 2916
			while i >= 0 do -- 2916
				do -- 2916
					local message = messages[i + 1] -- 2917
					if message.role ~= "assistant" or not message.tool_calls then -- 2917
						goto __continue470 -- 2918
					end -- 2918
					if __TS__ArraySome( -- 2918
						message.tool_calls, -- 2919
						function(____, call) return call.id == toolCallId end -- 2919
					) then -- 2919
						pairStartIndex = i -- 2920
						break -- 2921
					end -- 2921
				end -- 2921
				::__continue470:: -- 2921
				i = i - 1 -- 2916
			end -- 2916
		end -- 2916
	end -- 2916
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2925
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2928
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2932
	upsertStep( -- 2934
		session.id, -- 2934
		questionnaire.taskId, -- 2934
		questionnaire.step, -- 2934
		"ask_user", -- 2934
		{status = "DONE", result = result} -- 2934
	) -- 2934
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 2938
	upsertStep( -- 2939
		session.id, -- 2939
		questionnaire.taskId, -- 2939
		answerStep, -- 2939
		"questionnaire_answer", -- 2939
		{status = "DONE", result = result} -- 2939
	) -- 2939
	return {success = true, answerStep = answerStep, result = result} -- 2943
end -- 2874
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 2946
	local session = getSessionItem(sessionId) -- 2947
	if not session then -- 2947
		return {success = false, message = "session not found"} -- 2948
	end -- 2948
	if session.kind ~= "main" then -- 2948
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2949
	end -- 2949
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2950
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2950
		return {success = false, message = "pending questionnaire not found or already handled"} -- 2952
	end -- 2952
	local llmConfigRes = getLLMConfig(llmConfigId) -- 2954
	if not llmConfigRes.success then -- 2954
		return {success = false, message = llmConfigRes.message} -- 2955
	end -- 2955
	if not removePendingQuestionnaire(session) then -- 2955
		return {success = false, message = "failed to consume questionnaire file"} -- 2956
	end -- 2956
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 2957
	if not replaced.success then -- 2957
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 2959
		return replaced -- 2960
	end -- 2960
	local t = now() -- 2962
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 2963
	session.workMode = "plan" -- 2964
	local result = startPromptTask( -- 2965
		session, -- 2965
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 2965
		nil, -- 2965
		{}, -- 2965
		{ -- 2965
			workMode = "plan", -- 2966
			persistUserMessage = false, -- 2967
			resumeConversation = true, -- 2968
			existingTaskId = questionnaire.taskId, -- 2969
			initialStep = replaced.answerStep, -- 2970
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 2971
			llmConfig = llmConfigRes.config -- 2972
		} -- 2972
	) -- 2972
	if not result.success then -- 2972
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 2975
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 2976
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 2977
		emitAgentSessionPatch( -- 2978
			session.id, -- 2978
			{ -- 2978
				session = getSessionItem(session.id), -- 2979
				pendingQuestionnaire = questionnaire -- 2980
			} -- 2980
		) -- 2980
		return result -- 2982
	end -- 2982
	emitAgentSessionPatch( -- 2984
		sessionId, -- 2984
		{ -- 2984
			session = getSessionItem(sessionId), -- 2985
			pendingQuestionnaire = false -- 2986
		} -- 2986
	) -- 2986
	return result -- 2988
end -- 2946
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 2991
	local session = getSessionItem(sessionId) -- 2992
	if not session then -- 2992
		return {success = false, message = "session not found"} -- 2993
	end -- 2993
	if session.kind ~= "main" then -- 2993
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2994
	end -- 2994
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2995
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2995
		return {success = false, message = "pending questionnaire not found"} -- 2996
	end -- 2996
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 2997
	if not validated.success then -- 2997
		return validated -- 2998
	end -- 2998
	local llmConfigRes = getLLMConfig(llmConfigId) -- 2999
	if not llmConfigRes.success then -- 2999
		return {success = false, message = llmConfigRes.message} -- 3000
	end -- 3000
	local t = now() -- 3001
	if not removePendingQuestionnaire(session) then -- 3001
		return {success = false, message = "failed to consume questionnaire file"} -- 3002
	end -- 3002
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3003
	if not replaced.success then -- 3003
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3005
		return replaced -- 3006
	end -- 3006
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3008
	session.workMode = "plan" -- 3009
	local result = startPromptTask( -- 3010
		session, -- 3010
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3010
		nil, -- 3010
		{}, -- 3010
		{ -- 3010
			workMode = "plan", -- 3011
			persistUserMessage = false, -- 3012
			resumeConversation = true, -- 3013
			existingTaskId = questionnaire.taskId, -- 3014
			initialStep = replaced.answerStep, -- 3015
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3016
			llmConfig = llmConfigRes.config -- 3017
		} -- 3017
	) -- 3017
	if not result.success then -- 3017
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3020
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3021
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3022
		emitAgentSessionPatch( -- 3023
			session.id, -- 3023
			{ -- 3023
				session = getSessionItem(session.id), -- 3024
				pendingQuestionnaire = questionnaire -- 3025
			} -- 3025
		) -- 3025
		return result -- 3027
	end -- 3027
	emitAgentSessionPatch( -- 3029
		sessionId, -- 3029
		{ -- 3029
			session = getSessionItem(sessionId), -- 3030
			pendingQuestionnaire = false -- 3031
		} -- 3031
	) -- 3031
	return result -- 3033
end -- 2991
function ____exports.stopSessionTask(sessionId) -- 3036
	local session = getSessionItem(sessionId) -- 3037
	if not session or session.currentTaskId == nil then -- 3037
		return {success = false, message = "session task not found"} -- 3039
	end -- 3039
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3039
		return {success = false, message = "session task is finalizing"} -- 3042
	end -- 3042
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3044
	local stopToken = activeStopTokens[session.currentTaskId] -- 3045
	if not stopToken then -- 3045
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3045
			return {success = true, recovered = true} -- 3048
		end -- 3048
		return {success = false, message = "task is not running"} -- 3050
	end -- 3050
	if stopToken.stopped then -- 3050
		return {success = true, stopping = true} -- 3053
	end -- 3053
	stopToken.stopped = true -- 3055
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3056
	return {success = true, stopping = true} -- 3060
end -- 3036
function ____exports.getCurrentTaskId(sessionId) -- 3063
	local ____opt_123 = getSessionItem(sessionId) -- 3063
	return ____opt_123 and ____opt_123.currentTaskId -- 3064
end -- 3063
function ____exports.validateTaskAccess(sessionId, taskId) -- 3067
	local session = getSessionItem(sessionId) -- 3068
	if not session then -- 3068
		return {success = false, message = "session not found"} -- 3069
	end -- 3069
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3069
		getSessionOperableTaskIds(sessionId), -- 3070
		taskId -- 3070
	) < 0 then -- 3070
		return {success = false, message = "task is not operable for this session"} -- 3071
	end -- 3071
	return {success = true, session = session} -- 3073
end -- 3067
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3076
	if checkpointId <= 0 then -- 3076
		return {success = false, message = "invalid checkpointId"} -- 3078
	end -- 3078
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3080
	if not checkpoint then -- 3080
		return {success = false, message = "checkpoint not found"} -- 3082
	end -- 3082
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3084
	if not taskAccess.success then -- 3084
		return taskAccess -- 3085
	end -- 3085
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3086
end -- 3076
function ____exports.listRunningSessions() -- 3089
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3090
	local sessions = {} -- 3097
	do -- 3097
		local i = 0 -- 3098
		while i < #rows do -- 3098
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3099
			if session.currentTaskStatus == "RUNNING" then -- 3099
				sessions[#sessions + 1] = session -- 3101
			end -- 3101
			i = i + 1 -- 3098
		end -- 3098
	end -- 3098
	return {success = true, sessions = sessions} -- 3104
end -- 3089
return ____exports -- 3089
