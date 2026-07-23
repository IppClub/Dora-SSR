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
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeStoppedTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Path = ____Dora.Path -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____CodingAgent = require("Agent.CodingAgent") -- 3
local runCodingAgent = ____CodingAgent.runCodingAgent -- 3
local truncateAgentUserPrompt = ____CodingAgent.truncateAgentUserPrompt -- 3
local AgentToolRegistry = require("Agent.AgentToolRegistry") -- 5
local AgentRuntimePolicy = require("Agent.AgentRuntimePolicy") -- 6
local Tools = require("Agent.Tools") -- 7
local ____Memory = require("Agent.Memory") -- 8
local DualLayerStorage = ____Memory.DualLayerStorage -- 8
local ____Utils = require("Agent.Utils") -- 9
local Log = ____Utils.Log -- 9
local getLLMConfig = ____Utils.getLLMConfig -- 9
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 9
local safeJsonDecode = ____Utils.safeJsonDecode -- 9
local safeJsonEncode = ____Utils.safeJsonEncode -- 9
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 9
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 13
local validateQuestionnaireAnswers = ____AgentQuestionnaire.validateQuestionnaireAnswers -- 13
function getDefaultUseChineseResponse() -- 321
	local zh = string.match(App.locale, "^zh") -- 322
	return zh ~= nil -- 323
end -- 323
function toStr(v) -- 326
	if v == false or v == nil then -- 326
		return "" -- 327
	end -- 327
	return tostring(v) -- 328
end -- 328
function encodeJson(value) -- 331
	local text = safeJsonEncode(value) -- 332
	return text or "" -- 333
end -- 333
function decodeJsonObject(text) -- 336
	if not text or text == "" then -- 336
		return nil -- 337
	end -- 337
	local value = safeJsonDecode(text) -- 338
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 338
		return value -- 340
	end -- 340
	return nil -- 342
end -- 342
function decodeJsonFiles(text) -- 345
	if not text or text == "" then -- 345
		return nil -- 346
	end -- 346
	local value = safeJsonDecode(text) -- 347
	if not value or not __TS__ArrayIsArray(value) then -- 347
		return nil -- 348
	end -- 348
	local files = {} -- 349
	do -- 349
		local i = 0 -- 350
		while i < #value do -- 350
			do -- 350
				local item = value[i + 1] -- 351
				if type(item) ~= "table" then -- 351
					goto __continue14 -- 352
				end -- 352
				files[#files + 1] = { -- 353
					path = sanitizeUTF8(toStr(item.path)), -- 354
					op = sanitizeUTF8(toStr(item.op)) -- 355
				} -- 355
			end -- 355
			::__continue14:: -- 355
			i = i + 1 -- 350
		end -- 350
	end -- 350
	return files -- 358
end -- 358
function decodeChangeSetSummary(value) -- 361
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 361
		return nil -- 362
	end -- 362
	local row = value -- 363
	if row.success ~= true then -- 363
		return nil -- 364
	end -- 364
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 365
	if taskId <= 0 then -- 365
		return nil -- 366
	end -- 366
	local files = {} -- 367
	if __TS__ArrayIsArray(row.files) then -- 367
		do -- 367
			local i = 0 -- 369
			while i < #row.files do -- 369
				do -- 369
					local file = row.files[i + 1] -- 370
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 370
						goto __continue22 -- 371
					end -- 371
					local fileRow = file -- 372
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 373
					if path == "" then -- 373
						goto __continue22 -- 374
					end -- 374
					local checkpointIds = {} -- 375
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 375
						do -- 375
							local j = 0 -- 377
							while j < #fileRow.checkpointIds do -- 377
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 378
								if checkpointId > 0 then -- 378
									checkpointIds[#checkpointIds + 1] = checkpointId -- 379
								end -- 379
								j = j + 1 -- 377
							end -- 377
						end -- 377
					end -- 377
					local op = toStr(fileRow.op) -- 382
					files[#files + 1] = { -- 383
						path = path, -- 384
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 385
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 386
						checkpointIds = checkpointIds -- 387
					} -- 387
				end -- 387
				::__continue22:: -- 387
				i = i + 1 -- 369
			end -- 369
		end -- 369
	end -- 369
	return { -- 391
		success = true, -- 392
		taskId = taskId, -- 393
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 394
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 395
		files = files, -- 396
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 397
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 398
	} -- 398
end -- 398
function decodeHandoffEvidence(value) -- 402
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 402
		return nil -- 403
	end -- 403
	local row = value -- 404
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 405
		__TS__ArrayFilter( -- 406
			row.modifiedFiles, -- 406
			function(____, item) return type(item) == "string" end -- 406
		), -- 406
		function(____, item) return sanitizeUTF8(item) end -- 406
	) or ({}) -- 406
	local lastBuild = nil -- 408
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 408
		local build = row.lastBuild -- 410
		lastBuild = { -- 411
			result = build.result == "passed" and "passed" or "failed", -- 412
			path = sanitizeUTF8(toStr(build.path)), -- 413
			evidence = takeUtf8Head( -- 414
				sanitizeUTF8(toStr(build.evidence)), -- 414
				600 -- 414
			) -- 414
		} -- 414
	end -- 414
	local commands = {} -- 417
	if __TS__ArrayIsArray(row.commands) then -- 417
		do -- 417
			local i = 0 -- 419
			while i < #row.commands and #commands < 8 do -- 419
				do -- 419
					local raw = row.commands[i + 1] -- 420
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 420
						goto __continue36 -- 421
					end -- 421
					local item = raw -- 422
					commands[#commands + 1] = { -- 423
						mode = sanitizeUTF8(toStr(item.mode)), -- 424
						command = takeUtf8Head( -- 425
							sanitizeUTF8(toStr(item.command)), -- 425
							600 -- 425
						), -- 425
						result = item.result == "passed" and "passed" or "failed", -- 426
						evidence = takeUtf8Head( -- 427
							sanitizeUTF8(toStr(item.evidence)), -- 427
							600 -- 427
						) -- 427
					} -- 427
				end -- 427
				::__continue36:: -- 427
				i = i + 1 -- 419
			end -- 419
		end -- 419
	end -- 419
	local authoritativeSources = {} -- 431
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 431
		do -- 431
			local i = 0 -- 433
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 433
				do -- 433
					local raw = row.authoritativeSources[i + 1] -- 434
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 434
						goto __continue40 -- 435
					end -- 435
					local item = raw -- 436
					authoritativeSources[#authoritativeSources + 1] = { -- 437
						tool = "search_dora_api", -- 438
						query = takeUtf8Head( -- 439
							sanitizeUTF8(toStr(item.query)), -- 439
							300 -- 439
						), -- 439
						source = sanitizeUTF8(toStr(item.source)), -- 440
						result = item.result == "passed" and "passed" or "failed" -- 441
					} -- 441
				end -- 441
				::__continue40:: -- 441
				i = i + 1 -- 433
			end -- 433
		end -- 433
	end -- 433
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 445
end -- 445
function takeUtf8Head(text, maxChars) -- 448
	if maxChars <= 0 or text == "" then -- 448
		return "" -- 449
	end -- 449
	local nextPos = utf8.offset(text, maxChars + 1) -- 450
	if nextPos == nil then -- 450
		return text -- 451
	end -- 451
	return string.sub(text, 1, nextPos - 1) -- 452
end -- 452
function normalizeMemoryEntryEvidence(value) -- 455
	local evidence = {} -- 456
	if not __TS__ArrayIsArray(value) then -- 456
		return evidence -- 457
	end -- 457
	do -- 457
		local i = 0 -- 458
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 458
			do -- 458
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 459
				if item == "" then -- 459
					goto __continue48 -- 460
				end -- 460
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 460
					evidence[#evidence + 1] = item -- 462
				end -- 462
			end -- 462
			::__continue48:: -- 462
			i = i + 1 -- 458
		end -- 458
	end -- 458
	return evidence -- 465
end -- 465
function decodeSubAgentMemoryEntry(value) -- 468
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 468
		return nil -- 469
	end -- 469
	local row = value -- 470
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 471
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 472
	local content = takeUtf8Head( -- 473
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 473
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 473
	) -- 473
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 473
		return nil -- 474
	end -- 474
	return { -- 475
		sourceSessionId = sourceSessionId, -- 476
		sourceTaskId = sourceTaskId, -- 477
		content = content, -- 478
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 479
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 480
	} -- 480
end -- 480
function getTaskChangeSetSummary(taskId) -- 484
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 485
	return summary.success and summary or nil -- 486
end -- 486
function queryRows(sql, args) -- 489
	local ____args_0 -- 490
	if args then -- 490
		____args_0 = DB:query(sql, args) -- 490
	else -- 490
		____args_0 = DB:query(sql) -- 490
	end -- 490
	return ____args_0 -- 490
end -- 490
function queryOne(sql, args) -- 493
	local rows = queryRows(sql, args) -- 494
	if not rows or #rows == 0 then -- 494
		return nil -- 495
	end -- 495
	return rows[1] -- 496
end -- 496
function summarizeHandoffResult(result) -- 499
	local candidates = {result.output, result.message, result.state, result.phase} -- 500
	do -- 500
		local i = 0 -- 501
		while i < #candidates do -- 501
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 502
			if text ~= "" then -- 502
				return takeUtf8Head(text, 600) -- 503
			end -- 503
			i = i + 1 -- 501
		end -- 501
	end -- 501
	local messages = result.messages -- 505
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 505
		local parts = {} -- 507
		do -- 507
			local i = 0 -- 508
			while i < #messages and #parts < 4 do -- 508
				do -- 508
					local row = messages[i + 1] -- 509
					if not row or type(row) ~= "table" then -- 509
						goto __continue64 -- 510
					end -- 510
					local item = row -- 511
					local ____sanitizeUTF8_4 = sanitizeUTF8 -- 512
					local ____toStr_3 = toStr -- 512
					local ____item_message_1 = item.message -- 512
					if ____item_message_1 == nil then -- 512
						____item_message_1 = item.error -- 512
					end -- 512
					local ____item_message_1_2 = ____item_message_1 -- 512
					if ____item_message_1_2 == nil then -- 512
						____item_message_1_2 = item.file -- 512
					end -- 512
					local text = __TS__StringTrim(____sanitizeUTF8_4(____toStr_3(____item_message_1_2))) -- 512
					if text ~= "" then -- 512
						parts[#parts + 1] = text -- 513
					end -- 513
				end -- 513
				::__continue64:: -- 513
				i = i + 1 -- 508
			end -- 508
		end -- 508
		if #parts > 0 then -- 508
			return takeUtf8Head( -- 515
				table.concat(parts, "; "), -- 515
				600 -- 515
			) -- 515
		end -- 515
	end -- 515
	return result.success == true and "tool result success=true" or "tool result success=false" -- 517
end -- 517
function getTaskHandoffEvidence(taskId, changeSet) -- 520
	local ____opt_5 = changeSet -- 520
	local evidence = { -- 521
		modifiedFiles = ____opt_5 and __TS__ArrayMap( -- 522
			changeSet and changeSet.files, -- 522
			function(____, item) return item.path end -- 522
		) or ({}), -- 522
		commands = {}, -- 523
		authoritativeSources = {} -- 524
	} -- 524
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_api"}) or ({}) -- 526
	do -- 526
		local i = 0 -- 531
		while i < #rows do -- 531
			local tool = toStr(rows[i + 1][1]) -- 532
			local status = toStr(rows[i + 1][2]) -- 533
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 534
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 535
			local passed = status == "DONE" and result.success == true -- 536
			if tool == "build" then -- 536
				evidence.lastBuild = { -- 538
					result = passed and "passed" or "failed", -- 539
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 540
					evidence = summarizeHandoffResult(result) -- 541
				} -- 541
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 541
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 544
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 545
				local ____evidence_commands_9 = evidence.commands -- 545
				____evidence_commands_9[#____evidence_commands_9 + 1] = { -- 546
					mode = mode, -- 547
					command = takeUtf8Head( -- 548
						__TS__StringTrim(sanitizeUTF8(command)), -- 548
						600 -- 548
					), -- 548
					result = passed and "passed" or "failed", -- 549
					evidence = summarizeHandoffResult(result) -- 550
				} -- 550
			elseif tool == "search_dora_api" and #evidence.authoritativeSources < 8 then -- 550
				local ____evidence_authoritativeSources_10 = evidence.authoritativeSources -- 550
				____evidence_authoritativeSources_10[#____evidence_authoritativeSources_10 + 1] = { -- 553
					tool = "search_dora_api", -- 554
					query = takeUtf8Head( -- 555
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 555
						300 -- 555
					), -- 555
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docSource or "api"))), -- 556
					result = passed and "passed" or "failed" -- 557
				} -- 557
			end -- 557
			i = i + 1 -- 531
		end -- 531
	end -- 531
	return evidence -- 561
end -- 561
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 564
	local lastBuild = evidence.lastBuild -- 568
	if not lastBuild or lastBuild.result ~= "failed" then -- 568
		return completion -- 569
	end -- 569
	local validation = __TS__ArraySlice(completion.validation) -- 570
	local foundBuild = false -- 571
	do -- 571
		local i = 0 -- 572
		while i < #validation do -- 572
			do -- 572
				if validation[i + 1].kind ~= "build" then -- 572
					goto __continue78 -- 573
				end -- 573
				foundBuild = true -- 574
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 575
			end -- 575
			::__continue78:: -- 575
			i = i + 1 -- 572
		end -- 572
	end -- 572
	if not foundBuild then -- 572
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 582
	end -- 582
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 584
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 585
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 585
		knownIssues[#knownIssues + 1] = issue -- 586
	end -- 586
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 587
end -- 587
function getLastInsertRowId() -- 595
	local row = queryOne("SELECT last_insert_rowid()") -- 596
	return row and (row[1] or 0) or 0 -- 597
end -- 597
function isValidProjectRoot(path) -- 600
	return not not path and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 601
end -- 601
function rowToSession(row) -- 604
	return { -- 605
		id = row[1], -- 606
		projectRoot = toStr(row[2]), -- 607
		title = toStr(row[3]), -- 608
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 609
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 610
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 611
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 612
		status = toStr(row[8]), -- 613
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 614
		currentTaskStatus = toStr(row[10]), -- 615
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 616
		createdAt = row[11], -- 617
		updatedAt = row[12], -- 618
		metrics = decodeJsonObject(toStr(row[13])), -- 619
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 620
	} -- 620
end -- 620
function rowToMessage(row) -- 624
	local message = { -- 625
		id = row[1], -- 626
		sessionId = row[2], -- 627
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 628
		role = toStr(row[4]), -- 629
		content = toStr(row[5]), -- 630
		createdAt = row[7], -- 631
		updatedAt = row[8] -- 632
	} -- 632
	local displayContent = toStr(row[6]) -- 634
	if displayContent ~= "" then -- 634
		message.displayContent = displayContent -- 635
	end -- 635
	return message -- 636
end -- 636
function rowToStep(row) -- 639
	return { -- 640
		id = row[1], -- 641
		sessionId = row[2], -- 642
		taskId = row[3], -- 643
		step = row[4], -- 644
		tool = toStr(row[5]), -- 645
		status = toStr(row[6]), -- 646
		reason = toStr(row[7]), -- 647
		reasoningContent = toStr(row[8]), -- 648
		params = decodeJsonObject(toStr(row[9])), -- 649
		result = decodeJsonObject(toStr(row[10])), -- 650
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 651
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 652
		files = decodeJsonFiles(toStr(row[13])), -- 653
		createdAt = row[14], -- 654
		updatedAt = row[15] -- 655
	} -- 655
end -- 655
function getQuestionnairePath(projectRoot) -- 659
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 660
end -- 660
function decodeQuestionnaireFile(text) -- 663
	local value = decodeJsonObject(text) -- 664
	if not value then -- 664
		return nil -- 665
	end -- 665
	local schema = value.schema -- 666
	local id = type(value.id) == "number" and value.id or 0 -- 667
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 668
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 669
	local step = type(value.step) == "number" and value.step or 0 -- 670
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 671
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 671
		return nil -- 673
	end -- 673
	return { -- 675
		id = id, -- 675
		sessionId = sessionId, -- 675
		taskId = taskId, -- 675
		step = step, -- 675
		status = "PENDING", -- 675
		schema = schema, -- 675
		createdAt = createdAt -- 675
	} -- 675
end -- 675
function getPendingQuestionnaire(sessionId) -- 678
	local session = getSessionItem(sessionId) -- 679
	if not session or session.kind ~= "main" then -- 679
		return nil -- 680
	end -- 680
	local path = getQuestionnairePath(session.projectRoot) -- 681
	if not Content:exist(path) then -- 681
		return nil -- 682
	end -- 682
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 683
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 684
end -- 684
function restorePendingQuestionnaireState(session) -- 687
	local questionnaire = getPendingQuestionnaire(session.id) -- 688
	if not questionnaire then -- 688
		return {session = session} -- 689
	end -- 689
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 689
		local t = now() -- 696
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 697
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 703
		local restored = getSessionItem(session.id) -- 704
		if restored then -- 704
			session = restored -- 705
		end -- 705
	end -- 705
	return {session = session, questionnaire = questionnaire} -- 707
end -- 707
function savePendingQuestionnaire(projectRoot, questionnaire) -- 710
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 711
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 711
		return false -- 712
	end -- 712
	local path = getQuestionnairePath(projectRoot) -- 713
	local tempPath = path .. ".tmp" -- 714
	Content:remove(tempPath) -- 715
	if not Content:save( -- 715
		tempPath, -- 716
		encodeJson(questionnaire) -- 716
	) then -- 716
		return false -- 716
	end -- 716
	if Content:exist(path) then -- 716
		Content:remove(path) -- 717
	end -- 717
	if Content:move(tempPath, path) then -- 717
		return true -- 718
	end -- 718
	Content:remove(tempPath) -- 719
	return false -- 720
end -- 720
function removePendingQuestionnaire(session) -- 723
	local path = getQuestionnairePath(session.projectRoot) -- 724
	if not Content:exist(path) then -- 724
		return true -- 725
	end -- 725
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 726
	if questionnaire and questionnaire.sessionId ~= session.id then -- 726
		return false -- 727
	end -- 727
	return Content:remove(path) -- 728
end -- 728
function publishQuestionnaire(request) -- 731
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 731
		local session = getSessionItem(request.sessionId) -- 737
		if not session or session.kind ~= "main" then -- 737
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 737
		end -- 737
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 739
		if Content:exist(pendingPath) then -- 739
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 739
		end -- 739
		local questionnaire = { -- 741
			id = request.taskId, -- 742
			sessionId = request.sessionId, -- 743
			taskId = request.taskId, -- 744
			step = request.step, -- 745
			status = "PENDING", -- 746
			schema = request.schema, -- 747
			createdAt = now() -- 748
		} -- 748
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 748
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 748
		end -- 748
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 748
	end) -- 748
end -- 748
function getMessageItem(messageId) -- 756
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 757
	return row and rowToMessage(row) or nil -- 763
end -- 763
function getStepItem(sessionId, taskId, step) -- 766
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 767
	return row and rowToStep(row) or nil -- 773
end -- 773
function deleteMessageSteps(sessionId, taskId) -- 776
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 777
	local ids = {} -- 782
	do -- 782
		local i = 0 -- 783
		while i < #rows do -- 783
			local row = rows[i + 1] -- 784
			if type(row[1]) == "number" then -- 784
				ids[#ids + 1] = row[1] -- 786
			end -- 786
			i = i + 1 -- 783
		end -- 783
	end -- 783
	if #ids > 0 then -- 783
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 790
	end -- 790
	return ids -- 796
end -- 796
function normalizeDisabledAgentTools(value) -- 799
	if not __TS__ArrayIsArray(value) then -- 799
		return {} -- 800
	end -- 800
	local tools = {} -- 801
	do -- 801
		local i = 0 -- 802
		while i < #value do -- 802
			do -- 802
				local name = value[i + 1] -- 803
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 803
					goto __continue121 -- 804
				end -- 804
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 804
					tools[#tools + 1] = name -- 805
				end -- 805
			end -- 805
			::__continue121:: -- 805
			i = i + 1 -- 802
		end -- 802
	end -- 802
	return tools -- 807
end -- 807
function normalizeWorkMode(value, fallback) -- 810
	if fallback == nil then -- 810
		fallback = "code" -- 810
	end -- 810
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 811
end -- 811
function getSessionRow(sessionId) -- 814
	return queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 815
end -- 815
function getSessionItem(sessionId) -- 823
	local row = getSessionRow(sessionId) -- 824
	return row and rowToSession(row) or nil -- 825
end -- 825
function getTaskPrompt(taskId) -- 828
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 829
	if not row or type(row[1]) ~= "string" then -- 829
		return nil -- 830
	end -- 830
	return toStr(row[1]) -- 831
end -- 831
function getLatestMainSessionByProjectRoot(projectRoot) -- 834
	if not isValidProjectRoot(projectRoot) then -- 834
		return nil -- 835
	end -- 835
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 836
	return row and rowToSession(row) or nil -- 844
end -- 844
function countRunningSubSessions(rootSessionId) -- 847
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 848
	local count = 0 -- 855
	do -- 855
		local i = 0 -- 856
		while i < #rows do -- 856
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 857
			if session.currentTaskStatus == "RUNNING" then -- 857
				count = count + 1 -- 859
			end -- 859
			i = i + 1 -- 856
		end -- 856
	end -- 856
	return count -- 862
end -- 862
function deleteSessionRecords(sessionId, preserveArtifacts) -- 865
	if preserveArtifacts == nil then -- 865
		preserveArtifacts = false -- 865
	end -- 865
	local session = getSessionItem(sessionId) -- 866
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 867
	do -- 867
		local i = 0 -- 868
		while i < #children do -- 868
			local row = children[i + 1] -- 869
			if type(row[1]) == "number" and row[1] > 0 then -- 869
				deleteSessionRecords(row[1], preserveArtifacts) -- 871
			end -- 871
			i = i + 1 -- 868
		end -- 868
	end -- 868
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 874
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 875
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 876
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 877
	if session and session.kind == "main" then -- 877
		removePendingQuestionnaire(session) -- 879
	end -- 879
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 879
		Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) -- 882
	end -- 882
end -- 882
function getSessionRootId(session) -- 886
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 887
end -- 887
function getRootSessionItem(sessionId) -- 890
	local session = getSessionItem(sessionId) -- 891
	if not session then -- 891
		return nil -- 892
	end -- 892
	return getSessionItem(getSessionRootId(session)) or session -- 893
end -- 893
function listRelatedSessions(sessionId) -- 896
	local root = getRootSessionItem(sessionId) -- 897
	if not root then -- 897
		return {} -- 898
	end -- 898
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 899
	return __TS__ArrayMap( -- 908
		rows, -- 908
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 908
	) -- 908
end -- 908
function getSessionSpawnInfo(session) -- 911
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 912
	if not info then -- 912
		return nil -- 913
	end -- 913
	local ____temp_16 = type(info.sessionId) == "number" and info.sessionId or nil -- 915
	local ____temp_17 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 916
	local ____temp_18 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 917
	local ____temp_19 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 918
	local ____temp_20 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 919
	local ____temp_21 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 920
	local ____temp_22 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 921
	local ____temp_23 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 922
		__TS__ArrayFilter( -- 923
			info.filesHint, -- 923
			function(____, item) return type(item) == "string" end -- 923
		), -- 923
		function(____, item) return sanitizeUTF8(item) end -- 923
	) or nil -- 923
	local ____temp_24 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 925
	local ____temp_14 -- 928
	if info.success == true then -- 928
		____temp_14 = true -- 928
	else -- 928
		local ____temp_13 -- 928
		if info.success == false then -- 928
			____temp_13 = false -- 928
		else -- 928
			____temp_13 = nil -- 928
		end -- 928
		____temp_14 = ____temp_13 -- 928
	end -- 928
	local ____temp_15 -- 929
	if info.cleared == true then -- 929
		____temp_15 = true -- 929
	else -- 929
		____temp_15 = nil -- 929
	end -- 929
	return { -- 914
		sessionId = ____temp_16, -- 915
		rootSessionId = ____temp_17, -- 916
		parentSessionId = ____temp_18, -- 917
		title = ____temp_19, -- 918
		prompt = ____temp_20, -- 919
		goal = ____temp_21, -- 920
		expectedOutput = ____temp_22, -- 921
		filesHint = ____temp_23, -- 922
		status = ____temp_24, -- 925
		success = ____temp_14, -- 928
		cleared = ____temp_15, -- 929
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 930
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 931
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 932
		changeSet = decodeChangeSetSummary(info.changeSet), -- 933
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 934
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 935
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 936
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 937
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 940
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 941
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 942
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 943
	} -- 943
end -- 943
function ensureDirRecursive(dir) -- 960
	if not dir or dir == "" then -- 960
		return false -- 961
	end -- 961
	if Content:exist(dir) then -- 961
		return Content:isdir(dir) -- 962
	end -- 962
	local parent = Path:getPath(dir) -- 963
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 963
		if not ensureDirRecursive(parent) then -- 963
			return false -- 966
		end -- 966
	end -- 966
	return Content:mkdir(dir) -- 969
end -- 969
function writeSpawnInfo(projectRoot, memoryScope, value) -- 972
	local dir = Path(projectRoot, ".agent", memoryScope) -- 973
	if not Content:exist(dir) then -- 973
		ensureDirRecursive(dir) -- 975
	end -- 975
	local path = Path(dir, SPAWN_INFO_FILE) -- 977
	local text = safeJsonEncode(value) -- 978
	if not text then -- 978
		return false -- 979
	end -- 979
	local content = text .. "\n" -- 980
	if not Content:save(path, content) then -- 980
		return false -- 982
	end -- 982
	Tools.sendWebIDEFileUpdate(path, true, content) -- 984
	return true -- 985
end -- 985
function readSpawnInfo(projectRoot, memoryScope) -- 988
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 989
	if not Content:exist(path) then -- 989
		return nil -- 990
	end -- 990
	local text = Content:load(path) -- 991
	if not text or __TS__StringTrim(text) == "" then -- 991
		return nil -- 992
	end -- 992
	local value = safeJsonDecode(text) -- 993
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 993
		return value -- 995
	end -- 995
	return nil -- 997
end -- 997
function getArtifactRelativeDir(memoryScope) -- 1000
	return Path(".agent", memoryScope) -- 1001
end -- 1001
function getArtifactDir(projectRoot, memoryScope) -- 1004
	return Path( -- 1005
		projectRoot, -- 1005
		getArtifactRelativeDir(memoryScope) -- 1005
	) -- 1005
end -- 1005
function getResultRelativePath(memoryScope) -- 1008
	return Path( -- 1009
		getArtifactRelativeDir(memoryScope), -- 1009
		RESULT_FILE -- 1009
	) -- 1009
end -- 1009
function getResultPath(projectRoot, memoryScope) -- 1012
	return Path( -- 1013
		projectRoot, -- 1013
		getResultRelativePath(memoryScope) -- 1013
	) -- 1013
end -- 1013
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1016
	if not resultFilePath or resultFilePath == "" then -- 1016
		return "" -- 1017
	end -- 1017
	local path = Path(projectRoot, resultFilePath) -- 1018
	if not Content:exist(path) then -- 1018
		return "" -- 1019
	end -- 1019
	local text = sanitizeUTF8(Content:load(path)) -- 1020
	if not text or __TS__StringTrim(text) == "" then -- 1020
		return "" -- 1021
	end -- 1021
	local marker = "\n## Summary\n" -- 1022
	local start = string.find(text, marker, 1, true) -- 1023
	if start ~= nil then -- 1023
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1025
	end -- 1025
	return __TS__StringTrim(text) -- 1027
end -- 1027
function buildStructuredSubAgentMemoryEntry(record) -- 1030
	local hasPassedValidation = false -- 1031
	do -- 1031
		local i = 0 -- 1032
		while i < #record.completion.validation do -- 1032
			local result = record.completion.validation[i + 1].result -- 1033
			if result == "failed" then -- 1033
				return nil -- 1038
			end -- 1038
			if result == "passed" then -- 1038
				hasPassedValidation = true -- 1040
			end -- 1040
			i = i + 1 -- 1032
		end -- 1032
	end -- 1032
	if not hasPassedValidation then -- 1032
		return nil -- 1043
	end -- 1043
	local candidates = record.completion.learningCandidates -- 1044
	local claims = {} -- 1045
	local evidence = {} -- 1046
	do -- 1046
		local i = 0 -- 1047
		while i < #candidates do -- 1047
			do -- 1047
				local candidate = candidates[i + 1] -- 1048
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1048
					goto __continue185 -- 1049
				end -- 1049
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1050
				do -- 1050
					local j = 0 -- 1051
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1051
						local item = candidate.evidence[j + 1] -- 1052
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1052
							evidence[#evidence + 1] = item -- 1053
						end -- 1053
						j = j + 1 -- 1051
					end -- 1051
				end -- 1051
			end -- 1051
			::__continue185:: -- 1051
			i = i + 1 -- 1047
		end -- 1047
	end -- 1047
	local content = takeUtf8Head( -- 1056
		table.concat(claims, "\n"), -- 1056
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1056
	) -- 1056
	if content == "" then -- 1056
		return nil -- 1057
	end -- 1057
	return { -- 1058
		sourceSessionId = record.sessionId, -- 1059
		sourceTaskId = record.sourceTaskId, -- 1060
		content = content, -- 1061
		evidence = evidence, -- 1062
		createdAt = record.finishedAt -- 1063
	} -- 1063
end -- 1063
function containsNormalizedText(text, query) -- 1067
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1068
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1069
	if normalizedQuery == "" then -- 1069
		return true -- 1070
	end -- 1070
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1071
end -- 1071
function getSubAgentDisplayKey(item) -- 1074
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1080
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1081
	local label = goal ~= "" and goal or title -- 1082
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1083
end -- 1083
function writeSubAgentResultFile(session, record, resultText) -- 1086
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1087
	if not Content:exist(dir) then -- 1087
		ensureDirRecursive(dir) -- 1089
	end -- 1089
	local ____array_33 = __TS__SparseArrayNew( -- 1089
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1092
		"- Status: " .. record.status, -- 1093
		"- Success: " .. (record.success and "true" or "false"), -- 1094
		"- Outcome: " .. record.completion.outcome, -- 1095
		"- Session ID: " .. tostring(record.sessionId), -- 1096
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1097
		"- Goal: " .. record.goal, -- 1098
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1099
	) -- 1099
	__TS__SparseArrayPush( -- 1099
		____array_33, -- 1099
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1100
	) -- 1100
	__TS__SparseArrayPush( -- 1100
		____array_33, -- 1100
		"- Finished At: " .. record.finishedAt, -- 1101
		"", -- 1102
		"## Validation", -- 1103
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1104
			record.completion.validation, -- 1105
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1105
		) or ({"- Not reported"})) -- 1105
	) -- 1105
	__TS__SparseArrayPush(____array_33, "", "## Recorded Evidence") -- 1105
	local ____opt_25 = record.handoffEvidence -- 1105
	__TS__SparseArrayPush( -- 1105
		____array_33, -- 1105
		table.unpack(____opt_25 and #____opt_25.modifiedFiles and __TS__ArrayMap( -- 1109
			record.handoffEvidence.modifiedFiles, -- 1110
			function(____, item) return "- modified: " .. item end -- 1110
		) or ({"- modified: none recorded"})) -- 1110
	) -- 1110
	local ____opt_27 = record.handoffEvidence -- 1110
	__TS__SparseArrayPush( -- 1110
		____array_33, -- 1110
		table.unpack(____opt_27 and ____opt_27.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1112
	) -- 1112
	local ____opt_29 = record.handoffEvidence -- 1112
	__TS__SparseArrayPush( -- 1112
		____array_33, -- 1112
		table.unpack(__TS__ArrayMap( -- 1115
			____opt_29 and ____opt_29.commands or ({}), -- 1115
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1115
		)) -- 1115
	) -- 1115
	local ____opt_31 = record.handoffEvidence -- 1115
	__TS__SparseArrayPush( -- 1115
		____array_33, -- 1115
		table.unpack(__TS__ArrayMap( -- 1116
			____opt_31 and ____opt_31.authoritativeSources or ({}), -- 1116
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1116
		)) -- 1116
	) -- 1116
	__TS__SparseArrayPush( -- 1116
		____array_33, -- 1116
		"", -- 1117
		"## Known Issues", -- 1118
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1119
			record.completion.knownIssues, -- 1119
			function(____, item) return "- " .. item end -- 1119
		) or ({"- None reported"})) -- 1119
	) -- 1119
	__TS__SparseArrayPush( -- 1119
		____array_33, -- 1119
		"", -- 1120
		"## Assumptions", -- 1121
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1122
			record.completion.assumptions, -- 1122
			function(____, item) return "- " .. item end -- 1122
		) or ({"- None reported"})) -- 1122
	) -- 1122
	__TS__SparseArrayPush(____array_33, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1122
	local lines = {__TS__SparseArraySpread(____array_33)} -- 1091
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1127
	local content = table.concat(lines, "\n") .. "\n" -- 1128
	if not Content:save(path, content) then -- 1128
		return false -- 1130
	end -- 1130
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1132
	return true -- 1133
end -- 1133
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1136
	local dir = Path(projectRoot, ".agent", "subagents") -- 1137
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1137
		return {} -- 1138
	end -- 1138
	local items = {} -- 1139
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1140
		do -- 1140
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1141
			if not Content:exist(path) or not Content:isdir(path) then -- 1141
				goto __continue205 -- 1142
			end -- 1142
			local info = readSpawnInfo( -- 1143
				projectRoot, -- 1143
				Path( -- 1143
					"subagents", -- 1143
					Path:getFilename(path) -- 1143
				) -- 1143
			) -- 1143
			if not info then -- 1143
				goto __continue205 -- 1144
			end -- 1144
			local sessionId = tonumber(info.sessionId) -- 1145
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1146
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1147
			local status = sanitizeUTF8(toStr(info.status)) -- 1148
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1148
				goto __continue205 -- 1149
			end -- 1149
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1149
				goto __continue205 -- 1150
			end -- 1150
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1151
			items[#items + 1] = { -- 1152
				sessionId = sessionId, -- 1153
				rootSessionId = infoRootSessionId, -- 1154
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1155
				title = sanitizeUTF8(toStr(info.title)), -- 1156
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1157
				goal = sanitizeUTF8(toStr(info.goal)), -- 1158
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1159
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1160
					__TS__ArrayFilter( -- 1161
						info.filesHint, -- 1161
						function(____, item) return type(item) == "string" end -- 1161
					), -- 1161
					function(____, item) return sanitizeUTF8(item) end -- 1161
				) or ({}), -- 1161
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1163
				success = info.success == true, -- 1164
				cleared = info.cleared == true, -- 1165
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1166
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1167
					"subagents", -- 1167
					Path:getFilename(path) -- 1167
				)), -- 1167
				sourceTaskId = sourceTaskId or 0, -- 1168
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1169
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1170
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1171
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1172
				completion = normalizeAgentCompletionReport(info.completion), -- 1173
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1174
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1175
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1176
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1177
			} -- 1177
		end -- 1177
		::__continue205:: -- 1177
	end -- 1177
	__TS__ArraySort( -- 1180
		items, -- 1180
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1180
	) -- 1180
	return items -- 1181
end -- 1181
function getPendingHandoffDir(projectRoot, memoryScope) -- 1184
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1185
end -- 1185
function writePendingHandoff(projectRoot, memoryScope, value) -- 1188
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1189
	if not Content:exist(dir) then -- 1189
		ensureDirRecursive(dir) -- 1191
	end -- 1191
	local path = Path(dir, value.id .. ".json") -- 1193
	local text = safeJsonEncode(value) -- 1194
	if not text then -- 1194
		return false -- 1195
	end -- 1195
	return Content:save(path, text .. "\n") -- 1196
end -- 1196
function listPendingHandoffs(projectRoot, memoryScope) -- 1199
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1200
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1200
		return {} -- 1201
	end -- 1201
	local items = {} -- 1202
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1203
		do -- 1203
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1204
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1204
				goto __continue220 -- 1205
			end -- 1205
			local text = Content:load(path) -- 1206
			if not text or __TS__StringTrim(text) == "" then -- 1206
				goto __continue220 -- 1207
			end -- 1207
			local obj = safeJsonDecode(text) -- 1208
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1208
				goto __continue220 -- 1209
			end -- 1209
			local value = obj -- 1210
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1211
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1212
			local id = sanitizeUTF8(toStr(value.id)) -- 1213
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1214
			local message = sanitizeUTF8(toStr(value.message)) -- 1215
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1216
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1217
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1218
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1218
				goto __continue220 -- 1220
			end -- 1220
			items[#items + 1] = { -- 1222
				id = id, -- 1223
				sourceSessionId = sourceSessionId, -- 1224
				sourceTitle = sourceTitle, -- 1225
				sourceTaskId = sourceTaskId, -- 1226
				message = message, -- 1227
				prompt = prompt, -- 1228
				goal = goal, -- 1229
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1230
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1231
					__TS__ArrayFilter( -- 1232
						value.filesHint, -- 1232
						function(____, item) return type(item) == "string" end -- 1232
					), -- 1232
					function(____, item) return sanitizeUTF8(item) end -- 1232
				) or ({}), -- 1232
				success = value.success == true, -- 1234
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1235
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1236
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1237
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1238
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1239
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1240
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1241
				createdAt = createdAt -- 1244
			} -- 1244
		end -- 1244
		::__continue220:: -- 1244
	end -- 1244
	__TS__ArraySort( -- 1247
		items, -- 1247
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1247
	) -- 1247
	return items -- 1248
end -- 1248
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1251
	local path = Path( -- 1252
		getPendingHandoffDir(projectRoot, memoryScope), -- 1252
		id .. ".json" -- 1252
	) -- 1252
	if Content:exist(path) then -- 1252
		Content:remove(path) -- 1254
	end -- 1254
end -- 1254
function normalizePromptText(prompt) -- 1258
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1259
end -- 1259
function normalizePromptTextSafe(prompt) -- 1262
	if type(prompt) == "string" then -- 1262
		local normalized = normalizePromptText(prompt) -- 1264
		if normalized ~= "" then -- 1264
			return normalized -- 1265
		end -- 1265
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1266
		if sanitized ~= "" then -- 1266
			return truncateAgentUserPrompt(sanitized) -- 1268
		end -- 1268
		return "" -- 1270
	end -- 1270
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1272
	if text == "" then -- 1272
		return "" -- 1273
	end -- 1273
	return truncateAgentUserPrompt(text) -- 1274
end -- 1274
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1277
	local sections = {} -- 1278
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1279
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1280
	local normalizedFiles = __TS__ArrayFilter( -- 1281
		__TS__ArrayMap( -- 1281
			__TS__ArrayFilter( -- 1281
				filesHint or ({}), -- 1281
				function(____, item) return type(item) == "string" end -- 1282
			), -- 1282
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1283
		), -- 1283
		function(____, item) return item ~= "" end -- 1284
	) -- 1284
	if normalizedTitle ~= "" then -- 1284
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1286
	end -- 1286
	if normalizedExpected ~= "" then -- 1286
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1289
	end -- 1289
	if #normalizedFiles > 0 then -- 1289
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1292
	end -- 1292
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1294
end -- 1294
function normalizeSessionRuntimeState(session) -- 1297
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1297
		return session -- 1299
	end -- 1299
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1299
		return session -- 1302
	end -- 1302
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({}) -- 1304
	if #pendingToolRows > 0 then -- 1304
		local t = now() -- 1310
		do -- 1310
			local i = 0 -- 1311
			while i < #pendingToolRows do -- 1311
				local row = pendingToolRows[i + 1] -- 1312
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1313
				result.success = false -- 1314
				result.state = "failed" -- 1315
				result.interrupted = true -- 1316
				result.message = "tool call was interrupted because the program exited before it completed." -- 1317
				DB:exec( -- 1318
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1318
					{ -- 1320
						encodeJson(result), -- 1320
						t, -- 1320
						row[1] -- 1320
					} -- 1320
				) -- 1320
				i = i + 1 -- 1311
			end -- 1311
		end -- 1311
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1323
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1324
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1325
	end -- 1325
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1332
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1333
	return __TS__ObjectAssign( -- 1334
		{}, -- 1334
		session, -- 1335
		{ -- 1334
			status = "STOPPED", -- 1336
			currentTaskStatus = "STOPPED", -- 1337
			updatedAt = now() -- 1338
		} -- 1338
	) -- 1338
end -- 1338
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1342
	DB:exec( -- 1343
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1343
		{ -- 1347
			status, -- 1348
			currentTaskId or 0, -- 1349
			currentTaskStatus or status, -- 1350
			now(), -- 1351
			sessionId -- 1352
		} -- 1352
	) -- 1352
end -- 1352
function mergeAgentMetrics(current, next) -- 1357
	return __TS__ObjectAssign({}, current or ({}), next) -- 1358
end -- 1358
function updateSessionMetrics(sessionId, metrics) -- 1364
	local session = getSessionItem(sessionId) -- 1365
	if not session then -- 1365
		return nil -- 1366
	end -- 1366
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1367
	DB:exec( -- 1368
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1368
		{ -- 1372
			encodeJson(merged), -- 1373
			now(), -- 1374
			sessionId -- 1375
		} -- 1375
	) -- 1375
	return merged -- 1378
end -- 1378
function clearSessionTokenUsage(sessionId) -- 1381
	local session = getSessionItem(sessionId) -- 1382
	if not session then -- 1382
		return nil -- 1383
	end -- 1383
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1384
	__TS__Delete(metrics, "usage") -- 1385
	DB:exec( -- 1386
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1386
		{ -- 1390
			encodeJson(metrics), -- 1391
			now(), -- 1392
			sessionId -- 1393
		} -- 1393
	) -- 1393
	return metrics -- 1396
end -- 1396
function getInitialTokenUsage(session) -- 1399
	local ____opt_34 = session.metrics -- 1399
	local usage = ____opt_34 and ____opt_34.usage -- 1400
	if not usage or (usage.requestCount or 0) <= 0 then -- 1400
		return nil -- 1401
	end -- 1401
	return { -- 1402
		inputTokens = usage.inputTokens or 0, -- 1403
		outputTokens = usage.outputTokens or 0, -- 1404
		totalTokens = usage.totalTokens, -- 1405
		cachedInputTokens = usage.cachedInputTokens, -- 1406
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1407
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1408
		requestCount = usage.requestCount or 0, -- 1409
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1410
		model = usage.model or "", -- 1411
		phase = usage.phase or "", -- 1412
		step = usage.step or 0, -- 1413
		updatedAt = usage.updatedAt or now() -- 1414
	} -- 1414
end -- 1414
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1418
	if taskId == nil or taskId <= 0 then -- 1418
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1420
		return -- 1421
	end -- 1421
	local row = getSessionRow(sessionId) -- 1423
	if not row then -- 1423
		return -- 1424
	end -- 1424
	local session = rowToSession(row) -- 1425
	if session.currentTaskId ~= taskId then -- 1425
		Log( -- 1427
			"Info", -- 1427
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1427
		) -- 1427
		return -- 1428
	end -- 1428
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1430
end -- 1430
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1433
	local t = now() -- 1434
	DB:exec( -- 1435
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1435
		{ -- 1438
			sessionId, -- 1439
			taskId or 0, -- 1440
			role, -- 1441
			sanitizeUTF8(content), -- 1442
			displayContent and sanitizeUTF8(displayContent) or "", -- 1443
			t, -- 1444
			t -- 1445
		} -- 1445
	) -- 1445
	return getLastInsertRowId() -- 1448
end -- 1448
function updateMessage(messageId, content) -- 1451
	DB:exec( -- 1452
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1452
		{ -- 1454
			sanitizeUTF8(content), -- 1454
			now(), -- 1454
			messageId -- 1454
		} -- 1454
	) -- 1454
end -- 1454
function updateUserMessageForTask(messageId, content, taskId) -- 1458
	DB:exec( -- 1459
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1459
		{ -- 1463
			sanitizeUTF8(content), -- 1463
			taskId, -- 1463
			now(), -- 1463
			messageId -- 1463
		} -- 1463
	) -- 1463
end -- 1463
function removeStoppedTaskSummary(session) -- 1520
	local taskId = session.currentTaskId -- 1521
	if taskId == nil then -- 1521
		return -- 1522
	end -- 1522
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1523
end -- 1523
function upsertAssistantMessage(sessionId, taskId, content) -- 1529
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1530
	if row and type(row[1]) == "number" then -- 1530
		updateMessage(row[1], content) -- 1537
		return row[1] -- 1538
	end -- 1538
	return insertMessage(sessionId, "assistant", content, taskId) -- 1540
end -- 1540
function upsertStep(sessionId, taskId, step, tool, patch) -- 1543
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1553
	local reason = sanitizeUTF8(patch.reason or "") -- 1557
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1558
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1559
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1560
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1561
	local statusPatch = patch.status or "" -- 1562
	local status = patch.status or "PENDING" -- 1563
	if not row then -- 1563
		local t = now() -- 1565
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1566
			sessionId, -- 1570
			taskId, -- 1571
			step, -- 1572
			tool, -- 1573
			status, -- 1574
			reason, -- 1575
			reasoningContent, -- 1576
			paramsJson, -- 1577
			resultJson, -- 1578
			patch.checkpointId or 0, -- 1579
			patch.checkpointSeq or 0, -- 1580
			filesJson, -- 1581
			t, -- 1582
			t -- 1583
		}) -- 1583
		return -- 1586
	end -- 1586
	DB:exec( -- 1588
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1588
		{ -- 1600
			tool, -- 1601
			statusPatch, -- 1602
			status, -- 1603
			reason, -- 1604
			reason, -- 1605
			reasoningContent, -- 1606
			reasoningContent, -- 1607
			paramsJson, -- 1608
			paramsJson, -- 1609
			resultJson, -- 1610
			resultJson, -- 1611
			patch.checkpointId or 0, -- 1612
			patch.checkpointId or 0, -- 1613
			patch.checkpointSeq or 0, -- 1614
			patch.checkpointSeq or 0, -- 1615
			filesJson, -- 1616
			filesJson, -- 1617
			now(), -- 1618
			row[1] -- 1619
		} -- 1619
	) -- 1619
end -- 1619
function getNextStepNumber(sessionId, taskId) -- 1624
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1625
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1629
	return math.max(0, current) + 1 -- 1630
end -- 1630
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1651
	if status == nil then -- 1651
		status = "DONE" -- 1659
	end -- 1659
	local step = getNextStepNumber(sessionId, taskId) -- 1661
	upsertStep( -- 1662
		sessionId, -- 1662
		taskId, -- 1662
		step, -- 1662
		tool, -- 1662
		{status = status, reason = reason, params = params, result = result} -- 1662
	) -- 1662
	return getStepItem(sessionId, taskId, step) -- 1668
end -- 1668
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1671
	if taskId <= 0 then -- 1671
		return -- 1672
	end -- 1672
	if finalSteps ~= nil and finalSteps >= 0 then -- 1672
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1674
	end -- 1674
	if not finalStatus then -- 1674
		return -- 1680
	end -- 1680
	if finalSteps ~= nil and finalSteps >= 0 then -- 1680
		DB:exec( -- 1682
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1682
			{ -- 1686
				finalStatus, -- 1686
				now(), -- 1686
				sessionId, -- 1686
				taskId, -- 1686
				finalSteps -- 1686
			} -- 1686
		) -- 1686
		return -- 1688
	end -- 1688
	DB:exec( -- 1690
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1690
		{ -- 1694
			finalStatus, -- 1694
			now(), -- 1694
			sessionId, -- 1694
			taskId -- 1694
		} -- 1694
	) -- 1694
end -- 1694
function emitAgentSessionPatch(sessionId, patch) -- 1721
	if HttpServer.wsConnectionCount == 0 then -- 1721
		return -- 1723
	end -- 1723
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1725
	if not text then -- 1725
		return -- 1730
	end -- 1730
	emit("AppWS", "Send", text) -- 1731
end -- 1731
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1734
	emitAgentSessionPatch( -- 1735
		sessionId, -- 1735
		{ -- 1735
			sessionDeleted = true, -- 1736
			relatedSessions = listRelatedSessions(rootSessionId) -- 1737
		} -- 1737
	) -- 1737
	local rootSession = getSessionItem(rootSessionId) -- 1739
	if rootSession then -- 1739
		emitAgentSessionPatch( -- 1741
			rootSessionId, -- 1741
			{ -- 1741
				session = rootSession, -- 1742
				relatedSessions = listRelatedSessions(rootSessionId) -- 1743
			} -- 1743
		) -- 1743
	end -- 1743
end -- 1743
function flushPendingSubAgentHandoffs(rootSession) -- 1748
	if rootSession.kind ~= "main" then -- 1748
		return -- 1749
	end -- 1749
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1749
		return -- 1751
	end -- 1751
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1753
	if #items == 0 then -- 1753
		return -- 1754
	end -- 1754
	local handoffTaskId = 0 -- 1755
	local ____rootSession_currentTaskId_36 -- 1756
	if rootSession.currentTaskId then -- 1756
		____rootSession_currentTaskId_36 = getTaskPrompt(rootSession.currentTaskId) -- 1756
	else -- 1756
		____rootSession_currentTaskId_36 = nil -- 1756
	end -- 1756
	local currentTaskPrompt = ____rootSession_currentTaskId_36 -- 1756
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1756
		handoffTaskId = rootSession.currentTaskId -- 1764
	else -- 1764
		local taskRes = Tools.createTask( -- 1766
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1766
			"code" -- 1766
		) -- 1766
		if not taskRes.success then -- 1766
			Log( -- 1768
				"Warn", -- 1768
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1768
			) -- 1768
			return -- 1769
		end -- 1769
		handoffTaskId = taskRes.taskId -- 1771
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1772
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1773
		emitAgentSessionPatch( -- 1774
			rootSession.id, -- 1774
			{session = getSessionItem(rootSession.id)} -- 1774
		) -- 1774
	end -- 1774
	do -- 1774
		local i = 0 -- 1778
		while i < #items do -- 1778
			local item = items[i + 1] -- 1779
			local step = appendSystemStep( -- 1780
				rootSession.id, -- 1781
				handoffTaskId, -- 1782
				"sub_agent_handoff", -- 1783
				"sub_agent_handoff", -- 1784
				item.message, -- 1785
				{ -- 1786
					sourceSessionId = item.sourceSessionId, -- 1787
					sourceTitle = item.sourceTitle, -- 1788
					sourceTaskId = item.sourceTaskId, -- 1789
					success = item.success == true, -- 1790
					summary = item.message, -- 1791
					resultFilePath = item.resultFilePath or "", -- 1792
					artifactDir = item.artifactDir or "", -- 1793
					finishedAt = item.finishedAt or "", -- 1794
					changeSet = item.changeSet, -- 1795
					handoffEvidence = item.handoffEvidence, -- 1796
					memoryEntry = item.memoryEntry, -- 1797
					completion = item.completion -- 1798
				}, -- 1798
				{ -- 1800
					sourceSessionId = item.sourceSessionId, -- 1801
					sourceTitle = item.sourceTitle, -- 1802
					sourceTaskId = item.sourceTaskId, -- 1803
					prompt = item.prompt, -- 1804
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1805
					expectedOutput = item.expectedOutput or "", -- 1806
					filesHint = item.filesHint or ({}), -- 1807
					resultFilePath = item.resultFilePath or "", -- 1808
					artifactDir = item.artifactDir or "", -- 1809
					changeSet = item.changeSet, -- 1810
					handoffEvidence = item.handoffEvidence, -- 1811
					memoryEntry = item.memoryEntry, -- 1812
					completion = item.completion -- 1813
				}, -- 1813
				"DONE" -- 1815
			) -- 1815
			if step then -- 1815
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1818
			end -- 1818
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1820
			i = i + 1 -- 1778
		end -- 1778
	end -- 1778
end -- 1778
function applyEvent(sessionId, event) -- 1832
	repeat -- 1832
		local ____switch305 = event.type -- 1832
		local metrics, startedSession -- 1832
		local ____cond305 = ____switch305 == "task_started" -- 1832
		if ____cond305 then -- 1832
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1835
			local ____event_resumed_39 -- 1836
			if event.resumed then -- 1836
				local ____opt_37 = getSessionItem(sessionId) -- 1836
				____event_resumed_39 = ____opt_37 and ____opt_37.metrics -- 1837
			else -- 1837
				____event_resumed_39 = clearSessionTokenUsage(sessionId) -- 1838
			end -- 1838
			metrics = ____event_resumed_39 -- 1836
			startedSession = getSessionItem(sessionId) -- 1839
			emitAgentSessionPatch( -- 1840
				sessionId, -- 1840
				{ -- 1840
					session = startedSession, -- 1841
					metrics = metrics, -- 1842
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1843
				} -- 1843
			) -- 1843
			break -- 1847
		end -- 1847
		____cond305 = ____cond305 or ____switch305 == "decision_made" -- 1847
		if ____cond305 then -- 1847
			upsertStep( -- 1849
				sessionId, -- 1849
				event.taskId, -- 1849
				event.step, -- 1849
				event.tool, -- 1849
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1849
			) -- 1849
			emitAgentSessionPatch( -- 1857
				sessionId, -- 1857
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1857
			) -- 1857
			break -- 1860
		end -- 1860
		____cond305 = ____cond305 or ____switch305 == "tool_started" -- 1860
		if ____cond305 then -- 1860
			upsertStep( -- 1862
				sessionId, -- 1862
				event.taskId, -- 1862
				event.step, -- 1862
				event.tool, -- 1862
				{status = "RUNNING"} -- 1862
			) -- 1862
			emitAgentSessionPatch( -- 1865
				sessionId, -- 1865
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1865
			) -- 1865
			break -- 1868
		end -- 1868
		____cond305 = ____cond305 or ____switch305 == "tool_finished" -- 1868
		if ____cond305 then -- 1868
			do -- 1868
				local ____temp_42 = event.result.success ~= true -- 1870
				if ____temp_42 then -- 1870
					local ____opt_40 = activeStopTokens[event.taskId] -- 1870
					____temp_42 = (____opt_40 and ____opt_40.stopped) == true -- 1870
				end -- 1870
				local stopped = ____temp_42 -- 1870
				upsertStep( -- 1872
					sessionId, -- 1872
					event.taskId, -- 1872
					event.step, -- 1872
					event.tool, -- 1872
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1872
				) -- 1872
				emitAgentSessionPatch( -- 1880
					sessionId, -- 1880
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1880
				) -- 1880
				break -- 1883
			end -- 1883
		end -- 1883
		____cond305 = ____cond305 or ____switch305 == "tool_progress" -- 1883
		if ____cond305 then -- 1883
			do -- 1883
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1887
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1887
					break -- 1889
				end -- 1889
			end -- 1889
			upsertStep( -- 1892
				sessionId, -- 1892
				event.taskId, -- 1892
				event.step, -- 1892
				event.tool, -- 1892
				{status = "RUNNING", result = event.result} -- 1892
			) -- 1892
			emitAgentSessionPatch( -- 1896
				sessionId, -- 1896
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1896
			) -- 1896
			break -- 1899
		end -- 1899
		____cond305 = ____cond305 or ____switch305 == "checkpoint_created" -- 1899
		if ____cond305 then -- 1899
			upsertStep( -- 1901
				sessionId, -- 1901
				event.taskId, -- 1901
				event.step, -- 1901
				event.tool, -- 1901
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1901
			) -- 1901
			emitAgentSessionPatch( -- 1906
				sessionId, -- 1906
				{ -- 1906
					step = getStepItem(sessionId, event.taskId, event.step), -- 1907
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1908
				} -- 1908
			) -- 1908
			break -- 1910
		end -- 1910
		____cond305 = ____cond305 or ____switch305 == "memory_compression_started" -- 1910
		if ____cond305 then -- 1910
			upsertStep( -- 1912
				sessionId, -- 1912
				event.taskId, -- 1912
				event.step, -- 1912
				event.tool, -- 1912
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1912
			) -- 1912
			emitAgentSessionPatch( -- 1917
				sessionId, -- 1917
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1917
			) -- 1917
			break -- 1920
		end -- 1920
		____cond305 = ____cond305 or ____switch305 == "memory_compression_finished" -- 1920
		if ____cond305 then -- 1920
			upsertStep( -- 1922
				sessionId, -- 1922
				event.taskId, -- 1922
				event.step, -- 1922
				event.tool, -- 1922
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1922
			) -- 1922
			emitAgentSessionPatch( -- 1927
				sessionId, -- 1927
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1927
			) -- 1927
			break -- 1930
		end -- 1930
		____cond305 = ____cond305 or ____switch305 == "metrics_updated" -- 1930
		if ____cond305 then -- 1930
			do -- 1930
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1932
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1933
				break -- 1936
			end -- 1936
		end -- 1936
		____cond305 = ____cond305 or ____switch305 == "assistant_message_updated" -- 1936
		if ____cond305 then -- 1936
			do -- 1936
				upsertStep( -- 1939
					sessionId, -- 1939
					event.taskId, -- 1939
					event.step, -- 1939
					"message", -- 1939
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1939
				) -- 1939
				emitAgentSessionPatch( -- 1944
					sessionId, -- 1944
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1944
				) -- 1944
				break -- 1947
			end -- 1947
		end -- 1947
		____cond305 = ____cond305 or ____switch305 == "task_waiting_for_user" -- 1947
		if ____cond305 then -- 1947
			do -- 1947
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 1950
				__TS__Delete(activeStopTokens, event.taskId) -- 1951
				emitAgentSessionPatch( -- 1952
					sessionId, -- 1952
					{ -- 1952
						session = getSessionItem(sessionId), -- 1953
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 1954
					} -- 1954
				) -- 1954
				break -- 1956
			end -- 1956
		end -- 1956
		____cond305 = ____cond305 or ____switch305 == "task_finished" -- 1956
		if ____cond305 then -- 1956
			do -- 1956
				local session = getSessionItem(sessionId) -- 1959
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 1959
					__TS__Delete(activeStopTokens, event.taskId) -- 1961
					Log( -- 1962
						"Info", -- 1962
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1962
					) -- 1962
					break -- 1963
				end -- 1963
				local ____opt_43 = activeStopTokens[event.taskId or -1] -- 1963
				local stopped = (____opt_43 and ____opt_43.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 1965
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1967
				local isSubSession = (session and session.kind) == "sub" -- 1970
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1971
				if isSubSession and event.taskId ~= nil then -- 1971
					finalizingSubSessionTaskIds[event.taskId] = true -- 1973
				end -- 1973
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1975
				if event.taskId ~= nil then -- 1975
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1977
					local ____finalizeTaskSteps_49 = finalizeTaskSteps -- 1978
					local ____array_48 = __TS__SparseArrayNew( -- 1978
						sessionId, -- 1979
						event.taskId, -- 1980
						type(event.steps) == "number" and math.max( -- 1981
							0, -- 1981
							math.floor(event.steps) -- 1981
						) or nil -- 1981
					) -- 1981
					local ____event_success_47 -- 1982
					if event.success then -- 1982
						____event_success_47 = nil -- 1982
					else -- 1982
						____event_success_47 = stopped and "STOPPED" or "FAILED" -- 1982
					end -- 1982
					__TS__SparseArrayPush(____array_48, ____event_success_47) -- 1982
					____finalizeTaskSteps_49(__TS__SparseArraySpread(____array_48)) -- 1978
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1984
					if not isSubSession then -- 1984
						__TS__Delete(activeStopTokens, event.taskId) -- 1986
					end -- 1986
					emitAgentSessionPatch( -- 1988
						sessionId, -- 1988
						{ -- 1988
							session = getSessionItem(sessionId), -- 1989
							message = getMessageItem(messageId), -- 1990
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1991
							removedStepIds = removedStepIds -- 1992
						} -- 1992
					) -- 1992
				end -- 1992
				if session and session.kind == "main" then -- 1992
					flushPendingSubAgentHandoffs(session) -- 1996
				end -- 1996
				break -- 1998
			end -- 1998
		end -- 1998
	until true -- 1998
end -- 1998
function ____exports.createSession(projectRoot, title) -- 2157
	if title == nil then -- 2157
		title = "" -- 2157
	end -- 2157
	if not isValidProjectRoot(projectRoot) then -- 2157
		return {success = false, message = "invalid projectRoot"} -- 2159
	end -- 2159
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2161
	if row then -- 2161
		return { -- 2170
			success = true, -- 2170
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2170
		} -- 2170
	end -- 2170
	local t = now() -- 2172
	DB:exec( -- 2173
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 2173
		{ -- 2176
			projectRoot, -- 2176
			title ~= "" and title or Path:getFilename(projectRoot), -- 2176
			t, -- 2176
			t -- 2176
		} -- 2176
	) -- 2176
	local sessionId = getLastInsertRowId() -- 2178
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2179
	local session = getSessionItem(sessionId) -- 2180
	if not session then -- 2180
		return {success = false, message = "failed to create session"} -- 2182
	end -- 2182
	return {success = true, session = session} -- 2184
end -- 2157
function ____exports.createSubSession(parentSessionId, title) -- 2187
	if title == nil then -- 2187
		title = "" -- 2187
	end -- 2187
	local parent = getSessionItem(parentSessionId) -- 2188
	if not parent then -- 2188
		return {success = false, message = "parent session not found"} -- 2190
	end -- 2190
	local rootId = getSessionRootId(parent) -- 2192
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
end -- 2187
function spawnSubAgentSession(request) -- 2212
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2212
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2225
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2226
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2227
		if normalizedPrompt == "" then -- 2227
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2229
		end -- 2229
		if normalizedPrompt == "" then -- 2229
			local ____Log_55 = Log -- 2236
			local ____temp_52 = #normalizedTitle -- 2236
			local ____temp_53 = #rawPrompt -- 2236
			local ____temp_54 = #toStr(request.expectedOutput) -- 2236
			local ____opt_50 = request.filesHint -- 2236
			____Log_55( -- 2236
				"Warn", -- 2236
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_52)) .. " raw_prompt_len=") .. tostring(____temp_53)) .. " expected_len=") .. tostring(____temp_54)) .. " files_hint_count=") .. tostring(____opt_50 and #____opt_50 or 0) -- 2236
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
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2258
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2258
		end -- 2258
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2262
		if not created.success then -- 2262
			return ____awaiter_resolve(nil, created) -- 2262
		end -- 2262
		writeSpawnInfo( -- 2266
			created.session.projectRoot, -- 2266
			created.session.memoryScope, -- 2266
			{ -- 2266
				sessionId = created.session.id, -- 2267
				rootSessionId = created.session.rootSessionId, -- 2268
				parentSessionId = created.session.parentSessionId, -- 2269
				title = created.session.title, -- 2270
				prompt = normalizedPrompt, -- 2271
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2272
				expectedOutput = request.expectedOutput or "", -- 2273
				filesHint = request.filesHint or ({}), -- 2274
				status = "RUNNING", -- 2275
				success = false, -- 2276
				resultFilePath = "", -- 2277
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2278
				sourceTaskId = 0, -- 2279
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2280
				createdAtTs = created.session.createdAt, -- 2281
				finishedAt = "", -- 2282
				finishedAtTs = 0 -- 2283
			} -- 2283
		) -- 2283
		local sent = ____exports.sendPrompt( -- 2285
			created.session.id, -- 2285
			normalizedPrompt, -- 2285
			true, -- 2285
			request.disabledAgentTools, -- 2285
			nil, -- 2285
			nil, -- 2285
			request.llmConfig -- 2285
		) -- 2285
		if not sent.success then -- 2285
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2285
		end -- 2285
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2285
	end) -- 2285
end -- 2285
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2390
	local rootSession = getRootSessionItem(session.id) -- 2391
	if not rootSession then -- 2391
		return -- 2392
	end -- 2392
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2393
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2394
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2395
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2396
	local queueResult = writePendingHandoff( -- 2397
		rootSession.projectRoot, -- 2397
		rootSession.memoryScope, -- 2397
		{ -- 2397
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2398
			sourceSessionId = session.id, -- 2399
			sourceTitle = session.title, -- 2400
			sourceTaskId = taskId, -- 2401
			message = summary, -- 2402
			prompt = result.prompt, -- 2403
			goal = result.goal, -- 2404
			expectedOutput = result.expectedOutput or "", -- 2405
			filesHint = result.filesHint or ({}), -- 2406
			success = result.success, -- 2407
			resultFilePath = result.resultFilePath, -- 2408
			artifactDir = result.artifactDir, -- 2409
			finishedAt = result.finishedAt, -- 2410
			changeSet = changeSet, -- 2411
			handoffEvidence = result.handoffEvidence, -- 2412
			memoryEntry = result.memoryEntry, -- 2413
			completion = result.completion, -- 2414
			createdAt = createdAt -- 2415
		} -- 2415
	) -- 2415
	if not queueResult then -- 2415
		Log( -- 2418
			"Warn", -- 2418
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2418
		) -- 2418
		return -- 2419
	end -- 2419
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2419
		flushPendingSubAgentHandoffs(rootSession) -- 2422
	end -- 2422
end -- 2422
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2426
	if forceHandoff == nil then -- 2426
		forceHandoff = false -- 2432
	end -- 2432
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2432
		local rootSessionId = getSessionRootId(session) -- 2434
		local rootSession = getRootSessionItem(session.id) -- 2435
		if not rootSession then -- 2435
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2435
		end -- 2435
		local spawnInfo = getSessionSpawnInfo(session) -- 2439
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2440
		local finishedAtTs = now() -- 2441
		local resultText = sanitizeUTF8(message) -- 2442
		local changeSet = getTaskChangeSetSummary(taskId) -- 2443
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2444
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2445
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2449
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2449
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2451
		end -- 2451
		local completed = success and completionReport.outcome == "completed" -- 2459
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2460
		local record = { -- 2463
			sessionId = session.id, -- 2464
			rootSessionId = rootSessionId, -- 2465
			parentSessionId = session.parentSessionId, -- 2466
			title = session.title, -- 2467
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2468
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2469
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2470
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2471
			status = recordStatus, -- 2472
			success = completed, -- 2473
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2474
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2475
			sourceTaskId = taskId, -- 2476
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2477
			finishedAt = finishedAt, -- 2478
			createdAtTs = session.createdAt, -- 2479
			finishedAtTs = finishedAtTs, -- 2480
			changeSet = changeSet, -- 2481
			handoffEvidence = handoffEvidence, -- 2482
			completion = completionReport -- 2483
		} -- 2483
		local ____record_success_68 -- 2485
		if record.success then -- 2485
			____record_success_68 = buildStructuredSubAgentMemoryEntry(record) -- 2485
		else -- 2485
			____record_success_68 = nil -- 2485
		end -- 2485
		record.memoryEntry = ____record_success_68 -- 2485
		if not writeSubAgentResultFile(session, record, resultText) then -- 2485
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2485
		end -- 2485
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2485
			sessionId = record.sessionId, -- 2490
			rootSessionId = record.rootSessionId, -- 2491
			parentSessionId = record.parentSessionId, -- 2492
			title = record.title, -- 2493
			prompt = record.prompt, -- 2494
			goal = record.goal, -- 2495
			expectedOutput = record.expectedOutput or "", -- 2496
			filesHint = record.filesHint or ({}), -- 2497
			status = record.status, -- 2498
			success = record.success, -- 2499
			resultFilePath = record.resultFilePath, -- 2500
			artifactDir = record.artifactDir, -- 2501
			sourceTaskId = record.sourceTaskId, -- 2502
			createdAt = record.createdAt, -- 2503
			finishedAt = record.finishedAt, -- 2504
			createdAtTs = record.createdAtTs, -- 2505
			finishedAtTs = record.finishedAtTs, -- 2506
			changeSet = record.changeSet, -- 2507
			handoffEvidence = record.handoffEvidence, -- 2508
			memoryEntry = record.memoryEntry, -- 2509
			memoryEntryError = record.memoryEntryError, -- 2510
			completion = record.completion -- 2511
		}) then -- 2511
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2511
		end -- 2511
		if success or forceHandoff then -- 2511
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2516
			deleteSessionRecords(session.id, true) -- 2517
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2518
		end -- 2518
		return ____awaiter_resolve(nil, {success = true}) -- 2518
	end) -- 2518
end -- 2518
function stopClearedSubSession(session, taskId) -- 2523
	local spawnInfo = getSessionSpawnInfo(session) -- 2524
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2525
	local rootSessionId = getSessionRootId(session) -- 2526
	Tools.setTaskStatus(taskId, "STOPPED") -- 2527
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2528
	if not writeSpawnInfo( -- 2528
		session.projectRoot, -- 2529
		session.memoryScope, -- 2529
		{ -- 2529
			sessionId = session.id, -- 2530
			rootSessionId = rootSessionId, -- 2531
			parentSessionId = session.parentSessionId, -- 2532
			title = session.title, -- 2533
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2534
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2535
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2536
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2537
			status = "STOPPED", -- 2538
			success = false, -- 2539
			cleared = true, -- 2540
			resultFilePath = "", -- 2541
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2542
			sourceTaskId = taskId, -- 2543
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2544
			finishedAt = finishedAt, -- 2545
			createdAtTs = session.createdAt, -- 2546
			finishedAtTs = now() -- 2547
		} -- 2547
	) then -- 2547
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2549
	end -- 2549
	deleteSessionRecords(session.id, true) -- 2551
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2552
	return {success = true} -- 2553
end -- 2553
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2556
	if allowSubSessionStart == nil then -- 2556
		allowSubSessionStart = false -- 2556
	end -- 2556
	local session = getSessionItem(sessionId) -- 2557
	if not session then -- 2557
		return {success = false, message = "session not found"} -- 2559
	end -- 2559
	if getPendingQuestionnaire(sessionId) then -- 2559
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2561
	end -- 2561
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2561
		return {success = false, message = "session task is finalizing"} -- 2563
	end -- 2563
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2563
		return {success = false, message = "session task is still running"} -- 2566
	end -- 2566
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2568
	if normalizedPrompt == "" and session.kind == "sub" then -- 2568
		local spawnInfo = getSessionSpawnInfo(session) -- 2570
		if spawnInfo then -- 2570
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2572
			if normalizedPrompt == "" then -- 2572
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2574
			end -- 2574
		end -- 2574
	end -- 2574
	if normalizedPrompt == "" then -- 2574
		return {success = false, message = "prompt is empty"} -- 2583
	end -- 2583
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2585
	if session.workMode ~= nextWorkMode then -- 2585
		DB:exec( -- 2587
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2587
			{ -- 2587
				nextWorkMode, -- 2587
				now(), -- 2587
				session.id -- 2587
			} -- 2587
		) -- 2587
		session.workMode = nextWorkMode -- 2588
	end -- 2588
	return startPromptTask( -- 2590
		session, -- 2590
		normalizedPrompt, -- 2590
		nil, -- 2590
		normalizeDisabledAgentTools(disabledAgentTools), -- 2590
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2590
	) -- 2590
end -- 2556
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2628
	if disabledAgentTools == nil then -- 2628
		disabledAgentTools = {} -- 2632
	end -- 2632
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2635
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2636
	if not llmConfigRes.success then -- 2636
		return {success = false, message = llmConfigRes.message} -- 2640
	end -- 2640
	local llmConfig = llmConfigRes.config -- 2642
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2643
	if not taskRes.success then -- 2643
		return {success = false, message = taskRes.message} -- 2646
	end -- 2646
	if session.currentTaskStatus == "STOPPED" then -- 2646
		removeStoppedTaskSummary(session) -- 2648
	end -- 2648
	local taskId = taskRes.taskId -- 2650
	local useChineseResponse = getDefaultUseChineseResponse() -- 2651
	if existingUserMessageId ~= nil then -- 2651
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2653
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2653
		insertMessage( -- 2655
			session.id, -- 2655
			"user", -- 2655
			normalizedPrompt, -- 2655
			taskId, -- 2655
			options and options.displayContent -- 2655
		) -- 2655
	end -- 2655
	local stopToken = {stopped = false} -- 2657
	activeStopTokens[taskId] = stopToken -- 2658
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2659
	local ____runCodingAgent_115 = runCodingAgent -- 2660
	local ____normalizedPrompt_108 = normalizedPrompt -- 2661
	local ____temp_109 = options and options.resumeConversation -- 2662
	local ____temp_110 = (options and options.existingTaskId) ~= nil -- 2663
	local ____temp_111 = options and options.initialStep -- 2664
	local ____temp_112 = options and options.initialAgentStepCount -- 2665
	local ____temp_103 -- 2666
	if (options and options.existingTaskId) ~= nil then -- 2666
		____temp_103 = getInitialTokenUsage(session) -- 2666
	else -- 2666
		____temp_103 = nil -- 2666
	end -- 2666
	____runCodingAgent_115( -- 2660
		{ -- 2660
			prompt = ____normalizedPrompt_108, -- 2661
			resumeConversation = ____temp_109, -- 2662
			resumeTask = ____temp_110, -- 2663
			initialStep = ____temp_111, -- 2664
			initialAgentStepCount = ____temp_112, -- 2665
			initialTokenUsage = ____temp_103, -- 2666
			workDir = session.projectRoot, -- 2667
			useChineseResponse = useChineseResponse, -- 2668
			taskId = taskId, -- 2669
			sessionId = session.id, -- 2670
			memoryScope = session.memoryScope, -- 2671
			role = session.kind, -- 2672
			maxSteps = options and options.maxSteps, -- 2673
			disabledAgentTools = disabledAgentTools, -- 2674
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2675
			llmConfig = llmConfig, -- 2676
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2677
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2680
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2683
			stopToken = stopToken, -- 2684
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2685
		}, -- 2685
		function(result) -- 2686
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2686
				local nextSession = getSessionItem(session.id) -- 2687
				if nextSession and nextSession.kind == "sub" then -- 2687
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2687
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2690
						if not stopped.success then -- 2690
							Log( -- 2692
								"Warn", -- 2692
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2692
							) -- 2692
							emitAgentSessionPatch( -- 2693
								session.id, -- 2693
								{session = getSessionItem(session.id)} -- 2693
							) -- 2693
						end -- 2693
						__TS__Delete(activeStopTokens, taskId) -- 2697
						return ____awaiter_resolve(nil) -- 2697
					end -- 2697
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2700
					emitAgentSessionPatch( -- 2701
						session.id, -- 2701
						{session = getSessionItem(session.id)} -- 2701
					) -- 2701
					local finalized = __TS__Await(finalizeSubSession( -- 2704
						nextSession, -- 2705
						taskId, -- 2706
						result.success, -- 2707
						result.message, -- 2708
						result.completion, -- 2709
						(options and options.forceSubAgentHandoff) == true -- 2710
					)) -- 2710
					if not finalized.success then -- 2710
						Log( -- 2713
							"Warn", -- 2713
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2713
						) -- 2713
					end -- 2713
					local finalizedSession = getSessionItem(session.id) -- 2715
					if finalizedSession then -- 2715
						local stopped = stopToken.stopped == true -- 2717
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2718
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2721
						emitAgentSessionPatch( -- 2722
							session.id, -- 2722
							{session = getSessionItem(session.id)} -- 2722
						) -- 2722
					end -- 2722
					__TS__Delete(activeStopTokens, taskId) -- 2726
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2727
				end -- 2727
				local fallbackSession = getSessionItem(session.id) -- 2729
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2729
					applyEvent(session.id, { -- 2735
						type = "task_finished", -- 2736
						sessionId = session.id, -- 2737
						taskId = result.taskId, -- 2738
						success = false, -- 2739
						message = result.message, -- 2740
						steps = result.steps -- 2741
					}) -- 2741
				end -- 2741
			end) -- 2741
		end -- 2686
	) -- 2686
	return {success = true, sessionId = session.id, taskId = taskId} -- 2745
end -- 2745
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2897
	local lines = {} -- 2898
	do -- 2898
		local i = 0 -- 2899
		while i < #questionnaire.schema.questions do -- 2899
			local question = questionnaire.schema.questions[i + 1] -- 2900
			local answer = __TS__ArrayFind( -- 2901
				answers, -- 2901
				function(____, item) return item.questionId == question.id end -- 2901
			) -- 2901
			local answerText = "已跳过" -- 2902
			if answer and answer.status == "answered" then -- 2902
				local parts = {} -- 2904
				do -- 2904
					local j = 0 -- 2905
					while j < #(answer.selectedOptionIds or ({})) do -- 2905
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2906
						local option = __TS__ArrayFind( -- 2907
							question.options or ({}), -- 2907
							function(____, item) return item.id == optionId end -- 2907
						) -- 2907
						if option then -- 2907
							parts[#parts + 1] = option.label -- 2908
						end -- 2908
						j = j + 1 -- 2905
					end -- 2905
				end -- 2905
				if answer.otherText then -- 2905
					parts[#parts + 1] = answer.otherText -- 2910
				end -- 2910
				if answer.text then -- 2910
					parts[#parts + 1] = answer.text -- 2911
				end -- 2911
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2912
			end -- 2912
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2914
			i = i + 1 -- 2899
		end -- 2899
	end -- 2899
	return table.concat(lines, "\n\n") -- 2916
end -- 2916
function ____exports.listRunningSubAgents(request) -- 3133
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3133
		local session = getSessionItem(request.sessionId) -- 3141
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3141
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3143
		end -- 3143
		if not session then -- 3143
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3143
		end -- 3143
		local rootSession = getRootSessionItem(session.id) -- 3148
		if not rootSession then -- 3148
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3148
		end -- 3148
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3152
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3153
		local limit = math.max( -- 3154
			1, -- 3154
			math.floor(tonumber(request.limit) or 5) -- 3154
		) -- 3154
		local offset = math.max( -- 3155
			0, -- 3155
			math.floor(tonumber(request.offset) or 0) -- 3155
		) -- 3155
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3156
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3157
		local runningSessions = {} -- 3164
		do -- 3164
			local i = 0 -- 3165
			while i < #rows do -- 3165
				do -- 3165
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3166
					if current.currentTaskStatus ~= "RUNNING" then -- 3166
						goto __continue502 -- 3168
					end -- 3168
					local spawnInfo = getSessionSpawnInfo(current) -- 3170
					runningSessions[#runningSessions + 1] = { -- 3171
						sessionId = current.id, -- 3172
						title = current.title, -- 3173
						parentSessionId = current.parentSessionId, -- 3174
						rootSessionId = current.rootSessionId, -- 3175
						status = "RUNNING", -- 3176
						currentTaskId = current.currentTaskId, -- 3177
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3178
						goal = spawnInfo and spawnInfo.goal, -- 3179
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3180
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3181
						createdAt = current.createdAt, -- 3182
						updatedAt = current.updatedAt -- 3183
					} -- 3183
				end -- 3183
				::__continue502:: -- 3183
				i = i + 1 -- 3165
			end -- 3165
		end -- 3165
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3186
		local completedSessions = __TS__ArrayMap( -- 3187
			completedRecords, -- 3187
			function(____, record) return { -- 3187
				sessionId = record.sessionId, -- 3188
				title = record.title, -- 3189
				parentSessionId = record.parentSessionId, -- 3190
				rootSessionId = record.rootSessionId, -- 3191
				status = record.status, -- 3192
				goal = record.goal, -- 3193
				expectedOutput = record.expectedOutput, -- 3194
				filesHint = record.filesHint, -- 3195
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3196
				success = record.success, -- 3197
				cleared = record.cleared, -- 3198
				resultFilePath = record.resultFilePath, -- 3199
				artifactDir = record.artifactDir, -- 3200
				finishedAt = record.finishedAt, -- 3201
				createdAt = record.createdAtTs, -- 3202
				updatedAt = record.finishedAtTs -- 3203
			} end -- 3203
		) -- 3203
		local merged = {} -- 3205
		if status == "running" then -- 3205
			merged = runningSessions -- 3207
		elseif status == "done" then -- 3207
			merged = __TS__ArrayFilter( -- 3209
				completedSessions, -- 3209
				function(____, item) return item.status == "DONE" end -- 3209
			) -- 3209
		elseif status == "failed" then -- 3209
			merged = __TS__ArrayFilter( -- 3211
				completedSessions, -- 3211
				function(____, item) return item.status == "FAILED" end -- 3211
			) -- 3211
		elseif status == "stopped" then -- 3211
			merged = __TS__ArrayFilter( -- 3213
				completedSessions, -- 3213
				function(____, item) return item.status == "STOPPED" end -- 3213
			) -- 3213
		elseif status == "all" then -- 3213
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3215
		else -- 3215
			local runningKeys = {} -- 3217
			do -- 3217
				local i = 0 -- 3218
				while i < #runningSessions do -- 3218
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3219
					i = i + 1 -- 3218
				end -- 3218
			end -- 3218
			local latestCompletedByKey = {} -- 3221
			do -- 3221
				local i = 0 -- 3222
				while i < #completedSessions do -- 3222
					do -- 3222
						local item = completedSessions[i + 1] -- 3223
						local key = getSubAgentDisplayKey(item) -- 3224
						if runningKeys[key] then -- 3224
							goto __continue517 -- 3226
						end -- 3226
						local current = latestCompletedByKey[key] -- 3228
						if not current or item.updatedAt > current.updatedAt then -- 3228
							latestCompletedByKey[key] = item -- 3230
						end -- 3230
					end -- 3230
					::__continue517:: -- 3230
					i = i + 1 -- 3222
				end -- 3222
			end -- 3222
			local latestCompleted = {} -- 3233
			for ____, item in pairs(latestCompletedByKey) do -- 3234
				latestCompleted[#latestCompleted + 1] = item -- 3235
			end -- 3235
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3237
		end -- 3237
		if query ~= "" then -- 3237
			merged = __TS__ArrayFilter( -- 3240
				merged, -- 3240
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3240
			) -- 3240
		end -- 3240
		__TS__ArraySort( -- 3246
			merged, -- 3246
			function(____, a, b) -- 3246
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3246
					return -1 -- 3247
				end -- 3247
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3247
					return 1 -- 3248
				end -- 3248
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3248
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3250
				end -- 3250
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3252
			end -- 3246
		) -- 3246
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3254
		return ____awaiter_resolve(nil, { -- 3254
			success = true, -- 3256
			rootSessionId = rootSession.id, -- 3257
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3258
			status = status, -- 3259
			limit = limit, -- 3260
			offset = offset, -- 3261
			hasMore = offset + limit < #merged, -- 3262
			sessions = paged -- 3263
		}) -- 3263
	end) -- 3263
end -- 3133
TABLE_SESSION = "AgentSession" -- 255
TABLE_MESSAGE = "AgentSessionMessage" -- 256
TABLE_STEP = "AgentSessionStep" -- 257
TABLE_TASK = "AgentTask" -- 258
local AGENT_SESSION_SCHEMA_VERSION = 2 -- 259
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 260
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 261
SPAWN_INFO_FILE = "SPAWN.json" -- 262
RESULT_FILE = "RESULT.md" -- 263
PENDING_HANDOFF_DIR = "pending-handoffs" -- 264
MAX_CONCURRENT_SUB_AGENTS = 4 -- 265
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 266
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 267
activeStopTokens = {} -- 317
finalizingSubSessionTaskIds = {} -- 318
now = function() return os.time() end -- 319
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 947
	if projectRoot == oldRoot then -- 947
		return newRoot -- 949
	end -- 949
	for ____, separator in ipairs({"/", "\\"}) do -- 951
		local prefix = oldRoot .. separator -- 952
		if __TS__StringStartsWith(projectRoot, prefix) then -- 952
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 954
		end -- 954
	end -- 954
	return nil -- 957
end -- 947
local function clearSessionAfterMessage(sessionId, message) -- 1467
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1468
	local removedStepIds = {} -- 1476
	do -- 1476
		local i = 0 -- 1477
		while i < #removedStepRows do -- 1477
			local row = removedStepRows[i + 1] -- 1478
			if type(row[1]) == "number" then -- 1478
				removedStepIds[#removedStepIds + 1] = row[1] -- 1480
			end -- 1480
			i = i + 1 -- 1477
		end -- 1477
	end -- 1477
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1483
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1491
	return removedStepIds -- 1496
end -- 1467
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1499
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1500
	local persisted = storage:readSessionState() -- 1501
	local userIndex = -1 -- 1502
	do -- 1502
		local i = #persisted.messages - 1 -- 1503
		while i >= 0 do -- 1503
			if persisted.messages[i + 1].role == "user" then -- 1503
				userIndex = i -- 1505
				break -- 1506
			end -- 1506
			i = i - 1 -- 1503
		end -- 1503
	end -- 1503
	if userIndex < 0 then -- 1503
		return -- 1509
	end -- 1509
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1510
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1511
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1512
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1517
end -- 1499
local function getAgentStepCount(sessionId, taskId) -- 1633
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1634
		sessionId, -- 1639
		taskId, -- 1640
		"compress_memory", -- 1641
		"merge_memory", -- 1642
		"sub_agent_handoff", -- 1643
		"questionnaire_answer", -- 1644
		"message" -- 1645
	}) -- 1645
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1648
end -- 1633
local function sanitizeStoredSteps(sessionId) -- 1698
	DB:exec( -- 1699
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1699
		{ -- 1717
			now(), -- 1717
			sessionId -- 1717
		} -- 1717
	) -- 1717
end -- 1698
local function getSchemaVersion() -- 2003
	local row = queryOne("PRAGMA user_version") -- 2004
	return row and type(row[1]) == "number" and row[1] or 0 -- 2005
end -- 2003
local function setSchemaVersion(version) -- 2008
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 2009
		0, -- 2009
		math.floor(version) -- 2009
	))) -- 2009
end -- 2008
local function hasTableColumn(tableName, columnName) -- 2012
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 2013
	do -- 2013
		local i = 0 -- 2014
		while i < #rows do -- 2014
			local row = rows[i + 1] -- 2015
			if toStr(row[2]) == columnName then -- 2015
				return true -- 2017
			end -- 2017
			i = i + 1 -- 2014
		end -- 2014
	end -- 2014
	return false -- 2020
end -- 2012
local function ensureSessionMetricsColumn() -- 2023
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 2023
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 2025
	end -- 2025
end -- 2023
local function ensureSessionWorkModeColumn() -- 2029
	if not hasTableColumn(TABLE_SESSION, "work_mode") then -- 2029
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN work_mode TEXT NOT NULL DEFAULT 'code';") -- 2031
	end -- 2031
end -- 2029
local function ensureMessageDisplayContentColumn() -- 2035
	if not hasTableColumn(TABLE_MESSAGE, "display_content") then -- 2035
		DB:exec(("ALTER TABLE " .. TABLE_MESSAGE) .. " ADD COLUMN display_content TEXT NOT NULL DEFAULT '';") -- 2037
	end -- 2037
end -- 2035
local function recreateSchema() -- 2041
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 2042
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 2043
	DB:exec("DROP TABLE IF EXISTS AgentQuestionnaire;") -- 2044
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 2045
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t\t);") -- 2046
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 2062
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 2063
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 2073
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 2074
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2091
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2092
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 2093
end -- 2041
do -- 2041
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 2041
		recreateSchema() -- 2099
	else -- 2099
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t\t);") -- 2101
		ensureSessionMetricsColumn() -- 2117
		ensureSessionWorkModeColumn() -- 2118
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 2119
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 2120
		ensureMessageDisplayContentColumn() -- 2130
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 2131
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 2132
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2149
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2150
	end -- 2150
	DB:exec("DROP TABLE IF EXISTS AgentQuestionnaire;") -- 2154
end -- 2154
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2297
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2297
		return {success = false, message = "invalid projectRoot"} -- 2299
	end -- 2299
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2301
	for ____, row in ipairs(rows) do -- 2302
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2303
		if sessionId > 0 then -- 2303
			deleteSessionRecords(sessionId) -- 2305
		end -- 2305
	end -- 2305
	return {success = true, deleted = #rows} -- 2308
end -- 2297
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2311
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2311
		return {success = false, message = "invalid projectRoot"} -- 2313
	end -- 2313
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2315
	local renamed = 0 -- 2316
	for ____, row in ipairs(rows) do -- 2317
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2318
		local projectRoot = toStr(row[2]) -- 2319
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2320
		if sessionId > 0 and nextProjectRoot then -- 2320
			DB:exec( -- 2322
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2322
				{ -- 2324
					nextProjectRoot, -- 2324
					Path:getFilename(nextProjectRoot), -- 2324
					now(), -- 2324
					sessionId -- 2324
				} -- 2324
			) -- 2324
			renamed = renamed + 1 -- 2326
		end -- 2326
	end -- 2326
	return {success = true, renamed = renamed} -- 2329
end -- 2311
function ____exports.getSession(sessionId) -- 2332
	local session = getSessionItem(sessionId) -- 2333
	if not session then -- 2333
		return {success = false, message = "session not found"} -- 2335
	end -- 2335
	local restored = restorePendingQuestionnaireState(session) -- 2337
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2338
	local relatedSessions = listRelatedSessions(sessionId) -- 2339
	sanitizeStoredSteps(sessionId) -- 2340
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2341
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2348
	local ____relatedSessions_57 = relatedSessions -- 2359
	local ____temp_56 -- 2360
	if normalizedSession.kind == "sub" then -- 2360
		____temp_56 = getSessionSpawnInfo(normalizedSession) -- 2360
	else -- 2360
		____temp_56 = nil -- 2360
	end -- 2360
	return { -- 2356
		success = true, -- 2357
		session = normalizedSession, -- 2358
		relatedSessions = ____relatedSessions_57, -- 2359
		spawnInfo = ____temp_56, -- 2360
		messages = __TS__ArrayMap( -- 2361
			messages, -- 2361
			function(____, row) return rowToMessage(row) end -- 2361
		), -- 2361
		steps = __TS__ArrayMap( -- 2362
			steps, -- 2362
			function(____, row) return rowToStep(row) end -- 2362
		), -- 2362
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}), -- 2363
		pendingQuestionnaire = restored.questionnaire, -- 2364
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2365
	} -- 2365
end -- 2332
function ____exports.setWorkMode(sessionId, workMode) -- 2370
	local session = getSessionItem(sessionId) -- 2371
	if not session then -- 2371
		return {success = false, message = "session not found"} -- 2372
	end -- 2372
	if session.kind ~= "main" then -- 2372
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2373
	end -- 2373
	if workMode ~= "code" and workMode ~= "plan" then -- 2373
		return {success = false, message = "invalid work mode"} -- 2374
	end -- 2374
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2375
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2375
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2377
	end -- 2377
	if getPendingQuestionnaire(sessionId) then -- 2377
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2380
	end -- 2380
	if normalizedSession.workMode ~= workMode then -- 2380
		DB:exec( -- 2383
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2383
			{ -- 2383
				workMode, -- 2383
				now(), -- 2383
				sessionId -- 2383
			} -- 2383
		) -- 2383
	end -- 2383
	local updated = getSessionItem(sessionId) -- 2385
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2386
	return { -- 2387
		success = true, -- 2387
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2387
	} -- 2387
end -- 2370
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2593
	local session = getSessionItem(sessionId) -- 2594
	if not session then -- 2594
		return {success = false, message = "session not found"} -- 2596
	end -- 2596
	if getPendingQuestionnaire(sessionId) then -- 2596
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2598
	end -- 2598
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2598
		return {success = false, message = "session task is finalizing"} -- 2600
	end -- 2600
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2600
		return {success = false, message = "session task is not continuable"} -- 2603
	end -- 2603
	return startPromptTask( -- 2605
		session, -- 2606
		"", -- 2607
		nil, -- 2608
		normalizeDisabledAgentTools(disabledAgentTools), -- 2609
		{workMode = session.workMode, persistUserMessage = false, resumeConversation = true, llmConfigId = llmConfigId} -- 2610
	) -- 2610
end -- 2593
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2748
	local session = getSessionItem(sessionId) -- 2749
	if not session then -- 2749
		return {success = false, message = "session not found"} -- 2751
	end -- 2751
	if session.kind ~= "sub" then -- 2751
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2754
	end -- 2754
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2754
		return {success = false, message = "session task is finalizing"} -- 2757
	end -- 2757
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2759
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2759
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2764
	end -- 2764
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2764
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2767
	end -- 2767
	local disabledAgentTools = __TS__ArrayFilter( -- 2769
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2769
		function(____, tool) return tool ~= "finish" end -- 2770
	) -- 2770
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2771
	return startPromptTask( -- 2774
		session, -- 2774
		prompt, -- 2774
		nil, -- 2774
		disabledAgentTools, -- 2774
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2774
	) -- 2774
end -- 2748
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2781
	local session = getSessionItem(sessionId) -- 2782
	if not session then -- 2782
		return {success = false, message = "session not found"} -- 2784
	end -- 2784
	if getPendingQuestionnaire(sessionId) then -- 2784
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2786
	end -- 2786
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2786
		return {success = false, message = "session task is finalizing"} -- 2788
	end -- 2788
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2788
		return {success = false, message = "session task is still running"} -- 2791
	end -- 2791
	local message = getMessageItem(messageId) -- 2793
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2793
		return {success = false, message = "message not found"} -- 2795
	end -- 2795
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2797
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2803
	if latestUserMessageId ~= messageId then -- 2803
		return {success = false, message = "only the latest user prompt can be edited"} -- 2805
	end -- 2805
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2807
	if normalizedPrompt == "" then -- 2807
		return {success = false, message = "prompt is empty"} -- 2809
	end -- 2809
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2811
	if session.workMode ~= nextWorkMode then -- 2811
		DB:exec( -- 2813
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2813
			{ -- 2813
				nextWorkMode, -- 2813
				now(), -- 2813
				session.id -- 2813
			} -- 2813
		) -- 2813
		session.workMode = nextWorkMode -- 2814
	end -- 2814
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2816
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2817
	local result = startPromptTask( -- 2818
		session, -- 2818
		normalizedPrompt, -- 2818
		messageId, -- 2818
		normalizeDisabledAgentTools(disabledAgentTools), -- 2818
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2818
	) -- 2818
	if result.success and #removedStepIds > 0 then -- 2818
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2820
	end -- 2820
	return result -- 2822
end -- 2781
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 2827
	if status == "dismissed" then -- 2827
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 2833
	end -- 2833
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2835
end -- 2827
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2838
	if status == "dismissed" then -- 2838
		return { -- 2844
			success = true, -- 2845
			status = "dismissed", -- 2846
			source = "user", -- 2847
			questionnaireId = questionnaire.id, -- 2848
			title = questionnaire.schema.title, -- 2849
			answers = {}, -- 2850
			responses = {}, -- 2851
			displayText = "用户关闭了调查问卷，未作答。", -- 2852
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 2853
		} -- 2853
	end -- 2853
	local responses = {} -- 2856
	do -- 2856
		local i = 0 -- 2857
		while i < #questionnaire.schema.questions do -- 2857
			do -- 2857
				local question = questionnaire.schema.questions[i + 1] -- 2858
				local answer = __TS__ArrayFind( -- 2859
					answers, -- 2859
					function(____, item) return item.questionId == question.id end -- 2859
				) -- 2859
				if not answer or answer.status == "skipped" then -- 2859
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 2861
					goto __continue437 -- 2866
				end -- 2866
				local selectedOptionLabels = {} -- 2868
				do -- 2868
					local j = 0 -- 2869
					while j < #(answer.selectedOptionIds or ({})) do -- 2869
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2870
						local option = __TS__ArrayFind( -- 2871
							question.options or ({}), -- 2871
							function(____, item) return item.id == optionId end -- 2871
						) -- 2871
						if option then -- 2871
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 2872
						end -- 2872
						j = j + 1 -- 2869
					end -- 2869
				end -- 2869
				responses[#responses + 1] = { -- 2874
					questionId = question.id, -- 2875
					prompt = question.prompt, -- 2876
					status = "answered", -- 2877
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 2878
					selectedOptionLabels = selectedOptionLabels, -- 2879
					otherText = answer.otherText, -- 2880
					text = answer.text -- 2881
				} -- 2881
			end -- 2881
			::__continue437:: -- 2881
			i = i + 1 -- 2857
		end -- 2857
	end -- 2857
	return { -- 2884
		success = true, -- 2885
		status = "answered", -- 2886
		source = "user", -- 2887
		questionnaireId = questionnaire.id, -- 2888
		title = questionnaire.schema.title, -- 2889
		answers = answers, -- 2890
		responses = responses, -- 2891
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 2892
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 2893
	} -- 2893
end -- 2838
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 2919
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 2925
	local persisted = storage:readSessionState() -- 2926
	local messages = __TS__ArraySlice(persisted.messages) -- 2927
	local toolResultIndex = -1 -- 2928
	local existingResult -- 2929
	do -- 2929
		local i = #messages - 1 -- 2930
		while i >= 0 do -- 2930
			do -- 2930
				local message = messages[i + 1] -- 2931
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 2931
					goto __continue457 -- 2932
				end -- 2932
				local decoded = safeJsonDecode(message.content) -- 2933
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 2933
					goto __continue457 -- 2934
				end -- 2934
				local row = decoded -- 2935
				if row.questionnaireId ~= questionnaire.id then -- 2935
					goto __continue457 -- 2936
				end -- 2936
				toolResultIndex = i -- 2937
				existingResult = row -- 2938
				break -- 2939
			end -- 2939
			::__continue457:: -- 2939
			i = i - 1 -- 2930
		end -- 2930
	end -- 2930
	if toolResultIndex < 0 then -- 2930
		return {success = false, message = "matching ask_user tool result not found"} -- 2942
	end -- 2942
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 2944
	local guidance = {} -- 2945
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 2945
		guidance[#guidance + 1] = existingResult.guidance -- 2947
	end -- 2947
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 2947
		guidance[#guidance + 1] = result.guidance -- 2950
	end -- 2950
	result.guidance = table.concat(guidance, "\n") -- 2952
	messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 2953
		{}, -- 2953
		messages[toolResultIndex + 1], -- 2954
		{content = encodeJson(result)} -- 2953
	) -- 2953
	local pairStartIndex = toolResultIndex -- 2958
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 2959
	if toolCallId and toolCallId ~= "" then -- 2959
		do -- 2959
			local i = toolResultIndex - 1 -- 2961
			while i >= 0 do -- 2961
				do -- 2961
					local message = messages[i + 1] -- 2962
					if message.role ~= "assistant" or not message.tool_calls then -- 2962
						goto __continue466 -- 2963
					end -- 2963
					if __TS__ArraySome( -- 2963
						message.tool_calls, -- 2964
						function(____, call) return call.id == toolCallId end -- 2964
					) then -- 2964
						pairStartIndex = i -- 2965
						break -- 2966
					end -- 2966
				end -- 2966
				::__continue466:: -- 2966
				i = i - 1 -- 2961
			end -- 2961
		end -- 2961
	end -- 2961
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 2970
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 2973
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 2977
	upsertStep( -- 2979
		session.id, -- 2979
		questionnaire.taskId, -- 2979
		questionnaire.step, -- 2979
		"ask_user", -- 2979
		{status = "DONE", result = result} -- 2979
	) -- 2979
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 2983
	upsertStep( -- 2984
		session.id, -- 2984
		questionnaire.taskId, -- 2984
		answerStep, -- 2984
		"questionnaire_answer", -- 2984
		{status = "DONE", result = result} -- 2984
	) -- 2984
	return {success = true, answerStep = answerStep, result = result} -- 2988
end -- 2919
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId) -- 2991
	local session = getSessionItem(sessionId) -- 2992
	if not session then -- 2992
		return {success = false, message = "session not found"} -- 2993
	end -- 2993
	if session.kind ~= "main" then -- 2993
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2994
	end -- 2994
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2995
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2995
		return {success = false, message = "pending questionnaire not found or already handled"} -- 2997
	end -- 2997
	local llmConfigRes = getLLMConfig(llmConfigId) -- 2999
	if not llmConfigRes.success then -- 2999
		return {success = false, message = llmConfigRes.message} -- 3000
	end -- 3000
	if not removePendingQuestionnaire(session) then -- 3000
		return {success = false, message = "failed to consume questionnaire file"} -- 3001
	end -- 3001
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3002
	if not replaced.success then -- 3002
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3004
		return replaced -- 3005
	end -- 3005
	local t = now() -- 3007
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3008
	session.workMode = "plan" -- 3009
	local result = startPromptTask( -- 3010
		session, -- 3010
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3010
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
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 3036
	local session = getSessionItem(sessionId) -- 3037
	if not session then -- 3037
		return {success = false, message = "session not found"} -- 3038
	end -- 3038
	if session.kind ~= "main" then -- 3038
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3039
	end -- 3039
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3040
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3040
		return {success = false, message = "pending questionnaire not found"} -- 3041
	end -- 3041
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3042
	if not validated.success then -- 3042
		return validated -- 3043
	end -- 3043
	local llmConfigRes = getLLMConfig(llmConfigId) -- 3044
	if not llmConfigRes.success then -- 3044
		return {success = false, message = llmConfigRes.message} -- 3045
	end -- 3045
	local t = now() -- 3046
	if not removePendingQuestionnaire(session) then -- 3046
		return {success = false, message = "failed to consume questionnaire file"} -- 3047
	end -- 3047
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3048
	if not replaced.success then -- 3048
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3050
		return replaced -- 3051
	end -- 3051
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3053
	session.workMode = "plan" -- 3054
	local result = startPromptTask( -- 3055
		session, -- 3055
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3055
		nil, -- 3055
		{}, -- 3055
		{ -- 3055
			workMode = "plan", -- 3056
			persistUserMessage = false, -- 3057
			resumeConversation = true, -- 3058
			existingTaskId = questionnaire.taskId, -- 3059
			initialStep = replaced.answerStep, -- 3060
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3061
			llmConfig = llmConfigRes.config -- 3062
		} -- 3062
	) -- 3062
	if not result.success then -- 3062
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3065
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3066
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3067
		emitAgentSessionPatch( -- 3068
			session.id, -- 3068
			{ -- 3068
				session = getSessionItem(session.id), -- 3069
				pendingQuestionnaire = questionnaire -- 3070
			} -- 3070
		) -- 3070
		return result -- 3072
	end -- 3072
	emitAgentSessionPatch( -- 3074
		sessionId, -- 3074
		{ -- 3074
			session = getSessionItem(sessionId), -- 3075
			pendingQuestionnaire = false -- 3076
		} -- 3076
	) -- 3076
	return result -- 3078
end -- 3036
function ____exports.stopSessionTask(sessionId) -- 3081
	local session = getSessionItem(sessionId) -- 3082
	if not session or session.currentTaskId == nil then -- 3082
		return {success = false, message = "session task not found"} -- 3084
	end -- 3084
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3084
		return {success = false, message = "session task is finalizing"} -- 3087
	end -- 3087
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3089
	local stopToken = activeStopTokens[session.currentTaskId] -- 3090
	if not stopToken then -- 3090
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3090
			return {success = true, recovered = true} -- 3093
		end -- 3093
		return {success = false, message = "task is not running"} -- 3095
	end -- 3095
	stopToken.stopped = true -- 3097
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3098
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 3102
	finalizeTaskSteps(session.id, session.currentTaskId, nil, "STOPPED") -- 3103
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 3104
	return {success = true} -- 3105
end -- 3081
function ____exports.getCurrentTaskId(sessionId) -- 3108
	local ____opt_118 = getSessionItem(sessionId) -- 3108
	return ____opt_118 and ____opt_118.currentTaskId -- 3109
end -- 3108
function ____exports.listRunningSessions() -- 3112
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3113
	local sessions = {} -- 3120
	do -- 3120
		local i = 0 -- 3121
		while i < #rows do -- 3121
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3122
			if session.currentTaskStatus == "RUNNING" then -- 3122
				sessions[#sessions + 1] = session -- 3124
			end -- 3124
			i = i + 1 -- 3121
		end -- 3121
	end -- 3121
	return {success = true, sessions = sessions} -- 3127
end -- 3112
return ____exports -- 3112