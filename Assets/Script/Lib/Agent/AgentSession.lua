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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeStoppedTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
						tool = "search_dora_api", -- 446
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
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_api"}) or ({}) -- 534
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
			elseif tool == "search_dora_api" and #evidence.authoritativeSources < 8 then -- 558
				local ____evidence_authoritativeSources_10 = evidence.authoritativeSources -- 558
				____evidence_authoritativeSources_10[#____evidence_authoritativeSources_10 + 1] = { -- 561
					tool = "search_dora_api", -- 562
					query = takeUtf8Head( -- 563
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 563
						300 -- 563
					), -- 563
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docSource or "api"))), -- 564
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
		return true -- 726
	end -- 726
	Content:remove(tempPath) -- 727
	return false -- 728
end -- 728
function removePendingQuestionnaire(session) -- 731
	local path = getQuestionnairePath(session.projectRoot) -- 732
	if not Content:exist(path) then -- 732
		return true -- 733
	end -- 733
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 734
	if questionnaire and questionnaire.sessionId ~= session.id then -- 734
		return false -- 735
	end -- 735
	return Content:remove(path) -- 736
end -- 736
function publishQuestionnaire(request) -- 739
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 739
		local session = getSessionItem(request.sessionId) -- 745
		if not session or session.kind ~= "main" then -- 745
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 745
		end -- 745
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 747
		if Content:exist(pendingPath) then -- 747
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 747
		end -- 747
		local questionnaire = { -- 749
			id = request.taskId, -- 750
			sessionId = request.sessionId, -- 751
			taskId = request.taskId, -- 752
			step = request.step, -- 753
			status = "PENDING", -- 754
			schema = request.schema, -- 755
			createdAt = now() -- 756
		} -- 756
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 756
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 756
		end -- 756
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 756
	end) -- 756
end -- 756
function getMessageItem(messageId) -- 764
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 765
	return row and rowToMessage(row) or nil -- 771
end -- 771
function getStepItem(sessionId, taskId, step) -- 774
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 775
	return row and rowToStep(row) or nil -- 781
end -- 781
function deleteMessageSteps(sessionId, taskId) -- 784
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 785
	local ids = {} -- 790
	do -- 790
		local i = 0 -- 791
		while i < #rows do -- 791
			local row = rows[i + 1] -- 792
			if type(row[1]) == "number" then -- 792
				ids[#ids + 1] = row[1] -- 794
			end -- 794
			i = i + 1 -- 791
		end -- 791
	end -- 791
	if #ids > 0 then -- 791
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 798
	end -- 798
	return ids -- 804
end -- 804
function normalizeDisabledAgentTools(value) -- 807
	if not __TS__ArrayIsArray(value) then -- 807
		return {} -- 808
	end -- 808
	local tools = {} -- 809
	do -- 809
		local i = 0 -- 810
		while i < #value do -- 810
			do -- 810
				local name = value[i + 1] -- 811
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 811
					goto __continue121 -- 812
				end -- 812
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 812
					tools[#tools + 1] = name -- 813
				end -- 813
			end -- 813
			::__continue121:: -- 813
			i = i + 1 -- 810
		end -- 810
	end -- 810
	return tools -- 815
end -- 815
function normalizeWorkMode(value, fallback) -- 818
	if fallback == nil then -- 818
		fallback = "code" -- 818
	end -- 818
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 819
end -- 819
function getSessionRow(sessionId) -- 822
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 823
end -- 823
function getSessionItem(sessionId) -- 831
	local row = getSessionRow(sessionId) -- 832
	return row and rowToSession(row) or nil -- 833
end -- 833
function getTaskPrompt(taskId) -- 836
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 837
	if not row or type(row[1]) ~= "string" then -- 837
		return nil -- 838
	end -- 838
	return toStr(row[1]) -- 839
end -- 839
function getLatestMainSessionByProjectRoot(projectRoot) -- 842
	if not isValidProjectRoot(projectRoot) then -- 842
		return nil -- 843
	end -- 843
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 844
	return row and rowToSession(row) or nil -- 852
end -- 852
function countRunningSubSessions(rootSessionId) -- 855
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 856
	local count = 0 -- 863
	do -- 863
		local i = 0 -- 864
		while i < #rows do -- 864
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 865
			if session.currentTaskStatus == "RUNNING" then -- 865
				count = count + 1 -- 867
			end -- 867
			i = i + 1 -- 864
		end -- 864
	end -- 864
	return count -- 870
end -- 870
function deleteSessionRecords(sessionId, preserveArtifacts) -- 873
	if preserveArtifacts == nil then -- 873
		preserveArtifacts = false -- 873
	end -- 873
	local session = getSessionItem(sessionId) -- 874
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 875
	local taskIds = {} -- 883
	do -- 883
		local i = 0 -- 884
		while i < #taskRows do -- 884
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 885
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 885
				taskIds[#taskIds + 1] = taskId -- 886
			end -- 886
			i = i + 1 -- 884
		end -- 884
	end -- 884
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 888
	do -- 888
		local i = 0 -- 889
		while i < #children do -- 889
			local row = children[i + 1] -- 890
			if type(row[1]) == "number" and row[1] > 0 then -- 890
				deleteSessionRecords(row[1], preserveArtifacts) -- 892
			end -- 892
			i = i + 1 -- 889
		end -- 889
	end -- 889
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 895
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 896
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 897
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 898
	if session and session.kind == "main" then -- 898
		removePendingQuestionnaire(session) -- 900
	end -- 900
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 900
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 903
	end -- 903
	do -- 903
		local i = 0 -- 905
		while i < #taskIds do -- 905
			cleanupTaskHeavyData(taskIds[i + 1]) -- 906
			i = i + 1 -- 905
		end -- 905
	end -- 905
end -- 905
function getSessionRootId(session) -- 910
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 911
end -- 911
function getRootSessionItem(sessionId) -- 914
	local session = getSessionItem(sessionId) -- 915
	if not session then -- 915
		return nil -- 916
	end -- 916
	return getSessionItem(getSessionRootId(session)) or session -- 917
end -- 917
function listRelatedSessions(sessionId) -- 920
	local root = getRootSessionItem(sessionId) -- 921
	if not root then -- 921
		return {} -- 922
	end -- 922
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 923
	return __TS__ArrayMap( -- 932
		rows, -- 932
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 932
	) -- 932
end -- 932
function getSessionSpawnInfo(session) -- 935
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 936
	if not info then -- 936
		return nil -- 937
	end -- 937
	local ____temp_16 = type(info.sessionId) == "number" and info.sessionId or nil -- 939
	local ____temp_17 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 940
	local ____temp_18 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 941
	local ____temp_19 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 942
	local ____temp_20 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 943
	local ____temp_21 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 944
	local ____temp_22 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 945
	local ____temp_23 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 946
		__TS__ArrayFilter( -- 947
			info.filesHint, -- 947
			function(____, item) return type(item) == "string" end -- 947
		), -- 947
		function(____, item) return sanitizeUTF8(item) end -- 947
	) or nil -- 947
	local ____temp_24 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 949
	local ____temp_14 -- 952
	if info.success == true then -- 952
		____temp_14 = true -- 952
	else -- 952
		local ____temp_13 -- 952
		if info.success == false then -- 952
			____temp_13 = false -- 952
		else -- 952
			____temp_13 = nil -- 952
		end -- 952
		____temp_14 = ____temp_13 -- 952
	end -- 952
	local ____temp_15 -- 953
	if info.cleared == true then -- 953
		____temp_15 = true -- 953
	else -- 953
		____temp_15 = nil -- 953
	end -- 953
	return { -- 938
		sessionId = ____temp_16, -- 939
		rootSessionId = ____temp_17, -- 940
		parentSessionId = ____temp_18, -- 941
		title = ____temp_19, -- 942
		prompt = ____temp_20, -- 943
		goal = ____temp_21, -- 944
		expectedOutput = ____temp_22, -- 945
		filesHint = ____temp_23, -- 946
		status = ____temp_24, -- 949
		success = ____temp_14, -- 952
		cleared = ____temp_15, -- 953
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 954
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 955
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 956
		changeSet = decodeChangeSetSummary(info.changeSet), -- 957
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 958
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 959
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 960
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 961
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 964
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 965
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 966
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 967
	} -- 967
end -- 967
function ensureDirRecursive(dir) -- 984
	if not dir or dir == "" then -- 984
		return false -- 985
	end -- 985
	if Content:exist(dir) then -- 985
		return Content:isdir(dir) -- 986
	end -- 986
	local parent = Path:getPath(dir) -- 987
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 987
		if not ensureDirRecursive(parent) then -- 987
			return false -- 990
		end -- 990
	end -- 990
	return Content:mkdir(dir) -- 993
end -- 993
function writeSpawnInfo(projectRoot, memoryScope, value) -- 996
	local dir = Path(projectRoot, ".agent", memoryScope) -- 997
	if not Content:exist(dir) then -- 997
		ensureDirRecursive(dir) -- 999
	end -- 999
	local path = Path(dir, SPAWN_INFO_FILE) -- 1001
	local text = safeJsonEncode(value) -- 1002
	if not text then -- 1002
		return false -- 1003
	end -- 1003
	local content = text .. "\n" -- 1004
	if not Content:save(path, content) then -- 1004
		return false -- 1006
	end -- 1006
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1008
	return true -- 1009
end -- 1009
function readSpawnInfo(projectRoot, memoryScope) -- 1012
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1013
	if not Content:exist(path) then -- 1013
		return nil -- 1014
	end -- 1014
	local text = Content:load(path) -- 1015
	if not text or __TS__StringTrim(text) == "" then -- 1015
		return nil -- 1016
	end -- 1016
	local value = safeJsonDecode(text) -- 1017
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1017
		return value -- 1019
	end -- 1019
	return nil -- 1021
end -- 1021
function getArtifactRelativeDir(memoryScope) -- 1024
	return Path(".agent", memoryScope) -- 1025
end -- 1025
function getArtifactDir(projectRoot, memoryScope) -- 1028
	return Path( -- 1029
		projectRoot, -- 1029
		getArtifactRelativeDir(memoryScope) -- 1029
	) -- 1029
end -- 1029
function getResultRelativePath(memoryScope) -- 1032
	return Path( -- 1033
		getArtifactRelativeDir(memoryScope), -- 1033
		RESULT_FILE -- 1033
	) -- 1033
end -- 1033
function getResultPath(projectRoot, memoryScope) -- 1036
	return Path( -- 1037
		projectRoot, -- 1037
		getResultRelativePath(memoryScope) -- 1037
	) -- 1037
end -- 1037
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1040
	if not resultFilePath or resultFilePath == "" then -- 1040
		return "" -- 1041
	end -- 1041
	local path = Path(projectRoot, resultFilePath) -- 1042
	if not Content:exist(path) then -- 1042
		return "" -- 1043
	end -- 1043
	local text = sanitizeUTF8(Content:load(path)) -- 1044
	if not text or __TS__StringTrim(text) == "" then -- 1044
		return "" -- 1045
	end -- 1045
	local marker = "\n## Summary\n" -- 1046
	local start = string.find(text, marker, 1, true) -- 1047
	if start ~= nil then -- 1047
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1049
	end -- 1049
	return __TS__StringTrim(text) -- 1051
end -- 1051
function buildStructuredSubAgentMemoryEntry(record) -- 1054
	local hasPassedValidation = false -- 1055
	do -- 1055
		local i = 0 -- 1056
		while i < #record.completion.validation do -- 1056
			local result = record.completion.validation[i + 1].result -- 1057
			if result == "failed" then -- 1057
				return nil -- 1062
			end -- 1062
			if result == "passed" then -- 1062
				hasPassedValidation = true -- 1064
			end -- 1064
			i = i + 1 -- 1056
		end -- 1056
	end -- 1056
	if not hasPassedValidation then -- 1056
		return nil -- 1067
	end -- 1067
	local candidates = record.completion.learningCandidates -- 1068
	local claims = {} -- 1069
	local evidence = {} -- 1070
	do -- 1070
		local i = 0 -- 1071
		while i < #candidates do -- 1071
			do -- 1071
				local candidate = candidates[i + 1] -- 1072
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1072
					goto __continue190 -- 1073
				end -- 1073
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1074
				do -- 1074
					local j = 0 -- 1075
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1075
						local item = candidate.evidence[j + 1] -- 1076
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1076
							evidence[#evidence + 1] = item -- 1077
						end -- 1077
						j = j + 1 -- 1075
					end -- 1075
				end -- 1075
			end -- 1075
			::__continue190:: -- 1075
			i = i + 1 -- 1071
		end -- 1071
	end -- 1071
	local content = takeUtf8Head( -- 1080
		table.concat(claims, "\n"), -- 1080
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1080
	) -- 1080
	if content == "" then -- 1080
		return nil -- 1081
	end -- 1081
	return { -- 1082
		sourceSessionId = record.sessionId, -- 1083
		sourceTaskId = record.sourceTaskId, -- 1084
		content = content, -- 1085
		evidence = evidence, -- 1086
		createdAt = record.finishedAt -- 1087
	} -- 1087
end -- 1087
function containsNormalizedText(text, query) -- 1091
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1092
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1093
	if normalizedQuery == "" then -- 1093
		return true -- 1094
	end -- 1094
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1095
end -- 1095
function getSubAgentDisplayKey(item) -- 1098
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1104
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1105
	local label = goal ~= "" and goal or title -- 1106
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1107
end -- 1107
function writeSubAgentResultFile(session, record, resultText) -- 1110
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1111
	if not Content:exist(dir) then -- 1111
		ensureDirRecursive(dir) -- 1113
	end -- 1113
	local ____array_33 = __TS__SparseArrayNew( -- 1113
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1116
		"- Status: " .. record.status, -- 1117
		"- Success: " .. (record.success and "true" or "false"), -- 1118
		"- Outcome: " .. record.completion.outcome, -- 1119
		"- Session ID: " .. tostring(record.sessionId), -- 1120
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1121
		"- Goal: " .. record.goal, -- 1122
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1123
	) -- 1123
	__TS__SparseArrayPush( -- 1123
		____array_33, -- 1123
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1124
	) -- 1124
	__TS__SparseArrayPush( -- 1124
		____array_33, -- 1124
		"- Finished At: " .. record.finishedAt, -- 1125
		"", -- 1126
		"## Validation", -- 1127
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1128
			record.completion.validation, -- 1129
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1129
		) or ({"- Not reported"})) -- 1129
	) -- 1129
	__TS__SparseArrayPush(____array_33, "", "## Recorded Evidence") -- 1129
	local ____opt_25 = record.handoffEvidence -- 1129
	__TS__SparseArrayPush( -- 1129
		____array_33, -- 1129
		table.unpack(____opt_25 and #____opt_25.modifiedFiles and __TS__ArrayMap( -- 1133
			record.handoffEvidence.modifiedFiles, -- 1134
			function(____, item) return "- modified: " .. item end -- 1134
		) or ({"- modified: none recorded"})) -- 1134
	) -- 1134
	local ____opt_27 = record.handoffEvidence -- 1134
	__TS__SparseArrayPush( -- 1134
		____array_33, -- 1134
		table.unpack(____opt_27 and ____opt_27.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1136
	) -- 1136
	local ____opt_29 = record.handoffEvidence -- 1136
	__TS__SparseArrayPush( -- 1136
		____array_33, -- 1136
		table.unpack(__TS__ArrayMap( -- 1139
			____opt_29 and ____opt_29.commands or ({}), -- 1139
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1139
		)) -- 1139
	) -- 1139
	local ____opt_31 = record.handoffEvidence -- 1139
	__TS__SparseArrayPush( -- 1139
		____array_33, -- 1139
		table.unpack(__TS__ArrayMap( -- 1140
			____opt_31 and ____opt_31.authoritativeSources or ({}), -- 1140
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1140
		)) -- 1140
	) -- 1140
	__TS__SparseArrayPush( -- 1140
		____array_33, -- 1140
		"", -- 1141
		"## Known Issues", -- 1142
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1143
			record.completion.knownIssues, -- 1143
			function(____, item) return "- " .. item end -- 1143
		) or ({"- None reported"})) -- 1143
	) -- 1143
	__TS__SparseArrayPush( -- 1143
		____array_33, -- 1143
		"", -- 1144
		"## Assumptions", -- 1145
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1146
			record.completion.assumptions, -- 1146
			function(____, item) return "- " .. item end -- 1146
		) or ({"- None reported"})) -- 1146
	) -- 1146
	__TS__SparseArrayPush(____array_33, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1146
	local lines = {__TS__SparseArraySpread(____array_33)} -- 1115
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1151
	local content = table.concat(lines, "\n") .. "\n" -- 1152
	if not Content:save(path, content) then -- 1152
		return false -- 1154
	end -- 1154
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1156
	return true -- 1157
end -- 1157
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1160
	local dir = Path(projectRoot, ".agent", "subagents") -- 1161
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1161
		return {} -- 1162
	end -- 1162
	local items = {} -- 1163
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1164
		do -- 1164
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1165
			if not Content:exist(path) or not Content:isdir(path) then -- 1165
				goto __continue210 -- 1166
			end -- 1166
			local info = readSpawnInfo( -- 1167
				projectRoot, -- 1167
				Path( -- 1167
					"subagents", -- 1167
					Path:getFilename(path) -- 1167
				) -- 1167
			) -- 1167
			if not info then -- 1167
				goto __continue210 -- 1168
			end -- 1168
			local sessionId = tonumber(info.sessionId) -- 1169
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1170
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1171
			local status = sanitizeUTF8(toStr(info.status)) -- 1172
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1172
				goto __continue210 -- 1173
			end -- 1173
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1173
				goto __continue210 -- 1174
			end -- 1174
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1175
			items[#items + 1] = { -- 1176
				sessionId = sessionId, -- 1177
				rootSessionId = infoRootSessionId, -- 1178
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1179
				title = sanitizeUTF8(toStr(info.title)), -- 1180
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1181
				goal = sanitizeUTF8(toStr(info.goal)), -- 1182
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1183
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1184
					__TS__ArrayFilter( -- 1185
						info.filesHint, -- 1185
						function(____, item) return type(item) == "string" end -- 1185
					), -- 1185
					function(____, item) return sanitizeUTF8(item) end -- 1185
				) or ({}), -- 1185
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1187
				success = info.success == true, -- 1188
				cleared = info.cleared == true, -- 1189
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1190
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1191
					"subagents", -- 1191
					Path:getFilename(path) -- 1191
				)), -- 1191
				sourceTaskId = sourceTaskId or 0, -- 1192
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1193
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1194
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1195
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1196
				completion = normalizeAgentCompletionReport(info.completion), -- 1197
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1198
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1199
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1200
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1201
			} -- 1201
		end -- 1201
		::__continue210:: -- 1201
	end -- 1201
	__TS__ArraySort( -- 1204
		items, -- 1204
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1204
	) -- 1204
	return items -- 1205
end -- 1205
function getPendingHandoffDir(projectRoot, memoryScope) -- 1208
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1209
end -- 1209
function writePendingHandoff(projectRoot, memoryScope, value) -- 1212
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1213
	if not Content:exist(dir) then -- 1213
		ensureDirRecursive(dir) -- 1215
	end -- 1215
	local path = Path(dir, value.id .. ".json") -- 1217
	local text = safeJsonEncode(value) -- 1218
	if not text then -- 1218
		return false -- 1219
	end -- 1219
	return Content:save(path, text .. "\n") -- 1220
end -- 1220
function listPendingHandoffs(projectRoot, memoryScope) -- 1223
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1224
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1224
		return {} -- 1225
	end -- 1225
	local items = {} -- 1226
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1227
		do -- 1227
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1228
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1228
				goto __continue225 -- 1229
			end -- 1229
			local text = Content:load(path) -- 1230
			if not text or __TS__StringTrim(text) == "" then -- 1230
				goto __continue225 -- 1231
			end -- 1231
			local obj = safeJsonDecode(text) -- 1232
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1232
				goto __continue225 -- 1233
			end -- 1233
			local value = obj -- 1234
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1235
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1236
			local id = sanitizeUTF8(toStr(value.id)) -- 1237
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1238
			local message = sanitizeUTF8(toStr(value.message)) -- 1239
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1240
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1241
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1242
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1242
				goto __continue225 -- 1244
			end -- 1244
			items[#items + 1] = { -- 1246
				id = id, -- 1247
				sourceSessionId = sourceSessionId, -- 1248
				sourceTitle = sourceTitle, -- 1249
				sourceTaskId = sourceTaskId, -- 1250
				message = message, -- 1251
				prompt = prompt, -- 1252
				goal = goal, -- 1253
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1254
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1255
					__TS__ArrayFilter( -- 1256
						value.filesHint, -- 1256
						function(____, item) return type(item) == "string" end -- 1256
					), -- 1256
					function(____, item) return sanitizeUTF8(item) end -- 1256
				) or ({}), -- 1256
				success = value.success == true, -- 1258
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1259
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1260
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1261
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1262
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1263
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1264
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1265
				createdAt = createdAt -- 1268
			} -- 1268
		end -- 1268
		::__continue225:: -- 1268
	end -- 1268
	__TS__ArraySort( -- 1271
		items, -- 1271
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1271
	) -- 1271
	return items -- 1272
end -- 1272
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1275
	local path = Path( -- 1276
		getPendingHandoffDir(projectRoot, memoryScope), -- 1276
		id .. ".json" -- 1276
	) -- 1276
	if Content:exist(path) then -- 1276
		Content:remove(path) -- 1278
	end -- 1278
end -- 1278
function normalizePromptText(prompt) -- 1282
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1283
end -- 1283
function normalizePromptTextSafe(prompt) -- 1286
	if type(prompt) == "string" then -- 1286
		local normalized = normalizePromptText(prompt) -- 1288
		if normalized ~= "" then -- 1288
			return normalized -- 1289
		end -- 1289
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1290
		if sanitized ~= "" then -- 1290
			return truncateAgentUserPrompt(sanitized) -- 1292
		end -- 1292
		return "" -- 1294
	end -- 1294
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1296
	if text == "" then -- 1296
		return "" -- 1297
	end -- 1297
	return truncateAgentUserPrompt(text) -- 1298
end -- 1298
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1301
	local sections = {} -- 1302
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1303
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1304
	local normalizedFiles = __TS__ArrayFilter( -- 1305
		__TS__ArrayMap( -- 1305
			__TS__ArrayFilter( -- 1305
				filesHint or ({}), -- 1305
				function(____, item) return type(item) == "string" end -- 1306
			), -- 1306
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1307
		), -- 1307
		function(____, item) return item ~= "" end -- 1308
	) -- 1308
	if normalizedTitle ~= "" then -- 1308
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1310
	end -- 1310
	if normalizedExpected ~= "" then -- 1310
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1313
	end -- 1313
	if #normalizedFiles > 0 then -- 1313
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1316
	end -- 1316
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1318
end -- 1318
function normalizeSessionRuntimeState(session) -- 1321
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1321
		return session -- 1323
	end -- 1323
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1323
		return session -- 1326
	end -- 1326
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1328
	if #pendingToolRows > 0 then -- 1328
		local t = now() -- 1334
		do -- 1334
			local i = 0 -- 1335
			while i < #pendingToolRows do -- 1335
				local row = pendingToolRows[i + 1] -- 1336
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1337
				result.success = false -- 1338
				result.state = "failed" -- 1339
				result.interrupted = true -- 1340
				result.message = "tool call was interrupted because the program exited before it completed." -- 1341
				DB:exec( -- 1342
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1342
					{ -- 1344
						encodeJson(result), -- 1344
						t, -- 1344
						row[1] -- 1344
					} -- 1344
				) -- 1344
				i = i + 1 -- 1335
			end -- 1335
		end -- 1335
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1347
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1348
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1349
	end -- 1349
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1356
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1357
	return __TS__ObjectAssign( -- 1358
		{}, -- 1358
		session, -- 1359
		{ -- 1358
			status = "STOPPED", -- 1360
			currentTaskStatus = "STOPPED", -- 1361
			updatedAt = now() -- 1362
		} -- 1362
	) -- 1362
end -- 1362
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1366
	DB:exec( -- 1367
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1367
		{ -- 1371
			status, -- 1372
			currentTaskId or 0, -- 1373
			currentTaskStatus or status, -- 1374
			now(), -- 1375
			sessionId -- 1376
		} -- 1376
	) -- 1376
end -- 1376
function mergeAgentMetrics(current, next) -- 1381
	return __TS__ObjectAssign({}, current or ({}), next) -- 1382
end -- 1382
function updateSessionMetrics(sessionId, metrics) -- 1388
	local session = getSessionItem(sessionId) -- 1389
	if not session then -- 1389
		return nil -- 1390
	end -- 1390
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1391
	DB:exec( -- 1392
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1392
		{ -- 1396
			encodeJson(merged), -- 1397
			now(), -- 1398
			sessionId -- 1399
		} -- 1399
	) -- 1399
	return merged -- 1402
end -- 1402
function clearSessionTokenUsage(sessionId) -- 1405
	local session = getSessionItem(sessionId) -- 1406
	if not session then -- 1406
		return nil -- 1407
	end -- 1407
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1408
	__TS__Delete(metrics, "usage") -- 1409
	DB:exec( -- 1410
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1410
		{ -- 1414
			encodeJson(metrics), -- 1415
			now(), -- 1416
			sessionId -- 1417
		} -- 1417
	) -- 1417
	return metrics -- 1420
end -- 1420
function getInitialTokenUsage(session) -- 1423
	local ____opt_34 = session.metrics -- 1423
	local usage = ____opt_34 and ____opt_34.usage -- 1424
	if not usage or (usage.requestCount or 0) <= 0 then -- 1424
		return nil -- 1425
	end -- 1425
	return { -- 1426
		inputTokens = usage.inputTokens or 0, -- 1427
		outputTokens = usage.outputTokens or 0, -- 1428
		totalTokens = usage.totalTokens, -- 1429
		cachedInputTokens = usage.cachedInputTokens, -- 1430
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1431
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1432
		requestCount = usage.requestCount or 0, -- 1433
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1434
		model = usage.model or "", -- 1435
		phase = usage.phase or "", -- 1436
		step = usage.step or 0, -- 1437
		updatedAt = usage.updatedAt or now() -- 1438
	} -- 1438
end -- 1438
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1442
	if taskId == nil or taskId <= 0 then -- 1442
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1444
		return -- 1445
	end -- 1445
	local row = getSessionRow(sessionId) -- 1447
	if not row then -- 1447
		return -- 1448
	end -- 1448
	local session = rowToSession(row) -- 1449
	if session.currentTaskId ~= taskId then -- 1449
		Log( -- 1451
			"Info", -- 1451
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1451
		) -- 1451
		return -- 1452
	end -- 1452
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1454
end -- 1454
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1457
	local t = now() -- 1458
	DB:exec( -- 1459
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1459
		{ -- 1462
			sessionId, -- 1463
			taskId or 0, -- 1464
			role, -- 1465
			sanitizeUTF8(content), -- 1466
			displayContent and sanitizeUTF8(displayContent) or "", -- 1467
			t, -- 1468
			t -- 1469
		} -- 1469
	) -- 1469
	return getLastInsertRowId() -- 1472
end -- 1472
function updateMessage(messageId, content) -- 1475
	DB:exec( -- 1476
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1476
		{ -- 1478
			sanitizeUTF8(content), -- 1478
			now(), -- 1478
			messageId -- 1478
		} -- 1478
	) -- 1478
end -- 1478
function updateUserMessageForTask(messageId, content, taskId) -- 1482
	DB:exec( -- 1483
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1483
		{ -- 1487
			sanitizeUTF8(content), -- 1487
			taskId, -- 1487
			now(), -- 1487
			messageId -- 1487
		} -- 1487
	) -- 1487
end -- 1487
function removeStoppedTaskSummary(session) -- 1544
	local taskId = session.currentTaskId -- 1545
	if taskId == nil then -- 1545
		return -- 1546
	end -- 1546
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1547
end -- 1547
function upsertAssistantMessage(sessionId, taskId, content) -- 1559
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1560
	if row and type(row[1]) == "number" then -- 1560
		updateMessage(row[1], content) -- 1567
		return row[1] -- 1568
	end -- 1568
	return insertMessage(sessionId, "assistant", content, taskId) -- 1570
end -- 1570
function upsertStep(sessionId, taskId, step, tool, patch) -- 1573
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1583
	local reason = sanitizeUTF8(patch.reason or "") -- 1587
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1588
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1589
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1590
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1591
	local statusPatch = patch.status or "" -- 1592
	local status = patch.status or "PENDING" -- 1593
	if not row then -- 1593
		local t = now() -- 1595
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1596
			sessionId, -- 1600
			taskId, -- 1601
			step, -- 1602
			tool, -- 1603
			status, -- 1604
			reason, -- 1605
			reasoningContent, -- 1606
			paramsJson, -- 1607
			resultJson, -- 1608
			patch.checkpointId or 0, -- 1609
			patch.checkpointSeq or 0, -- 1610
			filesJson, -- 1611
			t, -- 1612
			t -- 1613
		}) -- 1613
		return -- 1616
	end -- 1616
	DB:exec( -- 1618
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1618
		{ -- 1630
			tool, -- 1631
			statusPatch, -- 1632
			status, -- 1633
			reason, -- 1634
			reason, -- 1635
			reasoningContent, -- 1636
			reasoningContent, -- 1637
			paramsJson, -- 1638
			paramsJson, -- 1639
			resultJson, -- 1640
			resultJson, -- 1641
			patch.checkpointId or 0, -- 1642
			patch.checkpointId or 0, -- 1643
			patch.checkpointSeq or 0, -- 1644
			patch.checkpointSeq or 0, -- 1645
			filesJson, -- 1646
			filesJson, -- 1647
			now(), -- 1648
			row[1] -- 1649
		} -- 1649
	) -- 1649
end -- 1649
function getNextStepNumber(sessionId, taskId) -- 1654
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1655
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1659
	return math.max(0, current) + 1 -- 1660
end -- 1660
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1701
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1709
	local t = now() -- 1710
	local sqls = { -- 1711
		{ -- 1712
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1712
			{{ -- 1715
				sessionId, -- 1716
				ownerTaskId, -- 1717
				step, -- 1718
				"sub_agent_handoff", -- 1719
				"DONE", -- 1720
				sanitizeUTF8(reason), -- 1721
				encodeJson(params), -- 1722
				encodeJson(result), -- 1723
				t, -- 1724
				t -- 1725
			}} -- 1725
		}, -- 1725
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1728
	} -- 1728
	if not DB:transaction(sqls) then -- 1728
		return nil -- 1734
	end -- 1734
	return getStepItem(sessionId, ownerTaskId, step) -- 1735
end -- 1735
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1738
	if taskId <= 0 then -- 1738
		return -- 1739
	end -- 1739
	if finalSteps ~= nil and finalSteps >= 0 then -- 1739
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1741
	end -- 1741
	if not finalStatus then -- 1741
		return -- 1747
	end -- 1747
	if finalSteps ~= nil and finalSteps >= 0 then -- 1747
		DB:exec( -- 1749
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1749
			{ -- 1753
				finalStatus, -- 1753
				now(), -- 1753
				sessionId, -- 1753
				taskId, -- 1753
				finalSteps -- 1753
			} -- 1753
		) -- 1753
		return -- 1755
	end -- 1755
	DB:exec( -- 1757
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1757
		{ -- 1761
			finalStatus, -- 1761
			now(), -- 1761
			sessionId, -- 1761
			taskId -- 1761
		} -- 1761
	) -- 1761
end -- 1761
function emitAgentSessionPatch(sessionId, patch) -- 1788
	if HttpServer.wsConnectionCount == 0 then -- 1788
		return -- 1790
	end -- 1790
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1792
	if not text then -- 1792
		return -- 1797
	end -- 1797
	emit("AppWS", "Send", text) -- 1798
end -- 1798
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1801
	emitAgentSessionPatch( -- 1802
		sessionId, -- 1802
		{ -- 1802
			sessionDeleted = true, -- 1803
			relatedSessions = listRelatedSessions(rootSessionId) -- 1804
		} -- 1804
	) -- 1804
	local rootSession = getSessionItem(rootSessionId) -- 1806
	if rootSession then -- 1806
		emitAgentSessionPatch( -- 1808
			rootSessionId, -- 1808
			{ -- 1808
				session = rootSession, -- 1809
				relatedSessions = listRelatedSessions(rootSessionId) -- 1810
			} -- 1810
		) -- 1810
	end -- 1810
end -- 1810
function flushPendingSubAgentHandoffs(rootSession) -- 1815
	if rootSession.kind ~= "main" then -- 1815
		return -- 1816
	end -- 1816
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1816
		return -- 1818
	end -- 1818
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1820
	if #items == 0 then -- 1820
		return -- 1821
	end -- 1821
	local handoffTaskId = 0 -- 1822
	local previousTaskId = rootSession.currentTaskId -- 1823
	local ____rootSession_currentTaskId_38 -- 1824
	if rootSession.currentTaskId then -- 1824
		____rootSession_currentTaskId_38 = getTaskPrompt(rootSession.currentTaskId) -- 1824
	else -- 1824
		____rootSession_currentTaskId_38 = nil -- 1824
	end -- 1824
	local currentTaskPrompt = ____rootSession_currentTaskId_38 -- 1824
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1824
		handoffTaskId = rootSession.currentTaskId -- 1832
	else -- 1832
		local taskRes = Tools.createTask( -- 1834
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1834
			"code" -- 1834
		) -- 1834
		if not taskRes.success then -- 1834
			Log( -- 1836
				"Warn", -- 1836
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1836
			) -- 1836
			return -- 1837
		end -- 1837
		handoffTaskId = taskRes.taskId -- 1839
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1840
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1841
		emitAgentSessionPatch( -- 1842
			rootSession.id, -- 1842
			{session = getSessionItem(rootSession.id)} -- 1842
		) -- 1842
	end -- 1842
	do -- 1842
		local i = 0 -- 1846
		while i < #items do -- 1846
			local item = items[i + 1] -- 1847
			local step = appendHandoffSystemStep( -- 1848
				rootSession.id, -- 1849
				handoffTaskId, -- 1850
				item.sourceTaskId, -- 1851
				item.message, -- 1852
				{ -- 1853
					sourceSessionId = item.sourceSessionId, -- 1854
					sourceTitle = item.sourceTitle, -- 1855
					sourceTaskId = item.sourceTaskId, -- 1856
					success = item.success == true, -- 1857
					summary = item.message, -- 1858
					resultFilePath = item.resultFilePath or "", -- 1859
					artifactDir = item.artifactDir or "", -- 1860
					finishedAt = item.finishedAt or "", -- 1861
					changeSet = item.changeSet, -- 1862
					handoffEvidence = item.handoffEvidence, -- 1863
					memoryEntry = item.memoryEntry, -- 1864
					completion = item.completion -- 1865
				}, -- 1865
				{ -- 1867
					sourceSessionId = item.sourceSessionId, -- 1868
					sourceTitle = item.sourceTitle, -- 1869
					sourceTaskId = item.sourceTaskId, -- 1870
					prompt = item.prompt, -- 1871
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1872
					expectedOutput = item.expectedOutput or "", -- 1873
					filesHint = item.filesHint or ({}), -- 1874
					resultFilePath = item.resultFilePath or "", -- 1875
					artifactDir = item.artifactDir or "", -- 1876
					changeSet = item.changeSet, -- 1877
					handoffEvidence = item.handoffEvidence, -- 1878
					memoryEntry = item.memoryEntry, -- 1879
					completion = item.completion -- 1880
				} -- 1880
			) -- 1880
			if step then -- 1880
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1884
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1885
			else -- 1885
				Log( -- 1887
					"Warn", -- 1887
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 1887
				) -- 1887
			end -- 1887
			i = i + 1 -- 1846
		end -- 1846
	end -- 1846
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 1846
		cleanupTaskHeavyData(previousTaskId) -- 1891
	end -- 1891
end -- 1891
function applyEvent(sessionId, event) -- 1903
	repeat -- 1903
		local ____switch315 = event.type -- 1903
		local metrics, startedSession -- 1903
		local ____cond315 = ____switch315 == "task_started" -- 1903
		if ____cond315 then -- 1903
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1906
			local ____event_resumed_41 -- 1907
			if event.resumed then -- 1907
				local ____opt_39 = getSessionItem(sessionId) -- 1907
				____event_resumed_41 = ____opt_39 and ____opt_39.metrics -- 1908
			else -- 1908
				____event_resumed_41 = clearSessionTokenUsage(sessionId) -- 1909
			end -- 1909
			metrics = ____event_resumed_41 -- 1907
			startedSession = getSessionItem(sessionId) -- 1910
			emitAgentSessionPatch( -- 1911
				sessionId, -- 1911
				{ -- 1911
					session = startedSession, -- 1912
					metrics = metrics, -- 1913
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1914
				} -- 1914
			) -- 1914
			break -- 1918
		end -- 1918
		____cond315 = ____cond315 or ____switch315 == "decision_made" -- 1918
		if ____cond315 then -- 1918
			upsertStep( -- 1920
				sessionId, -- 1920
				event.taskId, -- 1920
				event.step, -- 1920
				event.tool, -- 1920
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1920
			) -- 1920
			emitAgentSessionPatch( -- 1928
				sessionId, -- 1928
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1928
			) -- 1928
			break -- 1931
		end -- 1931
		____cond315 = ____cond315 or ____switch315 == "tool_started" -- 1931
		if ____cond315 then -- 1931
			upsertStep( -- 1933
				sessionId, -- 1933
				event.taskId, -- 1933
				event.step, -- 1933
				event.tool, -- 1933
				{status = "RUNNING"} -- 1933
			) -- 1933
			emitAgentSessionPatch( -- 1936
				sessionId, -- 1936
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1936
			) -- 1936
			break -- 1939
		end -- 1939
		____cond315 = ____cond315 or ____switch315 == "tool_finished" -- 1939
		if ____cond315 then -- 1939
			do -- 1939
				local ____temp_44 = event.result.success ~= true -- 1941
				if ____temp_44 then -- 1941
					local ____opt_42 = activeStopTokens[event.taskId] -- 1941
					____temp_44 = (____opt_42 and ____opt_42.stopped) == true -- 1941
				end -- 1941
				local stopped = ____temp_44 -- 1941
				upsertStep( -- 1943
					sessionId, -- 1943
					event.taskId, -- 1943
					event.step, -- 1943
					event.tool, -- 1943
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1943
				) -- 1943
				emitAgentSessionPatch( -- 1951
					sessionId, -- 1951
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1951
				) -- 1951
				break -- 1954
			end -- 1954
		end -- 1954
		____cond315 = ____cond315 or ____switch315 == "tool_progress" -- 1954
		if ____cond315 then -- 1954
			do -- 1954
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1958
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1958
					break -- 1960
				end -- 1960
			end -- 1960
			upsertStep( -- 1963
				sessionId, -- 1963
				event.taskId, -- 1963
				event.step, -- 1963
				event.tool, -- 1963
				{status = "RUNNING", result = event.result} -- 1963
			) -- 1963
			emitAgentSessionPatch( -- 1967
				sessionId, -- 1967
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1967
			) -- 1967
			break -- 1970
		end -- 1970
		____cond315 = ____cond315 or ____switch315 == "checkpoint_created" -- 1970
		if ____cond315 then -- 1970
			upsertStep( -- 1972
				sessionId, -- 1972
				event.taskId, -- 1972
				event.step, -- 1972
				event.tool, -- 1972
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1972
			) -- 1972
			emitAgentSessionPatch( -- 1977
				sessionId, -- 1977
				{ -- 1977
					step = getStepItem(sessionId, event.taskId, event.step), -- 1978
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 1979
				} -- 1979
			) -- 1979
			break -- 1981
		end -- 1981
		____cond315 = ____cond315 or ____switch315 == "memory_compression_started" -- 1981
		if ____cond315 then -- 1981
			upsertStep( -- 1983
				sessionId, -- 1983
				event.taskId, -- 1983
				event.step, -- 1983
				event.tool, -- 1983
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1983
			) -- 1983
			emitAgentSessionPatch( -- 1988
				sessionId, -- 1988
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1988
			) -- 1988
			break -- 1991
		end -- 1991
		____cond315 = ____cond315 or ____switch315 == "memory_compression_finished" -- 1991
		if ____cond315 then -- 1991
			upsertStep( -- 1993
				sessionId, -- 1993
				event.taskId, -- 1993
				event.step, -- 1993
				event.tool, -- 1993
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1993
			) -- 1993
			emitAgentSessionPatch( -- 1998
				sessionId, -- 1998
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1998
			) -- 1998
			break -- 2001
		end -- 2001
		____cond315 = ____cond315 or ____switch315 == "metrics_updated" -- 2001
		if ____cond315 then -- 2001
			do -- 2001
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2003
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2004
				break -- 2007
			end -- 2007
		end -- 2007
		____cond315 = ____cond315 or ____switch315 == "assistant_message_updated" -- 2007
		if ____cond315 then -- 2007
			do -- 2007
				upsertStep( -- 2010
					sessionId, -- 2010
					event.taskId, -- 2010
					event.step, -- 2010
					"message", -- 2010
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 2010
				) -- 2010
				emitAgentSessionPatch( -- 2015
					sessionId, -- 2015
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2015
				) -- 2015
				break -- 2018
			end -- 2018
		end -- 2018
		____cond315 = ____cond315 or ____switch315 == "task_waiting_for_user" -- 2018
		if ____cond315 then -- 2018
			do -- 2018
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2021
				__TS__Delete(activeStopTokens, event.taskId) -- 2022
				emitAgentSessionPatch( -- 2023
					sessionId, -- 2023
					{ -- 2023
						session = getSessionItem(sessionId), -- 2024
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2025
					} -- 2025
				) -- 2025
				break -- 2027
			end -- 2027
		end -- 2027
		____cond315 = ____cond315 or ____switch315 == "task_finished" -- 2027
		if ____cond315 then -- 2027
			do -- 2027
				local session = getSessionItem(sessionId) -- 2030
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2030
					__TS__Delete(activeStopTokens, event.taskId) -- 2032
					Log( -- 2033
						"Info", -- 2033
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2033
					) -- 2033
					break -- 2034
				end -- 2034
				local ____opt_45 = activeStopTokens[event.taskId or -1] -- 2034
				local stopped = (____opt_45 and ____opt_45.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2036
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2038
				local isSubSession = (session and session.kind) == "sub" -- 2041
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2042
				if isSubSession and event.taskId ~= nil then -- 2042
					finalizingSubSessionTaskIds[event.taskId] = true -- 2044
				end -- 2044
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2046
				if event.taskId ~= nil then -- 2046
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2048
					local ____finalizeTaskSteps_51 = finalizeTaskSteps -- 2049
					local ____array_50 = __TS__SparseArrayNew( -- 2049
						sessionId, -- 2050
						event.taskId, -- 2051
						type(event.steps) == "number" and math.max( -- 2052
							0, -- 2052
							math.floor(event.steps) -- 2052
						) or nil -- 2052
					) -- 2052
					local ____event_success_49 -- 2053
					if event.success then -- 2053
						____event_success_49 = nil -- 2053
					else -- 2053
						____event_success_49 = stopped and "STOPPED" or "FAILED" -- 2053
					end -- 2053
					__TS__SparseArrayPush(____array_50, ____event_success_49) -- 2053
					____finalizeTaskSteps_51(__TS__SparseArraySpread(____array_50)) -- 2049
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2055
					if not isSubSession then -- 2055
						__TS__Delete(activeStopTokens, event.taskId) -- 2057
					end -- 2057
					emitAgentSessionPatch( -- 2059
						sessionId, -- 2059
						{ -- 2059
							session = getSessionItem(sessionId), -- 2060
							message = getMessageItem(messageId), -- 2061
							removedStepIds = removedStepIds -- 2062
						} -- 2062
					) -- 2062
				end -- 2062
				if session and session.kind == "main" then -- 2062
					flushPendingSubAgentHandoffs(session) -- 2066
				end -- 2066
				break -- 2068
			end -- 2068
		end -- 2068
	until true -- 2068
end -- 2068
function ____exports.createSession(projectRoot, title) -- 2073
	if title == nil then -- 2073
		title = "" -- 2073
	end -- 2073
	local storage = requireAgentStorage() -- 2074
	if not storage.success then -- 2074
		return storage -- 2075
	end -- 2075
	if not isValidProjectRoot(projectRoot) then -- 2075
		return {success = false, message = "invalid projectRoot"} -- 2077
	end -- 2077
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2079
	if row then -- 2079
		return { -- 2088
			success = true, -- 2088
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2088
		} -- 2088
	end -- 2088
	local t = now() -- 2090
	DB:exec( -- 2091
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 2091
		{ -- 2094
			projectRoot, -- 2094
			title ~= "" and title or Path:getFilename(projectRoot), -- 2094
			t, -- 2094
			t -- 2094
		} -- 2094
	) -- 2094
	local sessionId = getLastInsertRowId() -- 2096
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2097
	local session = getSessionItem(sessionId) -- 2098
	if not session then -- 2098
		return {success = false, message = "failed to create session"} -- 2100
	end -- 2100
	return {success = true, session = session} -- 2102
end -- 2073
function ____exports.createSubSession(parentSessionId, title) -- 2105
	if title == nil then -- 2105
		title = "" -- 2105
	end -- 2105
	local storage = requireAgentStorage() -- 2106
	if not storage.success then -- 2106
		return storage -- 2107
	end -- 2107
	local parent = getSessionItem(parentSessionId) -- 2108
	if not parent then -- 2108
		return {success = false, message = "parent session not found"} -- 2110
	end -- 2110
	local rootId = getSessionRootId(parent) -- 2112
	local t = now() -- 2113
	DB:exec( -- 2114
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2114
		{ -- 2117
			parent.projectRoot, -- 2117
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2117
			rootId, -- 2117
			parent.id, -- 2117
			t, -- 2117
			t -- 2117
		} -- 2117
	) -- 2117
	local sessionId = getLastInsertRowId() -- 2119
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2120
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2121
	local session = getSessionItem(sessionId) -- 2122
	if not session then -- 2122
		return {success = false, message = "failed to create sub session"} -- 2124
	end -- 2124
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2126
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2127
	subStorage:writeMemory(parentStorage:readMemory()) -- 2128
	return {success = true, session = session} -- 2129
end -- 2105
function spawnSubAgentSession(request) -- 2132
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2132
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2145
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2146
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2147
		if normalizedPrompt == "" then -- 2147
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2149
		end -- 2149
		if normalizedPrompt == "" then -- 2149
			local ____Log_57 = Log -- 2156
			local ____temp_54 = #normalizedTitle -- 2156
			local ____temp_55 = #rawPrompt -- 2156
			local ____temp_56 = #toStr(request.expectedOutput) -- 2156
			local ____opt_52 = request.filesHint -- 2156
			____Log_57( -- 2156
				"Warn", -- 2156
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_54)) .. " raw_prompt_len=") .. tostring(____temp_55)) .. " expected_len=") .. tostring(____temp_56)) .. " files_hint_count=") .. tostring(____opt_52 and #____opt_52 or 0) -- 2156
			) -- 2156
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2156
		end -- 2156
		Log( -- 2159
			"Info", -- 2159
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2159
		) -- 2159
		local parentSessionId = request.parentSessionId -- 2160
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2160
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2162
			if not fallbackParent then -- 2162
				local createdMain = ____exports.createSession(request.projectRoot) -- 2164
				if createdMain.success then -- 2164
					fallbackParent = createdMain.session -- 2166
				end -- 2166
			end -- 2166
			if fallbackParent then -- 2166
				Log( -- 2170
					"Warn", -- 2170
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2170
				) -- 2170
				parentSessionId = fallbackParent.id -- 2171
			end -- 2171
		end -- 2171
		local parentSession = getSessionItem(parentSessionId) -- 2174
		if not parentSession then -- 2174
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2174
		end -- 2174
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2178
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2178
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2178
		end -- 2178
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2182
		if not created.success then -- 2182
			return ____awaiter_resolve(nil, created) -- 2182
		end -- 2182
		writeSpawnInfo( -- 2186
			created.session.projectRoot, -- 2186
			created.session.memoryScope, -- 2186
			{ -- 2186
				sessionId = created.session.id, -- 2187
				rootSessionId = created.session.rootSessionId, -- 2188
				parentSessionId = created.session.parentSessionId, -- 2189
				title = created.session.title, -- 2190
				prompt = normalizedPrompt, -- 2191
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2192
				expectedOutput = request.expectedOutput or "", -- 2193
				filesHint = request.filesHint or ({}), -- 2194
				status = "RUNNING", -- 2195
				success = false, -- 2196
				resultFilePath = "", -- 2197
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2198
				sourceTaskId = 0, -- 2199
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2200
				createdAtTs = created.session.createdAt, -- 2201
				finishedAt = "", -- 2202
				finishedAtTs = 0 -- 2203
			} -- 2203
		) -- 2203
		local sent = ____exports.sendPrompt( -- 2205
			created.session.id, -- 2205
			normalizedPrompt, -- 2205
			true, -- 2205
			request.disabledAgentTools, -- 2205
			nil, -- 2205
			nil, -- 2205
			request.llmConfig -- 2205
		) -- 2205
		if not sent.success then -- 2205
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2205
		end -- 2205
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2205
	end) -- 2205
end -- 2205
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2311
	local rootSession = getRootSessionItem(session.id) -- 2312
	if not rootSession then -- 2312
		return -- 2313
	end -- 2313
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2314
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2315
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2316
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2317
	local queueResult = writePendingHandoff( -- 2318
		rootSession.projectRoot, -- 2318
		rootSession.memoryScope, -- 2318
		{ -- 2318
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2319
			sourceSessionId = session.id, -- 2320
			sourceTitle = session.title, -- 2321
			sourceTaskId = taskId, -- 2322
			message = summary, -- 2323
			prompt = result.prompt, -- 2324
			goal = result.goal, -- 2325
			expectedOutput = result.expectedOutput or "", -- 2326
			filesHint = result.filesHint or ({}), -- 2327
			success = result.success, -- 2328
			resultFilePath = result.resultFilePath, -- 2329
			artifactDir = result.artifactDir, -- 2330
			finishedAt = result.finishedAt, -- 2331
			changeSet = changeSet, -- 2332
			handoffEvidence = result.handoffEvidence, -- 2333
			memoryEntry = result.memoryEntry, -- 2334
			completion = result.completion, -- 2335
			createdAt = createdAt -- 2336
		} -- 2336
	) -- 2336
	if not queueResult then -- 2336
		Log( -- 2339
			"Warn", -- 2339
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2339
		) -- 2339
		return -- 2340
	end -- 2340
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2340
		addTaskReference(rootSession.currentTaskId, taskId) -- 2343
	end -- 2343
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2343
		flushPendingSubAgentHandoffs(rootSession) -- 2346
	end -- 2346
end -- 2346
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2350
	if forceHandoff == nil then -- 2350
		forceHandoff = false -- 2356
	end -- 2356
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2356
		local rootSessionId = getSessionRootId(session) -- 2358
		local rootSession = getRootSessionItem(session.id) -- 2359
		if not rootSession then -- 2359
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2359
		end -- 2359
		local spawnInfo = getSessionSpawnInfo(session) -- 2363
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2364
		local finishedAtTs = now() -- 2365
		local resultText = sanitizeUTF8(message) -- 2366
		local changeSet = getTaskChangeSetSummary(taskId) -- 2367
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2368
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2369
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2373
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2373
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2375
		end -- 2375
		local completed = success and completionReport.outcome == "completed" -- 2383
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2384
		local record = { -- 2387
			sessionId = session.id, -- 2388
			rootSessionId = rootSessionId, -- 2389
			parentSessionId = session.parentSessionId, -- 2390
			title = session.title, -- 2391
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2392
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2393
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2394
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2395
			status = recordStatus, -- 2396
			success = completed, -- 2397
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2398
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2399
			sourceTaskId = taskId, -- 2400
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2401
			finishedAt = finishedAt, -- 2402
			createdAtTs = session.createdAt, -- 2403
			finishedAtTs = finishedAtTs, -- 2404
			changeSet = changeSet, -- 2405
			handoffEvidence = handoffEvidence, -- 2406
			completion = completionReport -- 2407
		} -- 2407
		local ____record_success_70 -- 2409
		if record.success then -- 2409
			____record_success_70 = buildStructuredSubAgentMemoryEntry(record) -- 2409
		else -- 2409
			____record_success_70 = nil -- 2409
		end -- 2409
		record.memoryEntry = ____record_success_70 -- 2409
		if not writeSubAgentResultFile(session, record, resultText) then -- 2409
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2409
		end -- 2409
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2409
			sessionId = record.sessionId, -- 2414
			rootSessionId = record.rootSessionId, -- 2415
			parentSessionId = record.parentSessionId, -- 2416
			title = record.title, -- 2417
			prompt = record.prompt, -- 2418
			goal = record.goal, -- 2419
			expectedOutput = record.expectedOutput or "", -- 2420
			filesHint = record.filesHint or ({}), -- 2421
			status = record.status, -- 2422
			success = record.success, -- 2423
			resultFilePath = record.resultFilePath, -- 2424
			artifactDir = record.artifactDir, -- 2425
			sourceTaskId = record.sourceTaskId, -- 2426
			createdAt = record.createdAt, -- 2427
			finishedAt = record.finishedAt, -- 2428
			createdAtTs = record.createdAtTs, -- 2429
			finishedAtTs = record.finishedAtTs, -- 2430
			changeSet = record.changeSet, -- 2431
			handoffEvidence = record.handoffEvidence, -- 2432
			memoryEntry = record.memoryEntry, -- 2433
			memoryEntryError = record.memoryEntryError, -- 2434
			completion = record.completion -- 2435
		}) then -- 2435
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2435
		end -- 2435
		if success or forceHandoff then -- 2435
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2440
			deleteSessionRecords(session.id, true) -- 2441
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2442
		end -- 2442
		return ____awaiter_resolve(nil, {success = true}) -- 2442
	end) -- 2442
end -- 2442
function stopClearedSubSession(session, taskId) -- 2447
	local spawnInfo = getSessionSpawnInfo(session) -- 2448
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2449
	local rootSessionId = getSessionRootId(session) -- 2450
	Tools.setTaskStatus(taskId, "STOPPED") -- 2451
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2452
	if not writeSpawnInfo( -- 2452
		session.projectRoot, -- 2453
		session.memoryScope, -- 2453
		{ -- 2453
			sessionId = session.id, -- 2454
			rootSessionId = rootSessionId, -- 2455
			parentSessionId = session.parentSessionId, -- 2456
			title = session.title, -- 2457
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2458
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2459
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2460
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2461
			status = "STOPPED", -- 2462
			success = false, -- 2463
			cleared = true, -- 2464
			resultFilePath = "", -- 2465
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2466
			sourceTaskId = taskId, -- 2467
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2468
			finishedAt = finishedAt, -- 2469
			createdAtTs = session.createdAt, -- 2470
			finishedAtTs = now() -- 2471
		} -- 2471
	) then -- 2471
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2473
	end -- 2473
	deleteSessionRecords(session.id, true) -- 2475
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2476
	return {success = true} -- 2477
end -- 2477
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2480
	if allowSubSessionStart == nil then -- 2480
		allowSubSessionStart = false -- 2480
	end -- 2480
	local session = getSessionItem(sessionId) -- 2481
	if not session then -- 2481
		return {success = false, message = "session not found"} -- 2483
	end -- 2483
	if getPendingQuestionnaire(sessionId) then -- 2483
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2485
	end -- 2485
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2485
		return {success = false, message = "session task is finalizing"} -- 2487
	end -- 2487
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2487
		return {success = false, message = "session task is still running"} -- 2490
	end -- 2490
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2492
	if normalizedPrompt == "" and session.kind == "sub" then -- 2492
		local spawnInfo = getSessionSpawnInfo(session) -- 2494
		if spawnInfo then -- 2494
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2496
			if normalizedPrompt == "" then -- 2496
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2498
			end -- 2498
		end -- 2498
	end -- 2498
	if normalizedPrompt == "" then -- 2498
		return {success = false, message = "prompt is empty"} -- 2507
	end -- 2507
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2509
	if session.workMode ~= nextWorkMode then -- 2509
		DB:exec( -- 2511
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2511
			{ -- 2511
				nextWorkMode, -- 2511
				now(), -- 2511
				session.id -- 2511
			} -- 2511
		) -- 2511
		session.workMode = nextWorkMode -- 2512
	end -- 2512
	return startPromptTask( -- 2514
		session, -- 2514
		normalizedPrompt, -- 2514
		nil, -- 2514
		normalizeDisabledAgentTools(disabledAgentTools), -- 2514
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2514
	) -- 2514
end -- 2480
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2567
	if disabledAgentTools == nil then -- 2567
		disabledAgentTools = {} -- 2571
	end -- 2571
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2574
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2575
	if not llmConfigRes.success then -- 2575
		return {success = false, message = llmConfigRes.message} -- 2579
	end -- 2579
	local llmConfig = llmConfigRes.config -- 2581
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2582
	if not taskRes.success then -- 2582
		return {success = false, message = taskRes.message} -- 2585
	end -- 2585
	if session.currentTaskStatus == "STOPPED" then -- 2585
		removeStoppedTaskSummary(session) -- 2587
	end -- 2587
	local taskId = taskRes.taskId -- 2589
	local ____temp_91 -- 2590
	if (options and options.existingTaskId) == nil then -- 2590
		____temp_91 = session.currentTaskId -- 2590
	else -- 2590
		____temp_91 = nil -- 2590
	end -- 2590
	local previousTaskId = ____temp_91 -- 2590
	local useChineseResponse = getDefaultUseChineseResponse() -- 2591
	if existingUserMessageId ~= nil then -- 2591
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2593
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2593
		insertMessage( -- 2595
			session.id, -- 2595
			"user", -- 2595
			normalizedPrompt, -- 2595
			taskId, -- 2595
			options and options.displayContent -- 2595
		) -- 2595
	end -- 2595
	local stopToken = {stopped = false} -- 2597
	activeStopTokens[taskId] = stopToken -- 2598
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2599
	if previousTaskId and previousTaskId ~= taskId then -- 2599
		cleanupTaskHeavyData(previousTaskId) -- 2601
	end -- 2601
	local ____runCodingAgent_120 = runCodingAgent -- 2603
	local ____normalizedPrompt_113 = normalizedPrompt -- 2604
	local ____temp_114 = options and options.resumeConversation -- 2605
	local ____temp_115 = (options and options.existingTaskId) ~= nil -- 2606
	local ____temp_116 = options and options.initialStep -- 2607
	local ____temp_117 = options and options.initialAgentStepCount -- 2608
	local ____temp_108 -- 2609
	if (options and options.existingTaskId) ~= nil then -- 2609
		____temp_108 = getInitialTokenUsage(session) -- 2609
	else -- 2609
		____temp_108 = nil -- 2609
	end -- 2609
	____runCodingAgent_120( -- 2603
		{ -- 2603
			prompt = ____normalizedPrompt_113, -- 2604
			resumeConversation = ____temp_114, -- 2605
			resumeTask = ____temp_115, -- 2606
			initialStep = ____temp_116, -- 2607
			initialAgentStepCount = ____temp_117, -- 2608
			initialTokenUsage = ____temp_108, -- 2609
			workDir = session.projectRoot, -- 2610
			useChineseResponse = useChineseResponse, -- 2611
			taskId = taskId, -- 2612
			sessionId = session.id, -- 2613
			memoryScope = session.memoryScope, -- 2614
			role = session.kind, -- 2615
			maxSteps = options and options.maxSteps, -- 2616
			disabledAgentTools = disabledAgentTools, -- 2617
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2618
			llmConfig = llmConfig, -- 2619
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2620
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2623
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2626
			stopToken = stopToken, -- 2627
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2628
		}, -- 2628
		function(result) -- 2629
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2629
				local nextSession = getSessionItem(session.id) -- 2630
				if nextSession and nextSession.kind == "sub" then -- 2630
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2630
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2633
						if not stopped.success then -- 2633
							Log( -- 2635
								"Warn", -- 2635
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2635
							) -- 2635
							emitAgentSessionPatch( -- 2636
								session.id, -- 2636
								{session = getSessionItem(session.id)} -- 2636
							) -- 2636
						end -- 2636
						__TS__Delete(activeStopTokens, taskId) -- 2640
						return ____awaiter_resolve(nil) -- 2640
					end -- 2640
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2643
					emitAgentSessionPatch( -- 2644
						session.id, -- 2644
						{session = getSessionItem(session.id)} -- 2644
					) -- 2644
					local finalized = __TS__Await(finalizeSubSession( -- 2647
						nextSession, -- 2648
						taskId, -- 2649
						result.success, -- 2650
						result.message, -- 2651
						result.completion, -- 2652
						(options and options.forceSubAgentHandoff) == true -- 2653
					)) -- 2653
					if not finalized.success then -- 2653
						Log( -- 2656
							"Warn", -- 2656
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2656
						) -- 2656
					end -- 2656
					local finalizedSession = getSessionItem(session.id) -- 2658
					if finalizedSession then -- 2658
						local stopped = stopToken.stopped == true -- 2660
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2661
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2664
						emitAgentSessionPatch( -- 2665
							session.id, -- 2665
							{session = getSessionItem(session.id)} -- 2665
						) -- 2665
					end -- 2665
					__TS__Delete(activeStopTokens, taskId) -- 2669
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2670
				end -- 2670
				local fallbackSession = getSessionItem(session.id) -- 2672
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2672
					applyEvent(session.id, { -- 2678
						type = "task_finished", -- 2679
						sessionId = session.id, -- 2680
						taskId = result.taskId, -- 2681
						success = false, -- 2682
						message = result.message, -- 2683
						steps = result.steps -- 2684
					}) -- 2684
				end -- 2684
			end) -- 2684
		end -- 2629
	) -- 2629
	return {success = true, sessionId = session.id, taskId = taskId} -- 2688
end -- 2688
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2840
	local lines = {} -- 2841
	do -- 2841
		local i = 0 -- 2842
		while i < #questionnaire.schema.questions do -- 2842
			local question = questionnaire.schema.questions[i + 1] -- 2843
			local answer = __TS__ArrayFind( -- 2844
				answers, -- 2844
				function(____, item) return item.questionId == question.id end -- 2844
			) -- 2844
			local answerText = "已跳过" -- 2845
			if answer and answer.status == "answered" then -- 2845
				local parts = {} -- 2847
				do -- 2847
					local j = 0 -- 2848
					while j < #(answer.selectedOptionIds or ({})) do -- 2848
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2849
						local option = __TS__ArrayFind( -- 2850
							question.options or ({}), -- 2850
							function(____, item) return item.id == optionId end -- 2850
						) -- 2850
						if option then -- 2850
							parts[#parts + 1] = option.label -- 2851
						end -- 2851
						j = j + 1 -- 2848
					end -- 2848
				end -- 2848
				if answer.otherText then -- 2848
					parts[#parts + 1] = answer.otherText -- 2853
				end -- 2853
				if answer.text then -- 2853
					parts[#parts + 1] = answer.text -- 2854
				end -- 2854
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2855
			end -- 2855
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2857
			i = i + 1 -- 2842
		end -- 2842
	end -- 2842
	return table.concat(lines, "\n\n") -- 2859
end -- 2859
function ____exports.listRunningSubAgents(request) -- 3098
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3098
		local session = getSessionItem(request.sessionId) -- 3106
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3106
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3108
		end -- 3108
		if not session then -- 3108
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3108
		end -- 3108
		local rootSession = getRootSessionItem(session.id) -- 3113
		if not rootSession then -- 3113
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3113
		end -- 3113
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3117
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3118
		local limit = math.max( -- 3119
			1, -- 3119
			math.floor(tonumber(request.limit) or 5) -- 3119
		) -- 3119
		local offset = math.max( -- 3120
			0, -- 3120
			math.floor(tonumber(request.offset) or 0) -- 3120
		) -- 3120
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3121
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3122
		local runningSessions = {} -- 3129
		do -- 3129
			local i = 0 -- 3130
			while i < #rows do -- 3130
				do -- 3130
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3131
					if current.currentTaskStatus ~= "RUNNING" then -- 3131
						goto __continue510 -- 3133
					end -- 3133
					local spawnInfo = getSessionSpawnInfo(current) -- 3135
					runningSessions[#runningSessions + 1] = { -- 3136
						sessionId = current.id, -- 3137
						title = current.title, -- 3138
						parentSessionId = current.parentSessionId, -- 3139
						rootSessionId = current.rootSessionId, -- 3140
						status = "RUNNING", -- 3141
						currentTaskId = current.currentTaskId, -- 3142
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3143
						goal = spawnInfo and spawnInfo.goal, -- 3144
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3145
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3146
						createdAt = current.createdAt, -- 3147
						updatedAt = current.updatedAt -- 3148
					} -- 3148
				end -- 3148
				::__continue510:: -- 3148
				i = i + 1 -- 3130
			end -- 3130
		end -- 3130
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3151
		local completedSessions = __TS__ArrayMap( -- 3152
			completedRecords, -- 3152
			function(____, record) return { -- 3152
				sessionId = record.sessionId, -- 3153
				title = record.title, -- 3154
				parentSessionId = record.parentSessionId, -- 3155
				rootSessionId = record.rootSessionId, -- 3156
				status = record.status, -- 3157
				goal = record.goal, -- 3158
				expectedOutput = record.expectedOutput, -- 3159
				filesHint = record.filesHint, -- 3160
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3161
				success = record.success, -- 3162
				cleared = record.cleared, -- 3163
				resultFilePath = record.resultFilePath, -- 3164
				artifactDir = record.artifactDir, -- 3165
				finishedAt = record.finishedAt, -- 3166
				createdAt = record.createdAtTs, -- 3167
				updatedAt = record.finishedAtTs -- 3168
			} end -- 3168
		) -- 3168
		local merged = {} -- 3170
		if status == "running" then -- 3170
			merged = runningSessions -- 3172
		elseif status == "done" then -- 3172
			merged = __TS__ArrayFilter( -- 3174
				completedSessions, -- 3174
				function(____, item) return item.status == "DONE" end -- 3174
			) -- 3174
		elseif status == "failed" then -- 3174
			merged = __TS__ArrayFilter( -- 3176
				completedSessions, -- 3176
				function(____, item) return item.status == "FAILED" end -- 3176
			) -- 3176
		elseif status == "stopped" then -- 3176
			merged = __TS__ArrayFilter( -- 3178
				completedSessions, -- 3178
				function(____, item) return item.status == "STOPPED" end -- 3178
			) -- 3178
		elseif status == "all" then -- 3178
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3180
		else -- 3180
			local runningKeys = {} -- 3182
			do -- 3182
				local i = 0 -- 3183
				while i < #runningSessions do -- 3183
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3184
					i = i + 1 -- 3183
				end -- 3183
			end -- 3183
			local latestCompletedByKey = {} -- 3186
			do -- 3186
				local i = 0 -- 3187
				while i < #completedSessions do -- 3187
					do -- 3187
						local item = completedSessions[i + 1] -- 3188
						local key = getSubAgentDisplayKey(item) -- 3189
						if runningKeys[key] then -- 3189
							goto __continue525 -- 3191
						end -- 3191
						local current = latestCompletedByKey[key] -- 3193
						if not current or item.updatedAt > current.updatedAt then -- 3193
							latestCompletedByKey[key] = item -- 3195
						end -- 3195
					end -- 3195
					::__continue525:: -- 3195
					i = i + 1 -- 3187
				end -- 3187
			end -- 3187
			local latestCompleted = {} -- 3198
			for ____, item in pairs(latestCompletedByKey) do -- 3199
				latestCompleted[#latestCompleted + 1] = item -- 3200
			end -- 3200
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3202
		end -- 3202
		if query ~= "" then -- 3202
			merged = __TS__ArrayFilter( -- 3205
				merged, -- 3205
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3205
			) -- 3205
		end -- 3205
		__TS__ArraySort( -- 3211
			merged, -- 3211
			function(____, a, b) -- 3211
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3211
					return -1 -- 3212
				end -- 3212
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3212
					return 1 -- 3213
				end -- 3213
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3213
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3215
				end -- 3215
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3217
			end -- 3211
		) -- 3211
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3219
		return ____awaiter_resolve(nil, { -- 3219
			success = true, -- 3221
			rootSessionId = rootSession.id, -- 3222
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3223
			status = status, -- 3224
			limit = limit, -- 3225
			offset = offset, -- 3226
			hasMore = offset + limit < #merged, -- 3227
			sessions = paged -- 3228
		}) -- 3228
	end) -- 3228
end -- 3098
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
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 971
	if projectRoot == oldRoot then -- 971
		return newRoot -- 973
	end -- 973
	for ____, separator in ipairs({"/", "\\"}) do -- 975
		local prefix = oldRoot .. separator -- 976
		if __TS__StringStartsWith(projectRoot, prefix) then -- 976
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 978
		end -- 978
	end -- 978
	return nil -- 981
end -- 971
local function clearSessionAfterMessage(sessionId, message) -- 1491
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1492
	local removedStepIds = {} -- 1500
	do -- 1500
		local i = 0 -- 1501
		while i < #removedStepRows do -- 1501
			local row = removedStepRows[i + 1] -- 1502
			if type(row[1]) == "number" then -- 1502
				removedStepIds[#removedStepIds + 1] = row[1] -- 1504
			end -- 1504
			i = i + 1 -- 1501
		end -- 1501
	end -- 1501
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1507
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1515
	return removedStepIds -- 1520
end -- 1491
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1523
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1524
	local persisted = storage:readSessionState() -- 1525
	local userIndex = -1 -- 1526
	do -- 1526
		local i = #persisted.messages - 1 -- 1527
		while i >= 0 do -- 1527
			if persisted.messages[i + 1].role == "user" then -- 1527
				userIndex = i -- 1529
				break -- 1530
			end -- 1530
			i = i - 1 -- 1527
		end -- 1527
	end -- 1527
	if userIndex < 0 then -- 1527
		return -- 1533
	end -- 1533
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1534
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1535
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1536
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1541
end -- 1523
local function listCurrentTaskCheckpoints(sessionId) -- 1553
	local session = getSessionItem(sessionId) -- 1554
	local taskId = session and session.currentTaskId -- 1555
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1556
end -- 1553
local function getAgentStepCount(sessionId, taskId) -- 1663
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1664
		sessionId, -- 1669
		taskId, -- 1670
		"compress_memory", -- 1671
		"merge_memory", -- 1672
		"sub_agent_handoff", -- 1673
		"questionnaire_answer", -- 1674
		"message" -- 1675
	}) -- 1675
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1678
end -- 1663
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1681
	if status == nil then -- 1681
		status = "DONE" -- 1689
	end -- 1689
	local step = getNextStepNumber(sessionId, taskId) -- 1691
	upsertStep( -- 1692
		sessionId, -- 1692
		taskId, -- 1692
		step, -- 1692
		tool, -- 1692
		{status = status, reason = reason, params = params, result = result} -- 1692
	) -- 1692
	return getStepItem(sessionId, taskId, step) -- 1698
end -- 1681
local function sanitizeStoredSteps(sessionId) -- 1765
	DB:exec( -- 1766
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1766
		{ -- 1784
			now(), -- 1784
			sessionId -- 1784
		} -- 1784
	) -- 1784
end -- 1765
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2217
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2217
		return {success = false, message = "invalid projectRoot"} -- 2219
	end -- 2219
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2221
	for ____, row in ipairs(rows) do -- 2222
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2223
		if sessionId > 0 then -- 2223
			deleteSessionRecords(sessionId) -- 2225
		end -- 2225
	end -- 2225
	return {success = true, deleted = #rows} -- 2228
end -- 2217
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2231
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2231
		return {success = false, message = "invalid projectRoot"} -- 2233
	end -- 2233
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2235
	local renamed = 0 -- 2236
	for ____, row in ipairs(rows) do -- 2237
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2238
		local projectRoot = toStr(row[2]) -- 2239
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2240
		if sessionId > 0 and nextProjectRoot then -- 2240
			DB:exec( -- 2242
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2242
				{ -- 2244
					nextProjectRoot, -- 2244
					Path:getFilename(nextProjectRoot), -- 2244
					now(), -- 2244
					sessionId -- 2244
				} -- 2244
			) -- 2244
			renamed = renamed + 1 -- 2246
		end -- 2246
	end -- 2246
	return {success = true, renamed = renamed} -- 2249
end -- 2231
function ____exports.getSession(sessionId) -- 2252
	local session = getSessionItem(sessionId) -- 2253
	if not session then -- 2253
		return {success = false, message = "session not found"} -- 2255
	end -- 2255
	local restored = restorePendingQuestionnaireState(session) -- 2257
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2258
	cleanupOrphanHeavyDataBatch() -- 2259
	local relatedSessions = listRelatedSessions(sessionId) -- 2260
	sanitizeStoredSteps(sessionId) -- 2261
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2262
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2269
	local ____relatedSessions_59 = relatedSessions -- 2280
	local ____temp_58 -- 2281
	if normalizedSession.kind == "sub" then -- 2281
		____temp_58 = getSessionSpawnInfo(normalizedSession) -- 2281
	else -- 2281
		____temp_58 = nil -- 2281
	end -- 2281
	return { -- 2277
		success = true, -- 2278
		session = normalizedSession, -- 2279
		relatedSessions = ____relatedSessions_59, -- 2280
		spawnInfo = ____temp_58, -- 2281
		messages = __TS__ArrayMap( -- 2282
			messages, -- 2282
			function(____, row) return rowToMessage(row) end -- 2282
		), -- 2282
		steps = __TS__ArrayMap( -- 2283
			steps, -- 2283
			function(____, row) return rowToStep(row) end -- 2283
		), -- 2283
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2284
		pendingQuestionnaire = restored.questionnaire, -- 2285
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2286
	} -- 2286
end -- 2252
function ____exports.setWorkMode(sessionId, workMode) -- 2291
	local session = getSessionItem(sessionId) -- 2292
	if not session then -- 2292
		return {success = false, message = "session not found"} -- 2293
	end -- 2293
	if session.kind ~= "main" then -- 2293
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2294
	end -- 2294
	if workMode ~= "code" and workMode ~= "plan" then -- 2294
		return {success = false, message = "invalid work mode"} -- 2295
	end -- 2295
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2296
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2296
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2298
	end -- 2298
	if getPendingQuestionnaire(sessionId) then -- 2298
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2301
	end -- 2301
	if normalizedSession.workMode ~= workMode then -- 2301
		DB:exec( -- 2304
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2304
			{ -- 2304
				workMode, -- 2304
				now(), -- 2304
				sessionId -- 2304
			} -- 2304
		) -- 2304
	end -- 2304
	local updated = getSessionItem(sessionId) -- 2306
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2307
	return { -- 2308
		success = true, -- 2308
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2308
	} -- 2308
end -- 2291
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2517
	local session = getSessionItem(sessionId) -- 2518
	if not session then -- 2518
		return {success = false, message = "session not found"} -- 2520
	end -- 2520
	if getPendingQuestionnaire(sessionId) then -- 2520
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2522
	end -- 2522
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2522
		return {success = false, message = "session task is finalizing"} -- 2524
	end -- 2524
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2524
		return {success = false, message = "session task is still stopping"} -- 2527
	end -- 2527
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2527
		return {success = false, message = "session task is not continuable"} -- 2530
	end -- 2530
	if session.currentTaskId == nil then -- 2530
		return {success = false, message = "session task not found"} -- 2533
	end -- 2533
	local taskId = session.currentTaskId -- 2535
	return startPromptTask( -- 2536
		session, -- 2537
		"", -- 2538
		nil, -- 2539
		normalizeDisabledAgentTools(disabledAgentTools), -- 2540
		{ -- 2541
			workMode = session.workMode, -- 2542
			persistUserMessage = false, -- 2543
			resumeConversation = true, -- 2544
			existingTaskId = taskId, -- 2545
			initialStep = math.max( -- 2546
				0, -- 2546
				getNextStepNumber(session.id, taskId) - 1 -- 2546
			), -- 2546
			initialAgentStepCount = 0, -- 2547
			llmConfigId = llmConfigId -- 2548
		} -- 2548
	) -- 2548
end -- 2517
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2691
	local session = getSessionItem(sessionId) -- 2692
	if not session then -- 2692
		return {success = false, message = "session not found"} -- 2694
	end -- 2694
	if session.kind ~= "sub" then -- 2694
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2697
	end -- 2697
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2697
		return {success = false, message = "session task is finalizing"} -- 2700
	end -- 2700
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2702
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2702
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2707
	end -- 2707
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2707
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2710
	end -- 2710
	local disabledAgentTools = __TS__ArrayFilter( -- 2712
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2712
		function(____, tool) return tool ~= "finish" end -- 2713
	) -- 2713
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2714
	return startPromptTask( -- 2717
		session, -- 2717
		prompt, -- 2717
		nil, -- 2717
		disabledAgentTools, -- 2717
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2717
	) -- 2717
end -- 2691
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2724
	local session = getSessionItem(sessionId) -- 2725
	if not session then -- 2725
		return {success = false, message = "session not found"} -- 2727
	end -- 2727
	if getPendingQuestionnaire(sessionId) then -- 2727
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2729
	end -- 2729
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2729
		return {success = false, message = "session task is finalizing"} -- 2731
	end -- 2731
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2731
		return {success = false, message = "session task is still running"} -- 2734
	end -- 2734
	local message = getMessageItem(messageId) -- 2736
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2736
		return {success = false, message = "message not found"} -- 2738
	end -- 2738
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2740
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2746
	if latestUserMessageId ~= messageId then -- 2746
		return {success = false, message = "only the latest user prompt can be edited"} -- 2748
	end -- 2748
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2750
	if normalizedPrompt == "" then -- 2750
		return {success = false, message = "prompt is empty"} -- 2752
	end -- 2752
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2754
	if session.workMode ~= nextWorkMode then -- 2754
		DB:exec( -- 2756
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2756
			{ -- 2756
				nextWorkMode, -- 2756
				now(), -- 2756
				session.id -- 2756
			} -- 2756
		) -- 2756
		session.workMode = nextWorkMode -- 2757
	end -- 2757
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2759
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2760
	local result = startPromptTask( -- 2761
		session, -- 2761
		normalizedPrompt, -- 2761
		messageId, -- 2761
		normalizeDisabledAgentTools(disabledAgentTools), -- 2761
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2761
	) -- 2761
	if result.success and #removedStepIds > 0 then -- 2761
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2763
	end -- 2763
	return result -- 2765
end -- 2724
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2770
	if status == "dismissed" then -- 2770
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2776
	end -- 2776
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2778
end -- 2770
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2781
	if status == "dismissed" then -- 2781
		return { -- 2787
			success = true, -- 2788
			status = "dismissed", -- 2789
			source = "user", -- 2790
			questionnaireId = questionnaire.id, -- 2791
			title = questionnaire.schema.title, -- 2792
			answers = {}, -- 2793
			responses = {}, -- 2794
			displayText = "用户关闭了调查问卷，未作答。", -- 2795
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2796
		} -- 2796
	end -- 2796
	local responses = {} -- 2799
	do -- 2799
		local i = 0 -- 2800
		while i < #questionnaire.schema.questions do -- 2800
			do -- 2800
				local question = questionnaire.schema.questions[i + 1] -- 2801
				local answer = __TS__ArrayFind( -- 2802
					answers, -- 2802
					function(____, item) return item.questionId == question.id end -- 2802
				) -- 2802
				if not answer or answer.status == "skipped" then -- 2802
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2804
					goto __continue437 -- 2809
				end -- 2809
				local selectedOptionLabels = {} -- 2811
				do -- 2811
					local j = 0 -- 2812
					while j < #(answer.selectedOptionIds or ({})) do -- 2812
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2813
						local option = __TS__ArrayFind( -- 2814
							question.options or ({}), -- 2814
							function(____, item) return item.id == optionId end -- 2814
						) -- 2814
						if option then -- 2814
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2815
						end -- 2815
						j = j + 1 -- 2812
					end -- 2812
				end -- 2812
				responses[#responses + 1] = { -- 2817
					questionId = question.id, -- 2818
					prompt = question.prompt, -- 2819
					status = "answered", -- 2820
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2821
					selectedOptionLabels = selectedOptionLabels, -- 2822
					otherText = answer.otherText, -- 2823
					text = answer.text -- 2824
				} -- 2824
			end -- 2824
			::__continue437:: -- 2824
			i = i + 1 -- 2800
		end -- 2800
	end -- 2800
	return { -- 2827
		success = true, -- 2828
		status = "answered", -- 2829
		source = "user", -- 2830
		questionnaireId = questionnaire.id, -- 2831
		title = questionnaire.schema.title, -- 2832
		answers = answers, -- 2833
		responses = responses, -- 2834
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2835
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2836
	} -- 2836
end -- 2781
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2862
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2868
	local persisted = storage:readSessionState() -- 2869
	local messages = __TS__ArraySlice(persisted.messages) -- 2870
	local toolResultIndex = -1 -- 2871
	local existingResult -- 2872
	do -- 2872
		local i = #messages - 1 -- 2873
		while i >= 0 do -- 2873
			do -- 2873
				local message = messages[i + 1] -- 2874
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2874
					goto __continue457 -- 2875
				end -- 2875
				local decoded = safeJsonDecode(message.content) -- 2876
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2876
					goto __continue457 -- 2877
				end -- 2877
				local row = decoded -- 2878
				if row.questionnaireId ~= questionnaire.id then -- 2878
					goto __continue457 -- 2879
				end -- 2879
				toolResultIndex = i -- 2880
				existingResult = row -- 2881
				break -- 2882
			end -- 2882
			::__continue457:: -- 2882
			i = i - 1 -- 2873
		end -- 2873
	end -- 2873
	if toolResultIndex < 0 then -- 2873
		return {success = false, message = "matching ask_user tool result not found"} -- 2885
	end -- 2885
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2887
	local guidance = {} -- 2888
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2888
		guidance[#guidance + 1] = existingResult.guidance -- 2890
	end -- 2890
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2890
		guidance[#guidance + 1] = result.guidance -- 2893
	end -- 2893
	result.guidance = table.concat(guidance, "\n") -- 2895
	messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2896
		{}, -- 2896
		messages[toolResultIndex + 1], -- 2897
		{content = encodeJson(result)} -- 2896
	) -- 2896
	local pairStartIndex = toolResultIndex -- 2901
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2902
	if toolCallId and toolCallId ~= "" then -- 2902
		do -- 2902
			local i = toolResultIndex - 1 -- 2904
			while i >= 0 do -- 2904
				do -- 2904
					local message = messages[i + 1] -- 2905
					if message.role ~= "assistant" or not message.tool_calls then -- 2905
						goto __continue466 -- 2906
					end -- 2906
					if __TS__ArraySome( -- 2906
						message.tool_calls, -- 2907
						function(____, call) return call.id == toolCallId end -- 2907
					) then -- 2907
						pairStartIndex = i -- 2908
						break -- 2909
					end -- 2909
				end -- 2909
				::__continue466:: -- 2909
				i = i - 1 -- 2904
			end -- 2904
		end -- 2904
	end -- 2904
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2913
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2916
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2920
	upsertStep( -- 2922
		session.id, -- 2922
		questionnaire.taskId, -- 2922
		questionnaire.step, -- 2922
		"ask_user", -- 2922
		{status = "DONE", result = result} -- 2922
	) -- 2922
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 2926
	upsertStep( -- 2927
		session.id, -- 2927
		questionnaire.taskId, -- 2927
		answerStep, -- 2927
		"questionnaire_answer", -- 2927
		{status = "DONE", result = result} -- 2927
	) -- 2927
	return {success = true, answerStep = answerStep, result = result} -- 2931
end -- 2862
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 2934
	local session = getSessionItem(sessionId) -- 2935
	if not session then -- 2935
		return {success = false, message = "session not found"} -- 2936
	end -- 2936
	if session.kind ~= "main" then -- 2936
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2937
	end -- 2937
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2938
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2938
		return {success = false, message = "pending questionnaire not found or already handled"} -- 2940
	end -- 2940
	local llmConfigRes = getLLMConfig(llmConfigId) -- 2942
	if not llmConfigRes.success then -- 2942
		return {success = false, message = llmConfigRes.message} -- 2943
	end -- 2943
	if not removePendingQuestionnaire(session) then -- 2943
		return {success = false, message = "failed to consume questionnaire file"} -- 2944
	end -- 2944
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 2945
	if not replaced.success then -- 2945
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 2947
		return replaced -- 2948
	end -- 2948
	local t = now() -- 2950
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 2951
	session.workMode = "plan" -- 2952
	local result = startPromptTask( -- 2953
		session, -- 2953
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 2953
		nil, -- 2953
		{}, -- 2953
		{ -- 2953
			workMode = "plan", -- 2954
			persistUserMessage = false, -- 2955
			resumeConversation = true, -- 2956
			existingTaskId = questionnaire.taskId, -- 2957
			initialStep = replaced.answerStep, -- 2958
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 2959
			llmConfig = llmConfigRes.config -- 2960
		} -- 2960
	) -- 2960
	if not result.success then -- 2960
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 2963
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 2964
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 2965
		emitAgentSessionPatch( -- 2966
			session.id, -- 2966
			{ -- 2966
				session = getSessionItem(session.id), -- 2967
				pendingQuestionnaire = questionnaire -- 2968
			} -- 2968
		) -- 2968
		return result -- 2970
	end -- 2970
	emitAgentSessionPatch( -- 2972
		sessionId, -- 2972
		{ -- 2972
			session = getSessionItem(sessionId), -- 2973
			pendingQuestionnaire = false -- 2974
		} -- 2974
	) -- 2974
	return result -- 2976
end -- 2934
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 2979
	local session = getSessionItem(sessionId) -- 2980
	if not session then -- 2980
		return {success = false, message = "session not found"} -- 2981
	end -- 2981
	if session.kind ~= "main" then -- 2981
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2982
	end -- 2982
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2983
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2983
		return {success = false, message = "pending questionnaire not found"} -- 2984
	end -- 2984
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 2985
	if not validated.success then -- 2985
		return validated -- 2986
	end -- 2986
	local llmConfigRes = getLLMConfig(llmConfigId) -- 2987
	if not llmConfigRes.success then -- 2987
		return {success = false, message = llmConfigRes.message} -- 2988
	end -- 2988
	local t = now() -- 2989
	if not removePendingQuestionnaire(session) then -- 2989
		return {success = false, message = "failed to consume questionnaire file"} -- 2990
	end -- 2990
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 2991
	if not replaced.success then -- 2991
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 2993
		return replaced -- 2994
	end -- 2994
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 2996
	session.workMode = "plan" -- 2997
	local result = startPromptTask( -- 2998
		session, -- 2998
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 2998
		nil, -- 2998
		{}, -- 2998
		{ -- 2998
			workMode = "plan", -- 2999
			persistUserMessage = false, -- 3000
			resumeConversation = true, -- 3001
			existingTaskId = questionnaire.taskId, -- 3002
			initialStep = replaced.answerStep, -- 3003
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3004
			llmConfig = llmConfigRes.config -- 3005
		} -- 3005
	) -- 3005
	if not result.success then -- 3005
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3008
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3009
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3010
		emitAgentSessionPatch( -- 3011
			session.id, -- 3011
			{ -- 3011
				session = getSessionItem(session.id), -- 3012
				pendingQuestionnaire = questionnaire -- 3013
			} -- 3013
		) -- 3013
		return result -- 3015
	end -- 3015
	emitAgentSessionPatch( -- 3017
		sessionId, -- 3017
		{ -- 3017
			session = getSessionItem(sessionId), -- 3018
			pendingQuestionnaire = false -- 3019
		} -- 3019
	) -- 3019
	return result -- 3021
end -- 2979
function ____exports.stopSessionTask(sessionId) -- 3024
	local session = getSessionItem(sessionId) -- 3025
	if not session or session.currentTaskId == nil then -- 3025
		return {success = false, message = "session task not found"} -- 3027
	end -- 3027
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3027
		return {success = false, message = "session task is finalizing"} -- 3030
	end -- 3030
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3032
	local stopToken = activeStopTokens[session.currentTaskId] -- 3033
	if not stopToken then -- 3033
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3033
			return {success = true, recovered = true} -- 3036
		end -- 3036
		return {success = false, message = "task is not running"} -- 3038
	end -- 3038
	if stopToken.stopped then -- 3038
		return {success = true, stopping = true} -- 3041
	end -- 3041
	stopToken.stopped = true -- 3043
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3044
	return {success = true, stopping = true} -- 3048
end -- 3024
function ____exports.getCurrentTaskId(sessionId) -- 3051
	local ____opt_123 = getSessionItem(sessionId) -- 3051
	return ____opt_123 and ____opt_123.currentTaskId -- 3052
end -- 3051
function ____exports.validateTaskAccess(sessionId, taskId) -- 3055
	local session = getSessionItem(sessionId) -- 3056
	if not session then -- 3056
		return {success = false, message = "session not found"} -- 3057
	end -- 3057
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3057
		getSessionOperableTaskIds(sessionId), -- 3058
		taskId -- 3058
	) < 0 then -- 3058
		return {success = false, message = "task is not operable for this session"} -- 3059
	end -- 3059
	return {success = true, session = session} -- 3061
end -- 3055
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3064
	if checkpointId <= 0 then -- 3064
		return {success = false, message = "invalid checkpointId"} -- 3066
	end -- 3066
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3068
	if not checkpoint then -- 3068
		return {success = false, message = "checkpoint not found"} -- 3070
	end -- 3070
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3072
	if not taskAccess.success then -- 3072
		return taskAccess -- 3073
	end -- 3073
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3074
end -- 3064
function ____exports.listRunningSessions() -- 3077
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3078
	local sessions = {} -- 3085
	do -- 3085
		local i = 0 -- 3086
		while i < #rows do -- 3086
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3087
			if session.currentTaskStatus == "RUNNING" then -- 3087
				sessions[#sessions + 1] = session -- 3089
			end -- 3089
			i = i + 1 -- 3086
		end -- 3086
	end -- 3086
	return {success = true, sessions = sessions} -- 3092
end -- 3077
return ____exports -- 3077