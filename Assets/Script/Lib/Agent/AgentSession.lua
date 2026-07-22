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
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local getDefaultUseChineseResponse, toStr, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, queryRows, queryOne, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, getLastInsertRowId, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeStoppedTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, TABLE_SESSION, TABLE_MESSAGE, TABLE_STEP, TABLE_TASK, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, finalizingSubSessionTaskIds, now -- 1
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
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1399
	if taskId == nil or taskId <= 0 then -- 1399
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1401
		return -- 1402
	end -- 1402
	local row = getSessionRow(sessionId) -- 1404
	if not row then -- 1404
		return -- 1405
	end -- 1405
	local session = rowToSession(row) -- 1406
	if session.currentTaskId ~= taskId then -- 1406
		Log( -- 1408
			"Info", -- 1408
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1408
		) -- 1408
		return -- 1409
	end -- 1409
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1411
end -- 1411
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1414
	local t = now() -- 1415
	DB:exec( -- 1416
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1416
		{ -- 1419
			sessionId, -- 1420
			taskId or 0, -- 1421
			role, -- 1422
			sanitizeUTF8(content), -- 1423
			displayContent and sanitizeUTF8(displayContent) or "", -- 1424
			t, -- 1425
			t -- 1426
		} -- 1426
	) -- 1426
	return getLastInsertRowId() -- 1429
end -- 1429
function updateMessage(messageId, content) -- 1432
	DB:exec( -- 1433
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1433
		{ -- 1435
			sanitizeUTF8(content), -- 1435
			now(), -- 1435
			messageId -- 1435
		} -- 1435
	) -- 1435
end -- 1435
function updateUserMessageForTask(messageId, content, taskId) -- 1439
	DB:exec( -- 1440
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1440
		{ -- 1444
			sanitizeUTF8(content), -- 1444
			taskId, -- 1444
			now(), -- 1444
			messageId -- 1444
		} -- 1444
	) -- 1444
end -- 1444
function removeStoppedTaskSummary(session) -- 1501
	local taskId = session.currentTaskId -- 1502
	if taskId == nil then -- 1502
		return -- 1503
	end -- 1503
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1504
end -- 1504
function upsertAssistantMessage(sessionId, taskId, content) -- 1510
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1511
	if row and type(row[1]) == "number" then -- 1511
		updateMessage(row[1], content) -- 1518
		return row[1] -- 1519
	end -- 1519
	return insertMessage(sessionId, "assistant", content, taskId) -- 1521
end -- 1521
function upsertStep(sessionId, taskId, step, tool, patch) -- 1524
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1534
	local reason = sanitizeUTF8(patch.reason or "") -- 1538
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1539
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1540
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1541
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1542
	local statusPatch = patch.status or "" -- 1543
	local status = patch.status or "PENDING" -- 1544
	if not row then -- 1544
		local t = now() -- 1546
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1547
			sessionId, -- 1551
			taskId, -- 1552
			step, -- 1553
			tool, -- 1554
			status, -- 1555
			reason, -- 1556
			reasoningContent, -- 1557
			paramsJson, -- 1558
			resultJson, -- 1559
			patch.checkpointId or 0, -- 1560
			patch.checkpointSeq or 0, -- 1561
			filesJson, -- 1562
			t, -- 1563
			t -- 1564
		}) -- 1564
		return -- 1567
	end -- 1567
	DB:exec( -- 1569
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1569
		{ -- 1581
			tool, -- 1582
			statusPatch, -- 1583
			status, -- 1584
			reason, -- 1585
			reason, -- 1586
			reasoningContent, -- 1587
			reasoningContent, -- 1588
			paramsJson, -- 1589
			paramsJson, -- 1590
			resultJson, -- 1591
			resultJson, -- 1592
			patch.checkpointId or 0, -- 1593
			patch.checkpointId or 0, -- 1594
			patch.checkpointSeq or 0, -- 1595
			patch.checkpointSeq or 0, -- 1596
			filesJson, -- 1597
			filesJson, -- 1598
			now(), -- 1599
			row[1] -- 1600
		} -- 1600
	) -- 1600
end -- 1600
function getNextStepNumber(sessionId, taskId) -- 1605
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1606
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1610
	return math.max(0, current) + 1 -- 1611
end -- 1611
function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1614
	if status == nil then -- 1614
		status = "DONE" -- 1622
	end -- 1622
	local step = getNextStepNumber(sessionId, taskId) -- 1624
	upsertStep( -- 1625
		sessionId, -- 1625
		taskId, -- 1625
		step, -- 1625
		tool, -- 1625
		{status = status, reason = reason, params = params, result = result} -- 1625
	) -- 1625
	return getStepItem(sessionId, taskId, step) -- 1631
end -- 1631
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1634
	if taskId <= 0 then -- 1634
		return -- 1635
	end -- 1635
	if finalSteps ~= nil and finalSteps >= 0 then -- 1635
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1637
	end -- 1637
	if not finalStatus then -- 1637
		return -- 1643
	end -- 1643
	if finalSteps ~= nil and finalSteps >= 0 then -- 1643
		DB:exec( -- 1645
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1645
			{ -- 1649
				finalStatus, -- 1649
				now(), -- 1649
				sessionId, -- 1649
				taskId, -- 1649
				finalSteps -- 1649
			} -- 1649
		) -- 1649
		return -- 1651
	end -- 1651
	DB:exec( -- 1653
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1653
		{ -- 1657
			finalStatus, -- 1657
			now(), -- 1657
			sessionId, -- 1657
			taskId -- 1657
		} -- 1657
	) -- 1657
end -- 1657
function emitAgentSessionPatch(sessionId, patch) -- 1684
	if HttpServer.wsConnectionCount == 0 then -- 1684
		return -- 1686
	end -- 1686
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1688
	if not text then -- 1688
		return -- 1693
	end -- 1693
	emit("AppWS", "Send", text) -- 1694
end -- 1694
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 1697
	emitAgentSessionPatch( -- 1698
		sessionId, -- 1698
		{ -- 1698
			sessionDeleted = true, -- 1699
			relatedSessions = listRelatedSessions(rootSessionId) -- 1700
		} -- 1700
	) -- 1700
	local rootSession = getSessionItem(rootSessionId) -- 1702
	if rootSession then -- 1702
		emitAgentSessionPatch( -- 1704
			rootSessionId, -- 1704
			{ -- 1704
				session = rootSession, -- 1705
				relatedSessions = listRelatedSessions(rootSessionId) -- 1706
			} -- 1706
		) -- 1706
	end -- 1706
end -- 1706
function flushPendingSubAgentHandoffs(rootSession) -- 1711
	if rootSession.kind ~= "main" then -- 1711
		return -- 1712
	end -- 1712
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 1712
		return -- 1714
	end -- 1714
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 1716
	if #items == 0 then -- 1716
		return -- 1717
	end -- 1717
	local handoffTaskId = 0 -- 1718
	local ____rootSession_currentTaskId_34 -- 1719
	if rootSession.currentTaskId then -- 1719
		____rootSession_currentTaskId_34 = getTaskPrompt(rootSession.currentTaskId) -- 1719
	else -- 1719
		____rootSession_currentTaskId_34 = nil -- 1719
	end -- 1719
	local currentTaskPrompt = ____rootSession_currentTaskId_34 -- 1719
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 1719
		handoffTaskId = rootSession.currentTaskId -- 1727
	else -- 1727
		local taskRes = Tools.createTask( -- 1729
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 1729
			"code" -- 1729
		) -- 1729
		if not taskRes.success then -- 1729
			Log( -- 1731
				"Warn", -- 1731
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 1731
			) -- 1731
			return -- 1732
		end -- 1732
		handoffTaskId = taskRes.taskId -- 1734
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 1735
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 1736
		emitAgentSessionPatch( -- 1737
			rootSession.id, -- 1737
			{session = getSessionItem(rootSession.id)} -- 1737
		) -- 1737
	end -- 1737
	do -- 1737
		local i = 0 -- 1741
		while i < #items do -- 1741
			local item = items[i + 1] -- 1742
			local step = appendSystemStep( -- 1743
				rootSession.id, -- 1744
				handoffTaskId, -- 1745
				"sub_agent_handoff", -- 1746
				"sub_agent_handoff", -- 1747
				item.message, -- 1748
				{ -- 1749
					sourceSessionId = item.sourceSessionId, -- 1750
					sourceTitle = item.sourceTitle, -- 1751
					sourceTaskId = item.sourceTaskId, -- 1752
					success = item.success == true, -- 1753
					summary = item.message, -- 1754
					resultFilePath = item.resultFilePath or "", -- 1755
					artifactDir = item.artifactDir or "", -- 1756
					finishedAt = item.finishedAt or "", -- 1757
					changeSet = item.changeSet, -- 1758
					handoffEvidence = item.handoffEvidence, -- 1759
					memoryEntry = item.memoryEntry, -- 1760
					completion = item.completion -- 1761
				}, -- 1761
				{ -- 1763
					sourceSessionId = item.sourceSessionId, -- 1764
					sourceTitle = item.sourceTitle, -- 1765
					sourceTaskId = item.sourceTaskId, -- 1766
					prompt = item.prompt, -- 1767
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 1768
					expectedOutput = item.expectedOutput or "", -- 1769
					filesHint = item.filesHint or ({}), -- 1770
					resultFilePath = item.resultFilePath or "", -- 1771
					artifactDir = item.artifactDir or "", -- 1772
					changeSet = item.changeSet, -- 1773
					handoffEvidence = item.handoffEvidence, -- 1774
					memoryEntry = item.memoryEntry, -- 1775
					completion = item.completion -- 1776
				}, -- 1776
				"DONE" -- 1778
			) -- 1778
			if step then -- 1778
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 1781
			end -- 1781
			deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 1783
			i = i + 1 -- 1741
		end -- 1741
	end -- 1741
end -- 1741
function applyEvent(sessionId, event) -- 1795
	repeat -- 1795
		local ____switch302 = event.type -- 1795
		local metrics, startedSession -- 1795
		local ____cond302 = ____switch302 == "task_started" -- 1795
		if ____cond302 then -- 1795
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 1798
			metrics = clearSessionTokenUsage(sessionId) -- 1799
			startedSession = getSessionItem(sessionId) -- 1800
			emitAgentSessionPatch( -- 1801
				sessionId, -- 1801
				{ -- 1801
					session = startedSession, -- 1802
					metrics = metrics, -- 1803
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 1804
				} -- 1804
			) -- 1804
			break -- 1808
		end -- 1808
		____cond302 = ____cond302 or ____switch302 == "decision_made" -- 1808
		if ____cond302 then -- 1808
			upsertStep( -- 1810
				sessionId, -- 1810
				event.taskId, -- 1810
				event.step, -- 1810
				event.tool, -- 1810
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 1810
			) -- 1810
			emitAgentSessionPatch( -- 1818
				sessionId, -- 1818
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1818
			) -- 1818
			break -- 1821
		end -- 1821
		____cond302 = ____cond302 or ____switch302 == "tool_started" -- 1821
		if ____cond302 then -- 1821
			upsertStep( -- 1823
				sessionId, -- 1823
				event.taskId, -- 1823
				event.step, -- 1823
				event.tool, -- 1823
				{status = "RUNNING"} -- 1823
			) -- 1823
			emitAgentSessionPatch( -- 1826
				sessionId, -- 1826
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1826
			) -- 1826
			break -- 1829
		end -- 1829
		____cond302 = ____cond302 or ____switch302 == "tool_finished" -- 1829
		if ____cond302 then -- 1829
			do -- 1829
				local ____temp_37 = event.result.success ~= true -- 1831
				if ____temp_37 then -- 1831
					local ____opt_35 = activeStopTokens[event.taskId] -- 1831
					____temp_37 = (____opt_35 and ____opt_35.stopped) == true -- 1831
				end -- 1831
				local stopped = ____temp_37 -- 1831
				upsertStep( -- 1833
					sessionId, -- 1833
					event.taskId, -- 1833
					event.step, -- 1833
					event.tool, -- 1833
					{status = stopped and "STOPPED" or "DONE", reason = event.reason, result = event.result} -- 1833
				) -- 1833
				emitAgentSessionPatch( -- 1841
					sessionId, -- 1841
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1841
				) -- 1841
				break -- 1844
			end -- 1844
		end -- 1844
		____cond302 = ____cond302 or ____switch302 == "tool_progress" -- 1844
		if ____cond302 then -- 1844
			do -- 1844
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 1848
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 1848
					break -- 1850
				end -- 1850
			end -- 1850
			upsertStep( -- 1853
				sessionId, -- 1853
				event.taskId, -- 1853
				event.step, -- 1853
				event.tool, -- 1853
				{status = "RUNNING", result = event.result} -- 1853
			) -- 1853
			emitAgentSessionPatch( -- 1857
				sessionId, -- 1857
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1857
			) -- 1857
			break -- 1860
		end -- 1860
		____cond302 = ____cond302 or ____switch302 == "checkpoint_created" -- 1860
		if ____cond302 then -- 1860
			upsertStep( -- 1862
				sessionId, -- 1862
				event.taskId, -- 1862
				event.step, -- 1862
				event.tool, -- 1862
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 1862
			) -- 1862
			emitAgentSessionPatch( -- 1867
				sessionId, -- 1867
				{ -- 1867
					step = getStepItem(sessionId, event.taskId, event.step), -- 1868
					checkpoints = Tools.listCheckpoints(event.taskId) -- 1869
				} -- 1869
			) -- 1869
			break -- 1871
		end -- 1871
		____cond302 = ____cond302 or ____switch302 == "memory_compression_started" -- 1871
		if ____cond302 then -- 1871
			upsertStep( -- 1873
				sessionId, -- 1873
				event.taskId, -- 1873
				event.step, -- 1873
				event.tool, -- 1873
				{status = "RUNNING", reason = event.reason, params = event.params} -- 1873
			) -- 1873
			emitAgentSessionPatch( -- 1878
				sessionId, -- 1878
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1878
			) -- 1878
			break -- 1881
		end -- 1881
		____cond302 = ____cond302 or ____switch302 == "memory_compression_finished" -- 1881
		if ____cond302 then -- 1881
			upsertStep( -- 1883
				sessionId, -- 1883
				event.taskId, -- 1883
				event.step, -- 1883
				event.tool, -- 1883
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 1883
			) -- 1883
			emitAgentSessionPatch( -- 1888
				sessionId, -- 1888
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 1888
			) -- 1888
			break -- 1891
		end -- 1891
		____cond302 = ____cond302 or ____switch302 == "metrics_updated" -- 1891
		if ____cond302 then -- 1891
			do -- 1891
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 1893
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 1894
				break -- 1897
			end -- 1897
		end -- 1897
		____cond302 = ____cond302 or ____switch302 == "assistant_message_updated" -- 1897
		if ____cond302 then -- 1897
			do -- 1897
				upsertStep( -- 1900
					sessionId, -- 1900
					event.taskId, -- 1900
					event.step, -- 1900
					"message", -- 1900
					{status = "RUNNING", reason = event.content, reasoningContent = event.reasoningContent} -- 1900
				) -- 1900
				emitAgentSessionPatch( -- 1905
					sessionId, -- 1905
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 1905
				) -- 1905
				break -- 1908
			end -- 1908
		end -- 1908
		____cond302 = ____cond302 or ____switch302 == "task_waiting_for_user" -- 1908
		if ____cond302 then -- 1908
			do -- 1908
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 1911
				__TS__Delete(activeStopTokens, event.taskId) -- 1912
				emitAgentSessionPatch( -- 1913
					sessionId, -- 1913
					{ -- 1913
						session = getSessionItem(sessionId), -- 1914
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 1915
					} -- 1915
				) -- 1915
				break -- 1917
			end -- 1917
		end -- 1917
		____cond302 = ____cond302 or ____switch302 == "task_finished" -- 1917
		if ____cond302 then -- 1917
			do -- 1917
				local session = getSessionItem(sessionId) -- 1920
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 1920
					__TS__Delete(activeStopTokens, event.taskId) -- 1922
					Log( -- 1923
						"Info", -- 1923
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1923
					) -- 1923
					break -- 1924
				end -- 1924
				local ____opt_38 = activeStopTokens[event.taskId or -1] -- 1924
				local stopped = (____opt_38 and ____opt_38.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 1926
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 1928
				local isSubSession = (session and session.kind) == "sub" -- 1931
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 1932
				if isSubSession and event.taskId ~= nil then -- 1932
					finalizingSubSessionTaskIds[event.taskId] = true -- 1934
				end -- 1934
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 1936
				if event.taskId ~= nil then -- 1936
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 1938
					local ____finalizeTaskSteps_44 = finalizeTaskSteps -- 1939
					local ____array_43 = __TS__SparseArrayNew( -- 1939
						sessionId, -- 1940
						event.taskId, -- 1941
						type(event.steps) == "number" and math.max( -- 1942
							0, -- 1942
							math.floor(event.steps) -- 1942
						) or nil -- 1942
					) -- 1942
					local ____event_success_42 -- 1943
					if event.success then -- 1943
						____event_success_42 = nil -- 1943
					else -- 1943
						____event_success_42 = stopped and "STOPPED" or "FAILED" -- 1943
					end -- 1943
					__TS__SparseArrayPush(____array_43, ____event_success_42) -- 1943
					____finalizeTaskSteps_44(__TS__SparseArraySpread(____array_43)) -- 1939
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 1945
					if not isSubSession then -- 1945
						__TS__Delete(activeStopTokens, event.taskId) -- 1947
					end -- 1947
					emitAgentSessionPatch( -- 1949
						sessionId, -- 1949
						{ -- 1949
							session = getSessionItem(sessionId), -- 1950
							message = getMessageItem(messageId), -- 1951
							checkpoints = Tools.listCheckpoints(event.taskId), -- 1952
							removedStepIds = removedStepIds -- 1953
						} -- 1953
					) -- 1953
				end -- 1953
				if session and session.kind == "main" then -- 1953
					flushPendingSubAgentHandoffs(session) -- 1957
				end -- 1957
				break -- 1959
			end -- 1959
		end -- 1959
	until true -- 1959
end -- 1959
function ____exports.createSession(projectRoot, title) -- 2118
	if title == nil then -- 2118
		title = "" -- 2118
	end -- 2118
	if not isValidProjectRoot(projectRoot) then -- 2118
		return {success = false, message = "invalid projectRoot"} -- 2120
	end -- 2120
	local row = queryOne(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2122
	if row then -- 2122
		return { -- 2131
			success = true, -- 2131
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2131
		} -- 2131
	end -- 2131
	local t = now() -- 2133
	DB:exec( -- 2134
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?)", -- 2134
		{ -- 2137
			projectRoot, -- 2137
			title ~= "" and title or Path:getFilename(projectRoot), -- 2137
			t, -- 2137
			t -- 2137
		} -- 2137
	) -- 2137
	local sessionId = getLastInsertRowId() -- 2139
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2140
	local session = getSessionItem(sessionId) -- 2141
	if not session then -- 2141
		return {success = false, message = "failed to create session"} -- 2143
	end -- 2143
	return {success = true, session = session} -- 2145
end -- 2118
function ____exports.createSubSession(parentSessionId, title) -- 2148
	if title == nil then -- 2148
		title = "" -- 2148
	end -- 2148
	local parent = getSessionItem(parentSessionId) -- 2149
	if not parent then -- 2149
		return {success = false, message = "parent session not found"} -- 2151
	end -- 2151
	local rootId = getSessionRootId(parent) -- 2153
	local t = now() -- 2154
	DB:exec( -- 2155
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2155
		{ -- 2158
			parent.projectRoot, -- 2158
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2158
			rootId, -- 2158
			parent.id, -- 2158
			t, -- 2158
			t -- 2158
		} -- 2158
	) -- 2158
	local sessionId = getLastInsertRowId() -- 2160
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2161
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2162
	local session = getSessionItem(sessionId) -- 2163
	if not session then -- 2163
		return {success = false, message = "failed to create sub session"} -- 2165
	end -- 2165
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2167
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2168
	subStorage:writeMemory(parentStorage:readMemory()) -- 2169
	return {success = true, session = session} -- 2170
end -- 2148
function spawnSubAgentSession(request) -- 2173
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2173
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2186
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2187
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2188
		if normalizedPrompt == "" then -- 2188
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2190
		end -- 2190
		if normalizedPrompt == "" then -- 2190
			local ____Log_50 = Log -- 2197
			local ____temp_47 = #normalizedTitle -- 2197
			local ____temp_48 = #rawPrompt -- 2197
			local ____temp_49 = #toStr(request.expectedOutput) -- 2197
			local ____opt_45 = request.filesHint -- 2197
			____Log_50( -- 2197
				"Warn", -- 2197
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_47)) .. " raw_prompt_len=") .. tostring(____temp_48)) .. " expected_len=") .. tostring(____temp_49)) .. " files_hint_count=") .. tostring(____opt_45 and #____opt_45 or 0) -- 2197
			) -- 2197
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2197
		end -- 2197
		Log( -- 2200
			"Info", -- 2200
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2200
		) -- 2200
		local parentSessionId = request.parentSessionId -- 2201
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2201
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2203
			if not fallbackParent then -- 2203
				local createdMain = ____exports.createSession(request.projectRoot) -- 2205
				if createdMain.success then -- 2205
					fallbackParent = createdMain.session -- 2207
				end -- 2207
			end -- 2207
			if fallbackParent then -- 2207
				Log( -- 2211
					"Warn", -- 2211
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2211
				) -- 2211
				parentSessionId = fallbackParent.id -- 2212
			end -- 2212
		end -- 2212
		local parentSession = getSessionItem(parentSessionId) -- 2215
		if not parentSession then -- 2215
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2215
		end -- 2215
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2219
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2219
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2219
		end -- 2219
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2223
		if not created.success then -- 2223
			return ____awaiter_resolve(nil, created) -- 2223
		end -- 2223
		writeSpawnInfo( -- 2227
			created.session.projectRoot, -- 2227
			created.session.memoryScope, -- 2227
			{ -- 2227
				sessionId = created.session.id, -- 2228
				rootSessionId = created.session.rootSessionId, -- 2229
				parentSessionId = created.session.parentSessionId, -- 2230
				title = created.session.title, -- 2231
				prompt = normalizedPrompt, -- 2232
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2233
				expectedOutput = request.expectedOutput or "", -- 2234
				filesHint = request.filesHint or ({}), -- 2235
				status = "RUNNING", -- 2236
				success = false, -- 2237
				resultFilePath = "", -- 2238
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2239
				sourceTaskId = 0, -- 2240
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2241
				createdAtTs = created.session.createdAt, -- 2242
				finishedAt = "", -- 2243
				finishedAtTs = 0 -- 2244
			} -- 2244
		) -- 2244
		local sent = ____exports.sendPrompt( -- 2246
			created.session.id, -- 2246
			normalizedPrompt, -- 2246
			true, -- 2246
			request.disabledAgentTools, -- 2246
			nil, -- 2246
			nil, -- 2246
			request.llmConfig -- 2246
		) -- 2246
		if not sent.success then -- 2246
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2246
		end -- 2246
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2246
	end) -- 2246
end -- 2246
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2351
	local rootSession = getRootSessionItem(session.id) -- 2352
	if not rootSession then -- 2352
		return -- 2353
	end -- 2353
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2354
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2355
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2356
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2357
	local queueResult = writePendingHandoff( -- 2358
		rootSession.projectRoot, -- 2358
		rootSession.memoryScope, -- 2358
		{ -- 2358
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2359
			sourceSessionId = session.id, -- 2360
			sourceTitle = session.title, -- 2361
			sourceTaskId = taskId, -- 2362
			message = summary, -- 2363
			prompt = result.prompt, -- 2364
			goal = result.goal, -- 2365
			expectedOutput = result.expectedOutput or "", -- 2366
			filesHint = result.filesHint or ({}), -- 2367
			success = result.success, -- 2368
			resultFilePath = result.resultFilePath, -- 2369
			artifactDir = result.artifactDir, -- 2370
			finishedAt = result.finishedAt, -- 2371
			changeSet = changeSet, -- 2372
			handoffEvidence = result.handoffEvidence, -- 2373
			memoryEntry = result.memoryEntry, -- 2374
			completion = result.completion, -- 2375
			createdAt = createdAt -- 2376
		} -- 2376
	) -- 2376
	if not queueResult then -- 2376
		Log( -- 2379
			"Warn", -- 2379
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2379
		) -- 2379
		return -- 2380
	end -- 2380
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2380
		flushPendingSubAgentHandoffs(rootSession) -- 2383
	end -- 2383
end -- 2383
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2387
	if forceHandoff == nil then -- 2387
		forceHandoff = false -- 2393
	end -- 2393
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2393
		local rootSessionId = getSessionRootId(session) -- 2395
		local rootSession = getRootSessionItem(session.id) -- 2396
		if not rootSession then -- 2396
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2396
		end -- 2396
		local spawnInfo = getSessionSpawnInfo(session) -- 2400
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2401
		local finishedAtTs = now() -- 2402
		local resultText = sanitizeUTF8(message) -- 2403
		local changeSet = getTaskChangeSetSummary(taskId) -- 2404
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2405
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2406
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2410
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2410
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2412
		end -- 2412
		local completed = success and completionReport.outcome == "completed" -- 2420
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2421
		local record = { -- 2424
			sessionId = session.id, -- 2425
			rootSessionId = rootSessionId, -- 2426
			parentSessionId = session.parentSessionId, -- 2427
			title = session.title, -- 2428
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2429
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2430
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2431
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2432
			status = recordStatus, -- 2433
			success = completed, -- 2434
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2435
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2436
			sourceTaskId = taskId, -- 2437
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2438
			finishedAt = finishedAt, -- 2439
			createdAtTs = session.createdAt, -- 2440
			finishedAtTs = finishedAtTs, -- 2441
			changeSet = changeSet, -- 2442
			handoffEvidence = handoffEvidence, -- 2443
			completion = completionReport -- 2444
		} -- 2444
		local ____record_success_63 -- 2446
		if record.success then -- 2446
			____record_success_63 = buildStructuredSubAgentMemoryEntry(record) -- 2446
		else -- 2446
			____record_success_63 = nil -- 2446
		end -- 2446
		record.memoryEntry = ____record_success_63 -- 2446
		if not writeSubAgentResultFile(session, record, resultText) then -- 2446
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2446
		end -- 2446
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2446
			sessionId = record.sessionId, -- 2451
			rootSessionId = record.rootSessionId, -- 2452
			parentSessionId = record.parentSessionId, -- 2453
			title = record.title, -- 2454
			prompt = record.prompt, -- 2455
			goal = record.goal, -- 2456
			expectedOutput = record.expectedOutput or "", -- 2457
			filesHint = record.filesHint or ({}), -- 2458
			status = record.status, -- 2459
			success = record.success, -- 2460
			resultFilePath = record.resultFilePath, -- 2461
			artifactDir = record.artifactDir, -- 2462
			sourceTaskId = record.sourceTaskId, -- 2463
			createdAt = record.createdAt, -- 2464
			finishedAt = record.finishedAt, -- 2465
			createdAtTs = record.createdAtTs, -- 2466
			finishedAtTs = record.finishedAtTs, -- 2467
			changeSet = record.changeSet, -- 2468
			handoffEvidence = record.handoffEvidence, -- 2469
			memoryEntry = record.memoryEntry, -- 2470
			memoryEntryError = record.memoryEntryError, -- 2471
			completion = record.completion -- 2472
		}) then -- 2472
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2472
		end -- 2472
		if success or forceHandoff then -- 2472
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2477
			deleteSessionRecords(session.id, true) -- 2478
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2479
		end -- 2479
		return ____awaiter_resolve(nil, {success = true}) -- 2479
	end) -- 2479
end -- 2479
function stopClearedSubSession(session, taskId) -- 2484
	local spawnInfo = getSessionSpawnInfo(session) -- 2485
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2486
	local rootSessionId = getSessionRootId(session) -- 2487
	Tools.setTaskStatus(taskId, "STOPPED") -- 2488
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2489
	if not writeSpawnInfo( -- 2489
		session.projectRoot, -- 2490
		session.memoryScope, -- 2490
		{ -- 2490
			sessionId = session.id, -- 2491
			rootSessionId = rootSessionId, -- 2492
			parentSessionId = session.parentSessionId, -- 2493
			title = session.title, -- 2494
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2495
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2496
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2497
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2498
			status = "STOPPED", -- 2499
			success = false, -- 2500
			cleared = true, -- 2501
			resultFilePath = "", -- 2502
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2503
			sourceTaskId = taskId, -- 2504
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2505
			finishedAt = finishedAt, -- 2506
			createdAtTs = session.createdAt, -- 2507
			finishedAtTs = now() -- 2508
		} -- 2508
	) then -- 2508
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2510
	end -- 2510
	deleteSessionRecords(session.id, true) -- 2512
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2513
	return {success = true} -- 2514
end -- 2514
function ____exports.sendPrompt(sessionId, prompt, allowSubSessionStart, disabledAgentTools, workMode, llmConfigId, llmConfig) -- 2517
	if allowSubSessionStart == nil then -- 2517
		allowSubSessionStart = false -- 2517
	end -- 2517
	local session = getSessionItem(sessionId) -- 2518
	if not session then -- 2518
		return {success = false, message = "session not found"} -- 2520
	end -- 2520
	if getPendingQuestionnaire(sessionId) then -- 2520
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2522
	end -- 2522
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2522
		return {success = false, message = "session task is finalizing"} -- 2524
	end -- 2524
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2524
		return {success = false, message = "session task is still running"} -- 2527
	end -- 2527
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2529
	if normalizedPrompt == "" and session.kind == "sub" then -- 2529
		local spawnInfo = getSessionSpawnInfo(session) -- 2531
		if spawnInfo then -- 2531
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2533
			if normalizedPrompt == "" then -- 2533
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2535
			end -- 2535
		end -- 2535
	end -- 2535
	if normalizedPrompt == "" then -- 2535
		return {success = false, message = "prompt is empty"} -- 2544
	end -- 2544
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2546
	if session.workMode ~= nextWorkMode then -- 2546
		DB:exec( -- 2548
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2548
			{ -- 2548
				nextWorkMode, -- 2548
				now(), -- 2548
				session.id -- 2548
			} -- 2548
		) -- 2548
		session.workMode = nextWorkMode -- 2549
	end -- 2549
	return startPromptTask( -- 2551
		session, -- 2551
		normalizedPrompt, -- 2551
		nil, -- 2551
		normalizeDisabledAgentTools(disabledAgentTools), -- 2551
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig} -- 2551
	) -- 2551
end -- 2517
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2586
	if disabledAgentTools == nil then -- 2586
		disabledAgentTools = {} -- 2590
	end -- 2590
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2593
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2594
	if not llmConfigRes.success then -- 2594
		return {success = false, message = llmConfigRes.message} -- 2598
	end -- 2598
	local llmConfig = llmConfigRes.config -- 2600
	local taskRes = Tools.createTask(normalizedPrompt, taskWorkMode) -- 2601
	if not taskRes.success then -- 2601
		return {success = false, message = taskRes.message} -- 2603
	end -- 2603
	if session.currentTaskStatus == "STOPPED" then -- 2603
		removeStoppedTaskSummary(session) -- 2606
	end -- 2606
	local taskId = taskRes.taskId -- 2608
	local useChineseResponse = getDefaultUseChineseResponse() -- 2609
	if existingUserMessageId ~= nil then -- 2609
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2611
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2611
		insertMessage( -- 2613
			session.id, -- 2613
			"user", -- 2613
			normalizedPrompt, -- 2613
			taskId, -- 2613
			options and options.displayContent -- 2613
		) -- 2613
	end -- 2613
	local stopToken = {stopped = false} -- 2615
	activeStopTokens[taskId] = stopToken -- 2616
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2617
	runCodingAgent( -- 2618
		{ -- 2618
			prompt = normalizedPrompt, -- 2619
			resumeConversation = options and options.resumeConversation, -- 2620
			workDir = session.projectRoot, -- 2621
			useChineseResponse = useChineseResponse, -- 2622
			taskId = taskId, -- 2623
			sessionId = session.id, -- 2624
			memoryScope = session.memoryScope, -- 2625
			role = session.kind, -- 2626
			maxSteps = options and options.maxSteps, -- 2627
			disabledAgentTools = disabledAgentTools, -- 2628
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2629
			llmConfig = llmConfig, -- 2630
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2631
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2634
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2637
			stopToken = stopToken, -- 2638
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2639
		}, -- 2639
		function(result) -- 2640
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2640
				local nextSession = getSessionItem(session.id) -- 2641
				if nextSession and nextSession.kind == "sub" then -- 2641
					if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 2641
						local stopped = stopClearedSubSession(nextSession, taskId) -- 2644
						if not stopped.success then -- 2644
							Log( -- 2646
								"Warn", -- 2646
								(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 2646
							) -- 2646
							emitAgentSessionPatch( -- 2647
								session.id, -- 2647
								{session = getSessionItem(session.id)} -- 2647
							) -- 2647
						end -- 2647
						__TS__Delete(activeStopTokens, taskId) -- 2651
						return ____awaiter_resolve(nil) -- 2651
					end -- 2651
					setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2654
					emitAgentSessionPatch( -- 2655
						session.id, -- 2655
						{session = getSessionItem(session.id)} -- 2655
					) -- 2655
					local finalized = __TS__Await(finalizeSubSession( -- 2658
						nextSession, -- 2659
						taskId, -- 2660
						result.success, -- 2661
						result.message, -- 2662
						result.completion, -- 2663
						(options and options.forceSubAgentHandoff) == true -- 2664
					)) -- 2664
					if not finalized.success then -- 2664
						Log( -- 2667
							"Warn", -- 2667
							(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 2667
						) -- 2667
					end -- 2667
					local finalizedSession = getSessionItem(session.id) -- 2669
					if finalizedSession then -- 2669
						local stopped = stopToken.stopped == true -- 2671
						local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2672
						setSessionState(session.id, finalStatus, taskId, finalStatus) -- 2675
						emitAgentSessionPatch( -- 2676
							session.id, -- 2676
							{session = getSessionItem(session.id)} -- 2676
						) -- 2676
					end -- 2676
					__TS__Delete(activeStopTokens, taskId) -- 2680
					__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 2681
				end -- 2681
				local fallbackSession = getSessionItem(session.id) -- 2683
				if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 2683
					applyEvent(session.id, { -- 2689
						type = "task_finished", -- 2690
						sessionId = session.id, -- 2691
						taskId = result.taskId, -- 2692
						success = false, -- 2693
						message = result.message, -- 2694
						steps = result.steps -- 2695
					}) -- 2695
				end -- 2695
			end) -- 2695
		end -- 2640
	) -- 2640
	return {success = true, sessionId = session.id, taskId = taskId} -- 2699
end -- 2699
function ____exports.listRunningSubAgents(request) -- 2932
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2932
		local session = getSessionItem(request.sessionId) -- 2940
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 2940
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2942
		end -- 2942
		if not session then -- 2942
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 2942
		end -- 2942
		local rootSession = getRootSessionItem(session.id) -- 2947
		if not rootSession then -- 2947
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2947
		end -- 2947
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 2951
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 2952
		local limit = math.max( -- 2953
			1, -- 2953
			math.floor(tonumber(request.limit) or 5) -- 2953
		) -- 2953
		local offset = math.max( -- 2954
			0, -- 2954
			math.floor(tonumber(request.offset) or 0) -- 2954
		) -- 2954
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 2955
		local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 2956
		local runningSessions = {} -- 2963
		do -- 2963
			local i = 0 -- 2964
			while i < #rows do -- 2964
				do -- 2964
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2965
					if current.currentTaskStatus ~= "RUNNING" then -- 2965
						goto __continue472 -- 2967
					end -- 2967
					local spawnInfo = getSessionSpawnInfo(current) -- 2969
					runningSessions[#runningSessions + 1] = { -- 2970
						sessionId = current.id, -- 2971
						title = current.title, -- 2972
						parentSessionId = current.parentSessionId, -- 2973
						rootSessionId = current.rootSessionId, -- 2974
						status = "RUNNING", -- 2975
						currentTaskId = current.currentTaskId, -- 2976
						currentTaskStatus = current.currentTaskStatus or current.status, -- 2977
						goal = spawnInfo and spawnInfo.goal, -- 2978
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 2979
						filesHint = spawnInfo and spawnInfo.filesHint, -- 2980
						createdAt = current.createdAt, -- 2981
						updatedAt = current.updatedAt -- 2982
					} -- 2982
				end -- 2982
				::__continue472:: -- 2982
				i = i + 1 -- 2964
			end -- 2964
		end -- 2964
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 2985
		local completedSessions = __TS__ArrayMap( -- 2986
			completedRecords, -- 2986
			function(____, record) return { -- 2986
				sessionId = record.sessionId, -- 2987
				title = record.title, -- 2988
				parentSessionId = record.parentSessionId, -- 2989
				rootSessionId = record.rootSessionId, -- 2990
				status = record.status, -- 2991
				goal = record.goal, -- 2992
				expectedOutput = record.expectedOutput, -- 2993
				filesHint = record.filesHint, -- 2994
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 2995
				success = record.success, -- 2996
				cleared = record.cleared, -- 2997
				resultFilePath = record.resultFilePath, -- 2998
				artifactDir = record.artifactDir, -- 2999
				finishedAt = record.finishedAt, -- 3000
				createdAt = record.createdAtTs, -- 3001
				updatedAt = record.finishedAtTs -- 3002
			} end -- 3002
		) -- 3002
		local merged = {} -- 3004
		if status == "running" then -- 3004
			merged = runningSessions -- 3006
		elseif status == "done" then -- 3006
			merged = __TS__ArrayFilter( -- 3008
				completedSessions, -- 3008
				function(____, item) return item.status == "DONE" end -- 3008
			) -- 3008
		elseif status == "failed" then -- 3008
			merged = __TS__ArrayFilter( -- 3010
				completedSessions, -- 3010
				function(____, item) return item.status == "FAILED" end -- 3010
			) -- 3010
		elseif status == "stopped" then -- 3010
			merged = __TS__ArrayFilter( -- 3012
				completedSessions, -- 3012
				function(____, item) return item.status == "STOPPED" end -- 3012
			) -- 3012
		elseif status == "all" then -- 3012
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3014
		else -- 3014
			local runningKeys = {} -- 3016
			do -- 3016
				local i = 0 -- 3017
				while i < #runningSessions do -- 3017
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3018
					i = i + 1 -- 3017
				end -- 3017
			end -- 3017
			local latestCompletedByKey = {} -- 3020
			do -- 3020
				local i = 0 -- 3021
				while i < #completedSessions do -- 3021
					do -- 3021
						local item = completedSessions[i + 1] -- 3022
						local key = getSubAgentDisplayKey(item) -- 3023
						if runningKeys[key] then -- 3023
							goto __continue487 -- 3025
						end -- 3025
						local current = latestCompletedByKey[key] -- 3027
						if not current or item.updatedAt > current.updatedAt then -- 3027
							latestCompletedByKey[key] = item -- 3029
						end -- 3029
					end -- 3029
					::__continue487:: -- 3029
					i = i + 1 -- 3021
				end -- 3021
			end -- 3021
			local latestCompleted = {} -- 3032
			for ____, item in pairs(latestCompletedByKey) do -- 3033
				latestCompleted[#latestCompleted + 1] = item -- 3034
			end -- 3034
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3036
		end -- 3036
		if query ~= "" then -- 3036
			merged = __TS__ArrayFilter( -- 3039
				merged, -- 3039
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3039
			) -- 3039
		end -- 3039
		__TS__ArraySort( -- 3045
			merged, -- 3045
			function(____, a, b) -- 3045
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3045
					return -1 -- 3046
				end -- 3046
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3046
					return 1 -- 3047
				end -- 3047
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3047
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3049
				end -- 3049
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3051
			end -- 3045
		) -- 3045
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3053
		return ____awaiter_resolve(nil, { -- 3053
			success = true, -- 3055
			rootSessionId = rootSession.id, -- 3056
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3057
			status = status, -- 3058
			limit = limit, -- 3059
			offset = offset, -- 3060
			hasMore = offset + limit < #merged, -- 3061
			sessions = paged -- 3062
		}) -- 3062
	end) -- 3062
end -- 2932
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
local function clearSessionAfterMessage(sessionId, message) -- 1448
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1449
	local removedStepIds = {} -- 1457
	do -- 1457
		local i = 0 -- 1458
		while i < #removedStepRows do -- 1458
			local row = removedStepRows[i + 1] -- 1459
			if type(row[1]) == "number" then -- 1459
				removedStepIds[#removedStepIds + 1] = row[1] -- 1461
			end -- 1461
			i = i + 1 -- 1458
		end -- 1458
	end -- 1458
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1464
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1472
	return removedStepIds -- 1477
end -- 1448
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1480
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1481
	local persisted = storage:readSessionState() -- 1482
	local userIndex = -1 -- 1483
	do -- 1483
		local i = #persisted.messages - 1 -- 1484
		while i >= 0 do -- 1484
			if persisted.messages[i + 1].role == "user" then -- 1484
				userIndex = i -- 1486
				break -- 1487
			end -- 1487
			i = i - 1 -- 1484
		end -- 1484
	end -- 1484
	if userIndex < 0 then -- 1484
		return -- 1490
	end -- 1490
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1491
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1492
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1493
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1498
end -- 1480
local function sanitizeStoredSteps(sessionId) -- 1661
	DB:exec( -- 1662
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1662
		{ -- 1680
			now(), -- 1680
			sessionId -- 1680
		} -- 1680
	) -- 1680
end -- 1661
local function getSchemaVersion() -- 1964
	local row = queryOne("PRAGMA user_version") -- 1965
	return row and type(row[1]) == "number" and row[1] or 0 -- 1966
end -- 1964
local function setSchemaVersion(version) -- 1969
	DB:exec("PRAGMA user_version = " .. tostring(math.max( -- 1970
		0, -- 1970
		math.floor(version) -- 1970
	))) -- 1970
end -- 1969
local function hasTableColumn(tableName, columnName) -- 1973
	local rows = queryRows(("PRAGMA table_info(" .. tableName) .. ")") or ({}) -- 1974
	do -- 1974
		local i = 0 -- 1975
		while i < #rows do -- 1975
			local row = rows[i + 1] -- 1976
			if toStr(row[2]) == columnName then -- 1976
				return true -- 1978
			end -- 1978
			i = i + 1 -- 1975
		end -- 1975
	end -- 1975
	return false -- 1981
end -- 1973
local function ensureSessionMetricsColumn() -- 1984
	if not hasTableColumn(TABLE_SESSION, "metrics_json") then -- 1984
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN metrics_json TEXT NOT NULL DEFAULT '';") -- 1986
	end -- 1986
end -- 1984
local function ensureSessionWorkModeColumn() -- 1990
	if not hasTableColumn(TABLE_SESSION, "work_mode") then -- 1990
		DB:exec(("ALTER TABLE " .. TABLE_SESSION) .. " ADD COLUMN work_mode TEXT NOT NULL DEFAULT 'code';") -- 1992
	end -- 1992
end -- 1990
local function ensureMessageDisplayContentColumn() -- 1996
	if not hasTableColumn(TABLE_MESSAGE, "display_content") then -- 1996
		DB:exec(("ALTER TABLE " .. TABLE_MESSAGE) .. " ADD COLUMN display_content TEXT NOT NULL DEFAULT '';") -- 1998
	end -- 1998
end -- 1996
local function recreateSchema() -- 2002
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_STEP) .. ";") -- 2003
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_MESSAGE) .. ";") -- 2004
	DB:exec("DROP TABLE IF EXISTS AgentQuestionnaire;") -- 2005
	DB:exec(("DROP TABLE IF EXISTS " .. TABLE_SESSION) .. ";") -- 2006
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tproject_root TEXT NOT NULL,\n\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\tparent_session_id INTEGER,\n\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t\t);") -- 2007
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 2023
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER,\n\t\trole TEXT NOT NULL,\n\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 2024
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 2034
	DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\tsession_id INTEGER NOT NULL,\n\t\ttask_id INTEGER NOT NULL,\n\t\tstep INTEGER NOT NULL,\n\t\ttool TEXT NOT NULL DEFAULT '',\n\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\treason TEXT NOT NULL DEFAULT '',\n\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\tcheckpoint_id INTEGER,\n\t\tcheckpoint_seq INTEGER,\n\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\tcreated_at INTEGER NOT NULL,\n\t\tupdated_at INTEGER NOT NULL\n\t);") -- 2035
	DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2052
	DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2053
	setSchemaVersion(AGENT_SESSION_SCHEMA_VERSION) -- 2054
end -- 2002
do -- 2002
	if getSchemaVersion() ~= AGENT_SESSION_SCHEMA_VERSION then -- 2002
		recreateSchema() -- 2060
	else -- 2060
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_SESSION) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tproject_root TEXT NOT NULL,\n\t\t\ttitle TEXT NOT NULL DEFAULT '',\n\t\t\tkind TEXT NOT NULL DEFAULT 'main',\n\t\t\troot_session_id INTEGER NOT NULL DEFAULT 0,\n\t\t\tparent_session_id INTEGER,\n\t\t\tmemory_scope TEXT NOT NULL DEFAULT 'main',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcurrent_task_id INTEGER,\n\t\t\tcurrent_task_status TEXT NOT NULL DEFAULT 'IDLE',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL,\n\t\t\tmetrics_json TEXT NOT NULL DEFAULT '',\n\t\t\twork_mode TEXT NOT NULL DEFAULT 'code'\n\t\t);") -- 2062
		ensureSessionMetricsColumn() -- 2078
		ensureSessionWorkModeColumn() -- 2079
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_project_root ON " .. TABLE_SESSION) .. "(project_root, updated_at DESC);") -- 2080
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_MESSAGE) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER,\n\t\t\trole TEXT NOT NULL,\n\t\t\tcontent TEXT NOT NULL DEFAULT '',\n\t\t\tdisplay_content TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 2081
		ensureMessageDisplayContentColumn() -- 2091
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_message_sid_id ON " .. TABLE_MESSAGE) .. "(session_id, id);") -- 2092
		DB:exec(("CREATE TABLE IF NOT EXISTS " .. TABLE_STEP) .. "(\n\t\t\tid INTEGER PRIMARY KEY AUTOINCREMENT,\n\t\t\tsession_id INTEGER NOT NULL,\n\t\t\ttask_id INTEGER NOT NULL,\n\t\t\tstep INTEGER NOT NULL,\n\t\t\ttool TEXT NOT NULL DEFAULT '',\n\t\t\tstatus TEXT NOT NULL DEFAULT 'PENDING',\n\t\t\treason TEXT NOT NULL DEFAULT '',\n\t\t\treasoning_content TEXT NOT NULL DEFAULT '',\n\t\t\tparams_json TEXT NOT NULL DEFAULT '',\n\t\t\tresult_json TEXT NOT NULL DEFAULT '',\n\t\t\tcheckpoint_id INTEGER,\n\t\t\tcheckpoint_seq INTEGER,\n\t\t\tfiles_json TEXT NOT NULL DEFAULT '',\n\t\t\tcreated_at INTEGER NOT NULL,\n\t\t\tupdated_at INTEGER NOT NULL\n\t\t);") -- 2093
		DB:exec(("CREATE UNIQUE INDEX IF NOT EXISTS idx_agent_session_step_unique ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2110
		DB:exec(("CREATE INDEX IF NOT EXISTS idx_agent_session_step_sid_task_step ON " .. TABLE_STEP) .. "(session_id, task_id, step);") -- 2111
	end -- 2111
	DB:exec("DROP TABLE IF EXISTS AgentQuestionnaire;") -- 2115
end -- 2115
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2258
	if not projectRoot or not Content:isAbsolutePath(projectRoot) then -- 2258
		return {success = false, message = "invalid projectRoot"} -- 2260
	end -- 2260
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2262
	for ____, row in ipairs(rows) do -- 2263
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2264
		if sessionId > 0 then -- 2264
			deleteSessionRecords(sessionId) -- 2266
		end -- 2266
	end -- 2266
	return {success = true, deleted = #rows} -- 2269
end -- 2258
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2272
	if not oldRoot or not newRoot or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2272
		return {success = false, message = "invalid projectRoot"} -- 2274
	end -- 2274
	local rows = queryRows("SELECT id, project_root FROM " .. TABLE_SESSION) or ({}) -- 2276
	local renamed = 0 -- 2277
	for ____, row in ipairs(rows) do -- 2278
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2279
		local projectRoot = toStr(row[2]) -- 2280
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2281
		if sessionId > 0 and nextProjectRoot then -- 2281
			DB:exec( -- 2283
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2283
				{ -- 2285
					nextProjectRoot, -- 2285
					Path:getFilename(nextProjectRoot), -- 2285
					now(), -- 2285
					sessionId -- 2285
				} -- 2285
			) -- 2285
			renamed = renamed + 1 -- 2287
		end -- 2287
	end -- 2287
	return {success = true, renamed = renamed} -- 2290
end -- 2272
function ____exports.getSession(sessionId) -- 2293
	local session = getSessionItem(sessionId) -- 2294
	if not session then -- 2294
		return {success = false, message = "session not found"} -- 2296
	end -- 2296
	local restored = restorePendingQuestionnaireState(session) -- 2298
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2299
	local relatedSessions = listRelatedSessions(sessionId) -- 2300
	sanitizeStoredSteps(sessionId) -- 2301
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ?\n\t\tORDER BY id ASC", {sessionId}) or ({}) -- 2302
	local steps = queryRows(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", {sessionId}) or ({}) -- 2309
	local ____relatedSessions_52 = relatedSessions -- 2320
	local ____temp_51 -- 2321
	if normalizedSession.kind == "sub" then -- 2321
		____temp_51 = getSessionSpawnInfo(normalizedSession) -- 2321
	else -- 2321
		____temp_51 = nil -- 2321
	end -- 2321
	return { -- 2317
		success = true, -- 2318
		session = normalizedSession, -- 2319
		relatedSessions = ____relatedSessions_52, -- 2320
		spawnInfo = ____temp_51, -- 2321
		messages = __TS__ArrayMap( -- 2322
			messages, -- 2322
			function(____, row) return rowToMessage(row) end -- 2322
		), -- 2322
		steps = __TS__ArrayMap( -- 2323
			steps, -- 2323
			function(____, row) return rowToStep(row) end -- 2323
		), -- 2323
		checkpoints = normalizedSession.currentTaskId and Tools.listCheckpoints(normalizedSession.currentTaskId) or ({}), -- 2324
		pendingQuestionnaire = restored.questionnaire, -- 2325
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2326
	} -- 2326
end -- 2293
function ____exports.setWorkMode(sessionId, workMode) -- 2331
	local session = getSessionItem(sessionId) -- 2332
	if not session then -- 2332
		return {success = false, message = "session not found"} -- 2333
	end -- 2333
	if session.kind ~= "main" then -- 2333
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2334
	end -- 2334
	if workMode ~= "code" and workMode ~= "plan" then -- 2334
		return {success = false, message = "invalid work mode"} -- 2335
	end -- 2335
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2336
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2336
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2338
	end -- 2338
	if getPendingQuestionnaire(sessionId) then -- 2338
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2341
	end -- 2341
	if normalizedSession.workMode ~= workMode then -- 2341
		DB:exec( -- 2344
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2344
			{ -- 2344
				workMode, -- 2344
				now(), -- 2344
				sessionId -- 2344
			} -- 2344
		) -- 2344
	end -- 2344
	local updated = getSessionItem(sessionId) -- 2346
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2347
	return { -- 2348
		success = true, -- 2348
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2348
	} -- 2348
end -- 2331
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2554
	local session = getSessionItem(sessionId) -- 2555
	if not session then -- 2555
		return {success = false, message = "session not found"} -- 2557
	end -- 2557
	if getPendingQuestionnaire(sessionId) then -- 2557
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2559
	end -- 2559
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2559
		return {success = false, message = "session task is finalizing"} -- 2561
	end -- 2561
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2561
		return {success = false, message = "session task is not continuable"} -- 2564
	end -- 2564
	return startPromptTask( -- 2566
		session, -- 2567
		"", -- 2568
		nil, -- 2569
		normalizeDisabledAgentTools(disabledAgentTools), -- 2570
		{workMode = session.workMode, persistUserMessage = false, resumeConversation = true, llmConfigId = llmConfigId} -- 2571
	) -- 2571
end -- 2554
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 2702
	local session = getSessionItem(sessionId) -- 2703
	if not session then -- 2703
		return {success = false, message = "session not found"} -- 2705
	end -- 2705
	if session.kind ~= "sub" then -- 2705
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 2708
	end -- 2708
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2708
		return {success = false, message = "session task is finalizing"} -- 2711
	end -- 2711
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2713
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2713
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 2718
	end -- 2718
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 2718
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 2721
	end -- 2721
	local disabledAgentTools = __TS__ArrayFilter( -- 2723
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 2723
		function(____, tool) return tool ~= "finish" end -- 2724
	) -- 2724
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 2725
	return startPromptTask( -- 2728
		session, -- 2728
		prompt, -- 2728
		nil, -- 2728
		disabledAgentTools, -- 2728
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 2728
	) -- 2728
end -- 2702
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 2735
	local session = getSessionItem(sessionId) -- 2736
	if not session then -- 2736
		return {success = false, message = "session not found"} -- 2738
	end -- 2738
	if getPendingQuestionnaire(sessionId) then -- 2738
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 2740
	end -- 2740
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2740
		return {success = false, message = "session task is finalizing"} -- 2742
	end -- 2742
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2742
		return {success = false, message = "session task is still running"} -- 2745
	end -- 2745
	local message = getMessageItem(messageId) -- 2747
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 2747
		return {success = false, message = "message not found"} -- 2749
	end -- 2749
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"}) -- 2751
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 2757
	if latestUserMessageId ~= messageId then -- 2757
		return {success = false, message = "only the latest user prompt can be edited"} -- 2759
	end -- 2759
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2761
	if normalizedPrompt == "" then -- 2761
		return {success = false, message = "prompt is empty"} -- 2763
	end -- 2763
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2765
	if session.workMode ~= nextWorkMode then -- 2765
		DB:exec( -- 2767
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2767
			{ -- 2767
				nextWorkMode, -- 2767
				now(), -- 2767
				session.id -- 2767
			} -- 2767
		) -- 2767
		session.workMode = nextWorkMode -- 2768
	end -- 2768
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 2770
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 2771
	local result = startPromptTask( -- 2772
		session, -- 2772
		normalizedPrompt, -- 2772
		messageId, -- 2772
		normalizeDisabledAgentTools(disabledAgentTools), -- 2772
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 2772
	) -- 2772
	if result.success and #removedStepIds > 0 then -- 2772
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 2774
	end -- 2774
	return result -- 2776
end -- 2735
local function buildQuestionnaireFeedbackPrompt(questionnaire, answers) -- 2779
	local lines = {"用户已完成 Plan 模式调查问卷。请把反馈合并到固定的 .agent/plan/PLAN.md 与 .agent/plan/PROGRESS.md，继续细化方案；如仍有必要，可再次使用 ask_user。", "", "问卷：" .. questionnaire.schema.title} -- 2780
	do -- 2780
		local i = 0 -- 2785
		while i < #questionnaire.schema.questions do -- 2785
			do -- 2785
				local question = questionnaire.schema.questions[i + 1] -- 2786
				local answer = __TS__ArrayFind( -- 2787
					answers, -- 2787
					function(____, item) return item.questionId == question.id end -- 2787
				) -- 2787
				if not answer or answer.status == "skipped" then -- 2787
					lines[#lines + 1] = ("- " .. question.prompt) .. "\n  状态：已跳过" -- 2789
					goto __continue431 -- 2790
				end -- 2790
				local ____array_94 = __TS__SparseArrayNew(table.unpack(answer.selectedOptionIds or ({}))) -- 2790
				__TS__SparseArrayPush( -- 2790
					____array_94, -- 2790
					table.unpack(answer.otherText and ({answer.otherText}) or ({})) -- 2794
				) -- 2794
				__TS__SparseArrayPush( -- 2794
					____array_94, -- 2794
					table.unpack(answer.text and ({answer.text}) or ({})) -- 2795
				) -- 2795
				local parts = {__TS__SparseArraySpread(____array_94)} -- 2792
				lines[#lines + 1] = (("- " .. question.prompt) .. "\n  回答：") .. table.concat(parts, ", ") -- 2797
			end -- 2797
			::__continue431:: -- 2797
			i = i + 1 -- 2785
		end -- 2785
	end -- 2785
	__TS__ArrayPush( -- 2799
		lines, -- 2799
		"", -- 2799
		"<questionnaire_answers>", -- 2799
		encodeJson({questionnaireId = questionnaire.id, answers = answers}), -- 2799
		"</questionnaire_answers>" -- 2799
	) -- 2799
	return table.concat(lines, "\n") -- 2800
end -- 2779
local function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 2803
	local lines = {} -- 2804
	do -- 2804
		local i = 0 -- 2805
		while i < #questionnaire.schema.questions do -- 2805
			local question = questionnaire.schema.questions[i + 1] -- 2806
			local answer = __TS__ArrayFind( -- 2807
				answers, -- 2807
				function(____, item) return item.questionId == question.id end -- 2807
			) -- 2807
			local answerText = "已跳过" -- 2808
			if answer and answer.status == "answered" then -- 2808
				local parts = {} -- 2810
				do -- 2810
					local j = 0 -- 2811
					while j < #(answer.selectedOptionIds or ({})) do -- 2811
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 2812
						local option = __TS__ArrayFind( -- 2813
							question.options or ({}), -- 2813
							function(____, item) return item.id == optionId end -- 2813
						) -- 2813
						if option then -- 2813
							parts[#parts + 1] = option.label -- 2814
						end -- 2814
						j = j + 1 -- 2811
					end -- 2811
				end -- 2811
				if answer.otherText then -- 2811
					parts[#parts + 1] = answer.otherText -- 2816
				end -- 2816
				if answer.text then -- 2816
					parts[#parts + 1] = answer.text -- 2817
				end -- 2817
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 2818
			end -- 2818
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 2820
			i = i + 1 -- 2805
		end -- 2805
	end -- 2805
	return table.concat(lines, "\n\n") -- 2822
end -- 2803
function ____exports.cancelQuestionnaire(sessionId, questionnaireId) -- 2825
	local session = getSessionItem(sessionId) -- 2826
	if not session then -- 2826
		return {success = false, message = "session not found"} -- 2827
	end -- 2827
	if session.kind ~= "main" then -- 2827
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2828
	end -- 2828
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2829
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2829
		return {success = false, message = "pending questionnaire not found or already handled"} -- 2831
	end -- 2831
	if not removePendingQuestionnaire(session) then -- 2831
		return {success = false, message = "failed to remove questionnaire file"} -- 2833
	end -- 2833
	Tools.setTaskStatus(questionnaire.taskId, "STOPPED") -- 2834
	finalizeTaskSteps(session.id, questionnaire.taskId, nil, "STOPPED") -- 2835
	setSessionState(session.id, "STOPPED", questionnaire.taskId, "STOPPED") -- 2836
	local updated = getSessionItem(session.id) -- 2837
	emitAgentSessionPatch(session.id, {session = updated, pendingQuestionnaire = false}) -- 2838
	return {success = true, session = updated} -- 2842
end -- 2825
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId) -- 2845
	local session = getSessionItem(sessionId) -- 2846
	if not session then -- 2846
		return {success = false, message = "session not found"} -- 2847
	end -- 2847
	if session.kind ~= "main" then -- 2847
		return {success = false, message = "questionnaires are only available for main sessions"} -- 2848
	end -- 2848
	local questionnaire = getPendingQuestionnaire(sessionId) -- 2849
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 2849
		return {success = false, message = "pending questionnaire not found"} -- 2850
	end -- 2850
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 2851
	if not validated.success then -- 2851
		return validated -- 2852
	end -- 2852
	local t = now() -- 2853
	if not removePendingQuestionnaire(session) then -- 2853
		return {success = false, message = "failed to consume questionnaire file"} -- 2854
	end -- 2854
	Tools.setTaskStatus(questionnaire.taskId, "DONE") -- 2855
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 2856
	session.workMode = "plan" -- 2857
	local result = startPromptTask( -- 2858
		session, -- 2858
		buildQuestionnaireFeedbackPrompt(questionnaire, validated.answers), -- 2858
		nil, -- 2858
		{}, -- 2858
		{ -- 2858
			workMode = "plan", -- 2859
			displayContent = buildQuestionnaireFeedbackDisplay(questionnaire, validated.answers), -- 2860
			llmConfigId = llmConfigId -- 2861
		} -- 2861
	) -- 2861
	if not result.success then -- 2861
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 2864
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 2865
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 2866
		emitAgentSessionPatch( -- 2867
			session.id, -- 2867
			{ -- 2867
				session = getSessionItem(session.id), -- 2868
				pendingQuestionnaire = questionnaire -- 2869
			} -- 2869
		) -- 2869
		return result -- 2871
	end -- 2871
	emitAgentSessionPatch( -- 2873
		sessionId, -- 2873
		{ -- 2873
			session = getSessionItem(sessionId), -- 2874
			pendingQuestionnaire = false -- 2875
		} -- 2875
	) -- 2875
	return result -- 2877
end -- 2845
function ____exports.stopSessionTask(sessionId) -- 2880
	local session = getSessionItem(sessionId) -- 2881
	if not session or session.currentTaskId == nil then -- 2881
		return {success = false, message = "session task not found"} -- 2883
	end -- 2883
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2883
		return {success = false, message = "session task is finalizing"} -- 2886
	end -- 2886
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2888
	local stopToken = activeStopTokens[session.currentTaskId] -- 2889
	if not stopToken then -- 2889
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 2889
			return {success = true, recovered = true} -- 2892
		end -- 2892
		return {success = false, message = "task is not running"} -- 2894
	end -- 2894
	stopToken.stopped = true -- 2896
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 2897
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 2901
	finalizeTaskSteps(session.id, session.currentTaskId, nil, "STOPPED") -- 2902
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 2903
	return {success = true} -- 2904
end -- 2880
function ____exports.getCurrentTaskId(sessionId) -- 2907
	local ____opt_95 = getSessionItem(sessionId) -- 2907
	return ____opt_95 and ____opt_95.currentTaskId -- 2908
end -- 2907
function ____exports.listRunningSessions() -- 2911
	local rows = queryRows(("SELECT id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode\n\t\tFROM " .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 2912
	local sessions = {} -- 2919
	do -- 2919
		local i = 0 -- 2920
		while i < #rows do -- 2920
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 2921
			if session.currentTaskStatus == "RUNNING" then -- 2921
				sessions[#sessions + 1] = session -- 2923
			end -- 2923
			i = i + 1 -- 2920
		end -- 2920
	end -- 2920
	return {success = true, sessions = sessions} -- 2926
end -- 2911
return ____exports -- 2911