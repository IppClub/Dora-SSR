-- [ts]: Session.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__New = ____lualib.__TS__New -- 1
local __TS__ArrayFind = ____lualib.__TS__ArrayFind -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySome = ____lualib.__TS__ArraySome -- 1
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
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local scheduleStreamFlush, getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startImmediatePrompt, startLocalPrompt, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, followup, activeLocalAgentControls, finalizingSubSessionTaskIds, activePromptRuns, streamUpdates, streamFlushScheduled, SESSION_SELECT_COLUMNS, now -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Content = ____Dora.Content -- 2
local DB = ____Dora.DB -- 2
local Director = ____Dora.Director -- 2
local Path = ____Dora.Path -- 2
local HttpServer = ____Dora.HttpServer -- 2
local emit = ____Dora.emit -- 2
local ____StreamUpdates = require("Agent.Runtime.StreamUpdates") -- 3
local StreamUpdates = ____StreamUpdates.StreamUpdates -- 3
local ____SessionEvents = require("Agent.Runtime.SessionEvents") -- 4
local publishSessionPatch = ____SessionEvents.publishSessionPatch -- 4
local ____TaskAdmission = require("Agent.Runtime.TaskAdmission") -- 5
local holdProjectTaskAdmission = ____TaskAdmission.holdProjectTaskAdmission -- 5
local isProjectTaskAdmissionClosed = ____TaskAdmission.isProjectTaskAdmissionClosed -- 5
local ____DoraAgent = require("Agent.DoraAgent") -- 7
local runCodingAgent = ____DoraAgent.runCodingAgent -- 7
local truncateAgentUserPrompt = ____DoraAgent.truncateAgentUserPrompt -- 7
local AgentConfig = require("Agent.Config.Defaults") -- 10
local AgentToolRegistry = require("Agent.Tool.Registry") -- 11
local AgentRuntimePolicy = require("Agent.Runtime.Policy") -- 12
local LocalAgent = require("Agent.Runtime.LocalAgent") -- 13
local Tools = require("Agent.Tools") -- 14
local ____Database = require("Agent.Storage.Database") -- 15
local TABLE_SESSION = ____Database.TABLE_SESSION -- 16
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE -- 17
local TABLE_STEP = ____Database.TABLE_STEP -- 18
local TABLE_TASK = ____Database.TABLE_TASK -- 19
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE -- 20
local addTaskReference = ____Database.addTaskReference -- 21
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData -- 22
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds -- 23
local requireAgentStorage = ____Database.requireAgentStorage -- 24
local InputInbox = require("Agent.Runtime.InputInbox") -- 26
local ____Memory = require("Agent.Runtime.Memory") -- 28
local DualLayerStorage = ____Memory.DualLayerStorage -- 28
local ____Utils = require("Agent.Utils") -- 29
local Log = ____Utils.Log -- 29
local getLLMConfig = ____Utils.getLLMConfig -- 29
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 29
local safeJsonDecode = ____Utils.safeJsonDecode -- 29
local safeJsonEncode = ____Utils.safeJsonEncode -- 29
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 29
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig -- 29
local ____Questionnaire = require("Agent.Runtime.Questionnaire") -- 33
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers -- 33
local ____Support = require("Agent.Storage.Support") -- 35
local getLastInsertRowId = ____Support.getLastInsertRowId -- 35
local queryOne = ____Support.queryOne -- 35
local queryRows = ____Support.queryRows -- 35
local toStr = ____Support.toStr -- 35
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, submission) -- 423
	return followup.submit( -- 425
		sessionId, -- 425
		prompt, -- 425
		{disabledAgentTools = disabledAgentTools, workMode = workMode, llmConfigId = llmConfigId, maxSteps = maxSteps}, -- 425
		{llmConfig = llmConfig, llmConfigId = llmConfigId}, -- 426
		submission -- 426
	) -- 426
end -- 423
function scheduleStreamFlush() -- 492
	if streamFlushScheduled or not streamUpdates:hasPending() then -- 492
		return -- 493
	end -- 493
	streamFlushScheduled = true -- 494
	Director.systemScheduler:schedule(function() -- 495
		streamUpdates:flushDue(App.runningTime) -- 496
		if streamUpdates:hasPending() then -- 496
			return false -- 497
		end -- 497
		streamFlushScheduled = false -- 498
		return true -- 499
	end) -- 495
end -- 495
function getDefaultUseChineseResponse() -- 513
	local zh = string.match(App.locale, "^zh") -- 514
	return zh ~= nil -- 515
end -- 515
function encodeJson(value) -- 518
	local text = safeJsonEncode(value) -- 519
	return text or "" -- 520
end -- 520
function decodeJsonObject(text) -- 523
	if text == "" then -- 523
		return nil -- 524
	end -- 524
	local value = safeJsonDecode(text) -- 525
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 525
		return value -- 527
	end -- 527
	return nil -- 529
end -- 529
function decodeJsonFiles(text) -- 532
	if text == "" then -- 532
		return nil -- 533
	end -- 533
	local value = safeJsonDecode(text) -- 534
	if not value or not __TS__ArrayIsArray(value) then -- 534
		return nil -- 535
	end -- 535
	local files = {} -- 536
	do -- 536
		local i = 0 -- 537
		while i < #value do -- 537
			do -- 537
				local item = value[i + 1] -- 538
				if type(item) ~= "table" then -- 538
					goto __continue76 -- 539
				end -- 539
				files[#files + 1] = { -- 540
					path = sanitizeUTF8(toStr(item.path)), -- 541
					op = sanitizeUTF8(toStr(item.op)) -- 542
				} -- 542
			end -- 542
			::__continue76:: -- 542
			i = i + 1 -- 537
		end -- 537
	end -- 537
	return files -- 545
end -- 545
function decodeChangeSetSummary(value) -- 548
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 548
		return nil -- 549
	end -- 549
	local row = value -- 550
	if row.success ~= true then -- 550
		return nil -- 551
	end -- 551
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 552
	if taskId <= 0 then -- 552
		return nil -- 553
	end -- 553
	local files = {} -- 554
	if __TS__ArrayIsArray(row.files) then -- 554
		do -- 554
			local i = 0 -- 556
			while i < #row.files do -- 556
				do -- 556
					local file = row.files[i + 1] -- 557
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 557
						goto __continue84 -- 558
					end -- 558
					local fileRow = file -- 559
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 560
					if path == "" then -- 560
						goto __continue84 -- 561
					end -- 561
					local checkpointIds = {} -- 562
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 562
						do -- 562
							local j = 0 -- 564
							while j < #fileRow.checkpointIds do -- 564
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 565
								if checkpointId > 0 then -- 565
									checkpointIds[#checkpointIds + 1] = checkpointId -- 566
								end -- 566
								j = j + 1 -- 564
							end -- 564
						end -- 564
					end -- 564
					local op = toStr(fileRow.op) -- 569
					files[#files + 1] = { -- 570
						path = path, -- 571
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 572
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 573
						checkpointIds = checkpointIds -- 574
					} -- 574
				end -- 574
				::__continue84:: -- 574
				i = i + 1 -- 556
			end -- 556
		end -- 556
	end -- 556
	return { -- 578
		success = true, -- 579
		taskId = taskId, -- 580
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 581
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 582
		files = files, -- 583
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 584
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 585
	} -- 585
end -- 585
function decodeHandoffEvidence(value) -- 589
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 589
		return nil -- 590
	end -- 590
	local row = value -- 591
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 592
		__TS__ArrayFilter( -- 593
			row.modifiedFiles, -- 593
			function(____, item) return type(item) == "string" end -- 593
		), -- 593
		function(____, item) return sanitizeUTF8(item) end -- 593
	) or ({}) -- 593
	local lastBuild = nil -- 595
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 595
		local build = row.lastBuild -- 597
		lastBuild = { -- 598
			result = build.result == "passed" and "passed" or "failed", -- 599
			path = sanitizeUTF8(toStr(build.path)), -- 600
			evidence = takeUtf8Head( -- 601
				sanitizeUTF8(toStr(build.evidence)), -- 601
				600 -- 601
			) -- 601
		} -- 601
	end -- 601
	local commands = {} -- 604
	if __TS__ArrayIsArray(row.commands) then -- 604
		do -- 604
			local i = 0 -- 606
			while i < #row.commands and #commands < 8 do -- 606
				do -- 606
					local raw = row.commands[i + 1] -- 607
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 607
						goto __continue98 -- 608
					end -- 608
					local item = raw -- 609
					commands[#commands + 1] = { -- 610
						mode = sanitizeUTF8(toStr(item.mode)), -- 611
						command = takeUtf8Head( -- 612
							sanitizeUTF8(toStr(item.command)), -- 612
							600 -- 612
						), -- 612
						result = item.result == "passed" and "passed" or "failed", -- 613
						evidence = takeUtf8Head( -- 614
							sanitizeUTF8(toStr(item.evidence)), -- 614
							600 -- 614
						) -- 614
					} -- 614
				end -- 614
				::__continue98:: -- 614
				i = i + 1 -- 606
			end -- 606
		end -- 606
	end -- 606
	local authoritativeSources = {} -- 618
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 618
		do -- 618
			local i = 0 -- 620
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 620
				do -- 620
					local raw = row.authoritativeSources[i + 1] -- 621
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 621
						goto __continue102 -- 622
					end -- 622
					local item = raw -- 623
					authoritativeSources[#authoritativeSources + 1] = { -- 624
						tool = "search_dora_doc", -- 625
						query = takeUtf8Head( -- 626
							sanitizeUTF8(toStr(item.query)), -- 626
							300 -- 626
						), -- 626
						source = sanitizeUTF8(toStr(item.source)), -- 627
						result = item.result == "passed" and "passed" or "failed" -- 628
					} -- 628
				end -- 628
				::__continue102:: -- 628
				i = i + 1 -- 620
			end -- 620
		end -- 620
	end -- 620
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 632
end -- 632
function takeUtf8Head(text, maxChars) -- 635
	if maxChars <= 0 or text == "" then -- 635
		return "" -- 636
	end -- 636
	local nextPos = utf8.offset(text, maxChars + 1) -- 637
	if nextPos == nil then -- 637
		return text -- 638
	end -- 638
	return string.sub(text, 1, nextPos - 1) -- 639
end -- 639
function normalizeMemoryEntryEvidence(value) -- 642
	local evidence = {} -- 643
	if not __TS__ArrayIsArray(value) then -- 643
		return evidence -- 644
	end -- 644
	do -- 644
		local i = 0 -- 645
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 645
			do -- 645
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 646
				if item == "" then -- 646
					goto __continue110 -- 647
				end -- 647
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 647
					evidence[#evidence + 1] = item -- 649
				end -- 649
			end -- 649
			::__continue110:: -- 649
			i = i + 1 -- 645
		end -- 645
	end -- 645
	return evidence -- 652
end -- 652
function decodeSubAgentMemoryEntry(value) -- 655
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 655
		return nil -- 656
	end -- 656
	local row = value -- 657
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 658
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 659
	local content = takeUtf8Head( -- 660
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 660
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 660
	) -- 660
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 660
		return nil -- 661
	end -- 661
	return { -- 662
		sourceSessionId = sourceSessionId, -- 663
		sourceTaskId = sourceTaskId, -- 664
		content = content, -- 665
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 666
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 667
	} -- 667
end -- 667
function getTaskChangeSetSummary(taskId) -- 671
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 672
	return summary.success and summary or nil -- 673
end -- 673
function summarizeHandoffResult(result) -- 676
	local candidates = {result.output, result.message, result.state, result.phase} -- 677
	do -- 677
		local i = 0 -- 678
		while i < #candidates do -- 678
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 679
			if text ~= "" then -- 679
				return takeUtf8Head(text, 600) -- 680
			end -- 680
			i = i + 1 -- 678
		end -- 678
	end -- 678
	local messages = result.messages -- 682
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 682
		local parts = {} -- 684
		do -- 684
			local i = 0 -- 685
			while i < #messages and #parts < 4 do -- 685
				do -- 685
					local row = messages[i + 1] -- 686
					if not row or type(row) ~= "table" then -- 686
						goto __continue123 -- 687
					end -- 687
					local item = row -- 688
					local ____sanitizeUTF8_33 = sanitizeUTF8 -- 689
					local ____toStr_32 = toStr -- 689
					local ____item_message_30 = item.message -- 689
					if ____item_message_30 == nil then -- 689
						____item_message_30 = item.error -- 689
					end -- 689
					local ____item_message_30_31 = ____item_message_30 -- 689
					if ____item_message_30_31 == nil then -- 689
						____item_message_30_31 = item.file -- 689
					end -- 689
					local text = __TS__StringTrim(____sanitizeUTF8_33(____toStr_32(____item_message_30_31))) -- 689
					if text ~= "" then -- 689
						parts[#parts + 1] = text -- 690
					end -- 690
				end -- 690
				::__continue123:: -- 690
				i = i + 1 -- 685
			end -- 685
		end -- 685
		if #parts > 0 then -- 685
			return takeUtf8Head( -- 692
				table.concat(parts, "; "), -- 692
				600 -- 692
			) -- 692
		end -- 692
	end -- 692
	return result.success == true and "tool result success=true" or "tool result success=false" -- 694
end -- 694
function getTaskHandoffEvidence(taskId, changeSet) -- 697
	local ____opt_34 = changeSet -- 697
	local evidence = { -- 698
		modifiedFiles = ____opt_34 and __TS__ArrayMap( -- 699
			changeSet and changeSet.files, -- 699
			function(____, item) return item.path end -- 699
		) or ({}), -- 699
		commands = {}, -- 700
		authoritativeSources = {} -- 701
	} -- 701
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 703
	do -- 703
		local i = 0 -- 708
		while i < #rows do -- 708
			local tool = toStr(rows[i + 1][1]) -- 709
			local status = toStr(rows[i + 1][2]) -- 710
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 711
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 712
			local passed = status == "DONE" and result.success == true -- 713
			if tool == "build" then -- 713
				evidence.lastBuild = { -- 715
					result = passed and "passed" or "failed", -- 716
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 717
					evidence = summarizeHandoffResult(result) -- 718
				} -- 718
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 718
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 721
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 722
				local ____evidence_commands_38 = evidence.commands -- 722
				____evidence_commands_38[#____evidence_commands_38 + 1] = { -- 723
					mode = mode, -- 724
					command = takeUtf8Head( -- 725
						__TS__StringTrim(sanitizeUTF8(command)), -- 725
						600 -- 725
					), -- 725
					result = passed and "passed" or "failed", -- 726
					evidence = summarizeHandoffResult(result) -- 727
				} -- 727
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 727
				local ____evidence_authoritativeSources_39 = evidence.authoritativeSources -- 727
				____evidence_authoritativeSources_39[#____evidence_authoritativeSources_39 + 1] = { -- 730
					tool = "search_dora_doc", -- 731
					query = takeUtf8Head( -- 732
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 732
						300 -- 732
					), -- 732
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 733
					result = passed and "passed" or "failed" -- 734
				} -- 734
			end -- 734
			i = i + 1 -- 708
		end -- 708
	end -- 708
	return evidence -- 738
end -- 738
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 741
	local lastBuild = evidence.lastBuild -- 745
	if not lastBuild or lastBuild.result ~= "failed" then -- 745
		return completion -- 746
	end -- 746
	local validation = __TS__ArraySlice(completion.validation) -- 747
	local foundBuild = false -- 748
	do -- 748
		local i = 0 -- 749
		while i < #validation do -- 749
			do -- 749
				if validation[i + 1].kind ~= "build" then -- 749
					goto __continue137 -- 750
				end -- 750
				foundBuild = true -- 751
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 752
			end -- 752
			::__continue137:: -- 752
			i = i + 1 -- 749
		end -- 749
	end -- 749
	if not foundBuild then -- 749
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 759
	end -- 759
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 761
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 762
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 762
		knownIssues[#knownIssues + 1] = issue -- 763
	end -- 763
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 764
end -- 764
function isValidProjectRoot(path) -- 772
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 773
end -- 773
function rowToSession(row) -- 776
	return { -- 777
		id = row[1], -- 778
		projectRoot = toStr(row[2]), -- 779
		title = toStr(row[3]), -- 780
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 781
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 782
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 783
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 784
		status = toStr(row[8]), -- 785
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 786
		currentTaskStatus = toStr(row[10]), -- 787
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 788
		createdAt = row[11], -- 789
		updatedAt = row[12], -- 790
		metrics = decodeJsonObject(toStr(row[13])), -- 791
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 792
	} -- 792
end -- 792
function rowToMessage(row) -- 796
	local message = { -- 797
		id = row[1], -- 798
		sessionId = row[2], -- 799
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 800
		role = toStr(row[4]), -- 801
		content = toStr(row[5]), -- 802
		createdAt = row[7], -- 803
		updatedAt = row[8] -- 804
	} -- 804
	local displayContent = toStr(row[6]) -- 806
	if displayContent ~= "" then -- 806
		message.displayContent = displayContent -- 807
	end -- 807
	local receipt = queryOne("SELECT delivery,delivered_step FROM agent.AgentSessionInput WHERE message_id=? AND status='delivered'", {message.id}) -- 808
	if (receipt and receipt[1]) == "steer" then -- 808
		message.inputKind = "steer" -- 809
		message.afterStep = type(receipt[2]) == "number" and receipt[2] or 0 -- 809
	end -- 809
	return message -- 810
end -- 810
function rowToStep(row) -- 813
	return { -- 814
		id = row[1], -- 815
		sessionId = row[2], -- 816
		taskId = row[3], -- 817
		step = row[4], -- 818
		tool = toStr(row[5]), -- 819
		status = toStr(row[6]), -- 820
		reason = toStr(row[7]), -- 821
		reasoningContent = toStr(row[8]), -- 822
		params = decodeJsonObject(toStr(row[9])), -- 823
		result = decodeJsonObject(toStr(row[10])), -- 824
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 825
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 826
		files = decodeJsonFiles(toStr(row[13])), -- 827
		createdAt = row[14], -- 828
		updatedAt = row[15] -- 829
	} -- 829
end -- 829
function getQuestionnairePath(projectRoot) -- 833
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 834
end -- 834
function decodeQuestionnaireFile(text) -- 837
	local value = decodeJsonObject(text) -- 838
	if not value then -- 838
		return nil -- 839
	end -- 839
	local schema = value.schema -- 840
	local id = type(value.id) == "number" and value.id or 0 -- 841
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 842
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 843
	local step = type(value.step) == "number" and value.step or 0 -- 844
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 845
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 845
		return nil -- 847
	end -- 847
	return { -- 849
		id = id, -- 849
		sessionId = sessionId, -- 849
		taskId = taskId, -- 849
		step = step, -- 849
		status = "PENDING", -- 849
		schema = schema, -- 849
		createdAt = createdAt -- 849
	} -- 849
end -- 849
function getPendingQuestionnaire(sessionId) -- 852
	local session = getSessionItem(sessionId) -- 853
	if not session or session.kind ~= "main" then -- 853
		return nil -- 854
	end -- 854
	local path = getQuestionnairePath(session.projectRoot) -- 855
	if not Content:exist(path) then -- 855
		return nil -- 856
	end -- 856
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 857
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 858
end -- 858
function restorePendingQuestionnaireState(session) -- 861
	local questionnaire = getPendingQuestionnaire(session.id) -- 862
	if not questionnaire then -- 862
		return {session = session} -- 863
	end -- 863
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 863
		local t = now() -- 870
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 871
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 877
		local restored = getSessionItem(session.id) -- 878
		if restored then -- 878
			session = restored -- 879
		end -- 879
	end -- 879
	return {session = session, questionnaire = questionnaire} -- 881
end -- 881
function savePendingQuestionnaire(projectRoot, questionnaire) -- 884
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 885
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 885
		return false -- 886
	end -- 886
	local path = getQuestionnairePath(projectRoot) -- 887
	local tempPath = path .. ".tmp" -- 888
	local backupPath = path .. ".bak" -- 889
	Content:remove(tempPath) -- 890
	Content:remove(backupPath) -- 891
	if not Content:save( -- 891
		tempPath, -- 892
		encodeJson(questionnaire) -- 892
	) then -- 892
		return false -- 892
	end -- 892
	local hadOriginal = Content:exist(path) -- 893
	if hadOriginal and not Content:move(path, backupPath) then -- 893
		Content:remove(tempPath) -- 895
		return false -- 896
	end -- 896
	if Content:move(tempPath, path) then -- 896
		Content:remove(backupPath) -- 899
		Tools.sendWebIDEFileUpdate( -- 900
			path, -- 900
			true, -- 900
			encodeJson(questionnaire) -- 900
		) -- 900
		return true -- 901
	end -- 901
	Content:remove(tempPath) -- 903
	if hadOriginal and Content:exist(backupPath) then -- 903
		Content:move(backupPath, path) -- 905
	end -- 905
	return false -- 907
end -- 907
function removePendingQuestionnaire(session) -- 910
	local path = getQuestionnairePath(session.projectRoot) -- 911
	if not Content:exist(path) then -- 911
		return true -- 912
	end -- 912
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 913
	if questionnaire and questionnaire.sessionId ~= session.id then -- 913
		return false -- 914
	end -- 914
	if not Content:remove(path) then -- 914
		return false -- 915
	end -- 915
	Tools.sendWebIDEFileUpdate(path, false, "") -- 916
	return true -- 917
end -- 917
function publishQuestionnaire(request) -- 920
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 920
		local session = getSessionItem(request.sessionId) -- 926
		if not session or session.kind ~= "main" then -- 926
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 926
		end -- 926
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 928
		if Content:exist(pendingPath) then -- 928
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 928
		end -- 928
		local questionnaire = { -- 930
			id = request.taskId, -- 931
			sessionId = request.sessionId, -- 932
			taskId = request.taskId, -- 933
			step = request.step, -- 934
			status = "PENDING", -- 935
			schema = request.schema, -- 936
			createdAt = now() -- 937
		} -- 937
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 937
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 937
		end -- 937
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 937
	end) -- 937
end -- 937
function getMessageItem(messageId) -- 945
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 946
	return row and rowToMessage(row) or nil -- 952
end -- 952
function getStepItem(sessionId, taskId, step) -- 955
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 956
	return row and rowToStep(row) or nil -- 962
end -- 962
function deleteMessageSteps(sessionId, taskId) -- 965
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 966
	local ids = {} -- 971
	do -- 971
		local i = 0 -- 972
		while i < #rows do -- 972
			local row = rows[i + 1] -- 973
			if type(row[1]) == "number" then -- 973
				ids[#ids + 1] = row[1] -- 975
			end -- 975
			i = i + 1 -- 972
		end -- 972
	end -- 972
	if #ids > 0 then -- 972
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 979
	end -- 979
	return ids -- 985
end -- 985
function normalizeDisabledAgentTools(value) -- 988
	if not __TS__ArrayIsArray(value) then -- 988
		return {} -- 989
	end -- 989
	local tools = {} -- 990
	do -- 990
		local i = 0 -- 991
		while i < #value do -- 991
			do -- 991
				local name = value[i + 1] -- 992
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 992
					goto __continue182 -- 993
				end -- 993
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 993
					tools[#tools + 1] = name -- 994
				end -- 994
			end -- 994
			::__continue182:: -- 994
			i = i + 1 -- 991
		end -- 991
	end -- 991
	return tools -- 996
end -- 996
function normalizeWorkMode(value, fallback) -- 999
	if fallback == nil then -- 999
		fallback = "code" -- 999
	end -- 999
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 1000
end -- 1000
function getSessionRow(sessionId) -- 1003
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 1004
end -- 1004
function getSessionItem(sessionId) -- 1012
	local row = getSessionRow(sessionId) -- 1013
	if not row then -- 1013
		return nil -- 1014
	end -- 1014
	local session = rowToSession(row) -- 1015
	session.pendingInputs = __TS__ArrayMap( -- 1016
		InputInbox.listInputs(session.id), -- 1016
		function(____, item) return { -- 1016
			id = item.id, -- 1016
			content = item.content, -- 1016
			delivery = item.delivery, -- 1016
			held = item.held, -- 1016
			status = item.status -- 1016
		} end -- 1016
	) -- 1016
	return session -- 1017
end -- 1017
function getTaskPrompt(taskId) -- 1020
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1021
	if not row or type(row[1]) ~= "string" then -- 1021
		return nil -- 1022
	end -- 1022
	return toStr(row[1]) -- 1023
end -- 1023
function getLatestMainSessionByProjectRoot(projectRoot) -- 1026
	if not isValidProjectRoot(projectRoot) then -- 1026
		return nil -- 1027
	end -- 1027
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1028
	if not row then -- 1028
		return nil -- 1036
	end -- 1036
	local session = rowToSession(row) -- 1037
	session.pendingInputs = __TS__ArrayMap( -- 1038
		InputInbox.listInputs(session.id), -- 1038
		function(____, item) return { -- 1038
			id = item.id, -- 1038
			content = item.content, -- 1038
			delivery = item.delivery, -- 1038
			held = item.held, -- 1038
			status = item.status -- 1038
		} end -- 1038
	) -- 1038
	return session -- 1039
end -- 1039
function countRunningSubSessions(rootSessionId) -- 1042
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 1043
	local count = 0 -- 1050
	do -- 1050
		local i = 0 -- 1051
		while i < #rows do -- 1051
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1052
			if session.currentTaskStatus == "RUNNING" then -- 1052
				count = count + 1 -- 1054
			end -- 1054
			i = i + 1 -- 1051
		end -- 1051
	end -- 1051
	return count -- 1057
end -- 1057
function deleteSessionRecords(sessionId, preserveArtifacts) -- 1060
	if preserveArtifacts == nil then -- 1060
		preserveArtifacts = false -- 1060
	end -- 1060
	for ____, input in ipairs(InputInbox.listInputs(sessionId, true)) do -- 1061
		__TS__Delete(followup.configs, input.id) -- 1061
	end -- 1061
	DB:exec("DELETE FROM agent.AgentSessionInput WHERE session_id=?", {sessionId}) -- 1062
	__TS__Delete(followup.bindings, sessionId) -- 1063
	__TS__Delete(followup.recovered, sessionId) -- 1064
	streamUpdates:clear(sessionId) -- 1065
	local session = getSessionItem(sessionId) -- 1066
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 1067
	local taskIds = {} -- 1075
	do -- 1075
		local i = 0 -- 1076
		while i < #taskRows do -- 1076
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 1077
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 1077
				taskIds[#taskIds + 1] = taskId -- 1079
				local stopToken = activeStopTokens[taskId] -- 1080
				if stopToken ~= nil then -- 1080
					stopToken.stopped = true -- 1082
					stopToken.reason = "session deleted" -- 1083
				end -- 1083
			end -- 1083
			i = i + 1 -- 1076
		end -- 1076
	end -- 1076
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 1087
	do -- 1087
		local i = 0 -- 1088
		while i < #children do -- 1088
			local row = children[i + 1] -- 1089
			if type(row[1]) == "number" and row[1] > 0 then -- 1089
				deleteSessionRecords(row[1], preserveArtifacts) -- 1091
			end -- 1091
			i = i + 1 -- 1088
		end -- 1088
	end -- 1088
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 1094
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 1095
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 1096
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 1097
	if session and session.kind == "main" then -- 1097
		removePendingQuestionnaire(session) -- 1099
	end -- 1099
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 1099
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 1099
			Tools.sendWebIDERefreshTree() -- 1103
		end -- 1103
	end -- 1103
	do -- 1103
		local i = 0 -- 1106
		while i < #taskIds do -- 1106
			cleanupTaskHeavyData(taskIds[i + 1]) -- 1107
			i = i + 1 -- 1106
		end -- 1106
	end -- 1106
end -- 1106
function getSessionRootId(session) -- 1111
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 1112
end -- 1112
function getRootSessionItem(sessionId) -- 1115
	local session = getSessionItem(sessionId) -- 1116
	if not session then -- 1116
		return nil -- 1117
	end -- 1117
	return getSessionItem(getSessionRootId(session)) or session -- 1118
end -- 1118
function listRelatedSessions(sessionId) -- 1121
	local root = getRootSessionItem(sessionId) -- 1122
	if not root then -- 1122
		return {} -- 1123
	end -- 1123
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 1124
	return __TS__ArrayMap( -- 1133
		rows, -- 1133
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 1133
	) -- 1133
end -- 1133
function getSessionSpawnInfo(session) -- 1136
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1137
	if not info then -- 1137
		return nil -- 1138
	end -- 1138
	local ____temp_47 = type(info.sessionId) == "number" and info.sessionId or nil -- 1140
	local ____temp_48 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 1141
	local ____temp_49 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 1142
	local ____temp_50 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 1143
	local ____temp_51 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 1144
	local ____temp_52 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 1145
	local ____temp_53 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 1146
	local ____temp_54 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1147
		__TS__ArrayFilter( -- 1148
			info.filesHint, -- 1148
			function(____, item) return type(item) == "string" end -- 1148
		), -- 1148
		function(____, item) return sanitizeUTF8(item) end -- 1148
	) or nil -- 1148
	local ____temp_55 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 1150
	local ____temp_45 -- 1153
	if info.success == true then -- 1153
		____temp_45 = true -- 1153
	else -- 1153
		local ____temp_44 -- 1153
		if info.success == false then -- 1153
			____temp_44 = false -- 1153
		else -- 1153
			____temp_44 = nil -- 1153
		end -- 1153
		____temp_45 = ____temp_44 -- 1153
	end -- 1153
	local ____temp_46 -- 1154
	if info.cleared == true then -- 1154
		____temp_46 = true -- 1154
	else -- 1154
		____temp_46 = nil -- 1154
	end -- 1154
	return { -- 1139
		sessionId = ____temp_47, -- 1140
		rootSessionId = ____temp_48, -- 1141
		parentSessionId = ____temp_49, -- 1142
		title = ____temp_50, -- 1143
		prompt = ____temp_51, -- 1144
		goal = ____temp_52, -- 1145
		expectedOutput = ____temp_53, -- 1146
		filesHint = ____temp_54, -- 1147
		status = ____temp_55, -- 1150
		success = ____temp_45, -- 1153
		cleared = ____temp_46, -- 1154
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 1155
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 1156
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 1157
		changeSet = decodeChangeSetSummary(info.changeSet), -- 1158
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1159
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1160
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 1161
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 1162
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 1165
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 1166
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 1167
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 1168
	} -- 1168
end -- 1168
function ensureDirRecursive(dir) -- 1185
	if dir == "" then -- 1185
		return false -- 1186
	end -- 1186
	if Content:exist(dir) then -- 1186
		return Content:isdir(dir) -- 1187
	end -- 1187
	local parent = Path:getPath(dir) -- 1188
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1188
		if not ensureDirRecursive(parent) then -- 1188
			return false -- 1191
		end -- 1191
	end -- 1191
	return Content:mkdir(dir) -- 1194
end -- 1194
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1197
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1198
	if not Content:exist(dir) then -- 1198
		ensureDirRecursive(dir) -- 1200
	end -- 1200
	local path = Path(dir, SPAWN_INFO_FILE) -- 1202
	local text = safeJsonEncode(value) -- 1203
	if not text then -- 1203
		return false -- 1204
	end -- 1204
	local content = text .. "\n" -- 1205
	if not Content:save(path, content) then -- 1205
		return false -- 1207
	end -- 1207
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1209
	return true -- 1210
end -- 1210
function readSpawnInfo(projectRoot, memoryScope) -- 1213
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1214
	if not Content:exist(path) then -- 1214
		return nil -- 1215
	end -- 1215
	local text = Content:load(path) -- 1216
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1216
		return nil -- 1217
	end -- 1217
	local value = safeJsonDecode(text) -- 1218
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1218
		return value -- 1220
	end -- 1220
	return nil -- 1222
end -- 1222
function getArtifactRelativeDir(memoryScope) -- 1225
	return Path(".agent", memoryScope) -- 1226
end -- 1226
function getArtifactDir(projectRoot, memoryScope) -- 1229
	return Path( -- 1230
		projectRoot, -- 1230
		getArtifactRelativeDir(memoryScope) -- 1230
	) -- 1230
end -- 1230
function getResultRelativePath(memoryScope) -- 1233
	return Path( -- 1234
		getArtifactRelativeDir(memoryScope), -- 1234
		RESULT_FILE -- 1234
	) -- 1234
end -- 1234
function getResultPath(projectRoot, memoryScope) -- 1237
	return Path( -- 1238
		projectRoot, -- 1238
		getResultRelativePath(memoryScope) -- 1238
	) -- 1238
end -- 1238
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1241
	if resultFilePath == "" then -- 1241
		return "" -- 1242
	end -- 1242
	local path = Path(projectRoot, resultFilePath) -- 1243
	if not Content:exist(path) then -- 1243
		return "" -- 1244
	end -- 1244
	local text = sanitizeUTF8(Content:load(path)) -- 1245
	if __TS__StringTrim(text) == "" then -- 1245
		return "" -- 1246
	end -- 1246
	local marker = "\n## Summary\n" -- 1247
	local start = string.find(text, marker, 1, true) -- 1248
	if start ~= nil then -- 1248
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1250
	end -- 1250
	return __TS__StringTrim(text) -- 1252
end -- 1252
function buildStructuredSubAgentMemoryEntry(record) -- 1255
	local hasPassedValidation = false -- 1256
	do -- 1256
		local i = 0 -- 1257
		while i < #record.completion.validation do -- 1257
			local result = record.completion.validation[i + 1].result -- 1258
			if result == "failed" then -- 1258
				return nil -- 1263
			end -- 1263
			if result == "passed" then -- 1263
				hasPassedValidation = true -- 1265
			end -- 1265
			i = i + 1 -- 1257
		end -- 1257
	end -- 1257
	if not hasPassedValidation then -- 1257
		return nil -- 1268
	end -- 1268
	local candidates = record.completion.learningCandidates -- 1269
	local claims = {} -- 1270
	local evidence = {} -- 1271
	do -- 1271
		local i = 0 -- 1272
		while i < #candidates do -- 1272
			do -- 1272
				local candidate = candidates[i + 1] -- 1273
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1273
					goto __continue259 -- 1274
				end -- 1274
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1275
				do -- 1275
					local j = 0 -- 1276
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1276
						local item = candidate.evidence[j + 1] -- 1277
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1277
							evidence[#evidence + 1] = item -- 1278
						end -- 1278
						j = j + 1 -- 1276
					end -- 1276
				end -- 1276
			end -- 1276
			::__continue259:: -- 1276
			i = i + 1 -- 1272
		end -- 1272
	end -- 1272
	local content = takeUtf8Head( -- 1281
		table.concat(claims, "\n"), -- 1281
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1281
	) -- 1281
	if content == "" then -- 1281
		return nil -- 1282
	end -- 1282
	return { -- 1283
		sourceSessionId = record.sessionId, -- 1284
		sourceTaskId = record.sourceTaskId, -- 1285
		content = content, -- 1286
		evidence = evidence, -- 1287
		createdAt = record.finishedAt -- 1288
	} -- 1288
end -- 1288
function containsNormalizedText(text, query) -- 1292
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1293
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1294
	if normalizedQuery == "" then -- 1294
		return true -- 1295
	end -- 1295
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1296
end -- 1296
function getSubAgentDisplayKey(item) -- 1299
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1305
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1306
	local label = goal ~= "" and goal or title -- 1307
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1308
end -- 1308
function writeSubAgentResultFile(session, record, resultText) -- 1311
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1312
	if not Content:exist(dir) then -- 1312
		ensureDirRecursive(dir) -- 1314
	end -- 1314
	local ____array_64 = __TS__SparseArrayNew( -- 1314
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1317
		"- Status: " .. record.status, -- 1318
		"- Success: " .. (record.success and "true" or "false"), -- 1319
		"- Outcome: " .. record.completion.outcome, -- 1320
		"- Session ID: " .. tostring(record.sessionId), -- 1321
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1322
		"- Goal: " .. record.goal, -- 1323
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1324
	) -- 1324
	__TS__SparseArrayPush( -- 1324
		____array_64, -- 1324
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1325
	) -- 1325
	__TS__SparseArrayPush( -- 1325
		____array_64, -- 1325
		"- Finished At: " .. record.finishedAt, -- 1326
		"", -- 1327
		"## Validation", -- 1328
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1329
			record.completion.validation, -- 1330
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1330
		) or ({"- Not reported"})) -- 1330
	) -- 1330
	__TS__SparseArrayPush(____array_64, "", "## Recorded Evidence") -- 1330
	local ____opt_56 = record.handoffEvidence -- 1330
	__TS__SparseArrayPush( -- 1330
		____array_64, -- 1330
		table.unpack(____opt_56 and #____opt_56.modifiedFiles and __TS__ArrayMap( -- 1334
			record.handoffEvidence.modifiedFiles, -- 1335
			function(____, item) return "- modified: " .. item end -- 1335
		) or ({"- modified: none recorded"})) -- 1335
	) -- 1335
	local ____opt_58 = record.handoffEvidence -- 1335
	__TS__SparseArrayPush( -- 1335
		____array_64, -- 1335
		table.unpack(____opt_58 and ____opt_58.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1337
	) -- 1337
	local ____opt_60 = record.handoffEvidence -- 1337
	__TS__SparseArrayPush( -- 1337
		____array_64, -- 1337
		table.unpack(__TS__ArrayMap( -- 1340
			____opt_60 and ____opt_60.commands or ({}), -- 1340
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1340
		)) -- 1340
	) -- 1340
	local ____opt_62 = record.handoffEvidence -- 1340
	__TS__SparseArrayPush( -- 1340
		____array_64, -- 1340
		table.unpack(__TS__ArrayMap( -- 1341
			____opt_62 and ____opt_62.authoritativeSources or ({}), -- 1341
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1341
		)) -- 1341
	) -- 1341
	__TS__SparseArrayPush( -- 1341
		____array_64, -- 1341
		"", -- 1342
		"## Known Issues", -- 1343
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1344
			record.completion.knownIssues, -- 1344
			function(____, item) return "- " .. item end -- 1344
		) or ({"- None reported"})) -- 1344
	) -- 1344
	__TS__SparseArrayPush( -- 1344
		____array_64, -- 1344
		"", -- 1345
		"## Assumptions", -- 1346
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1347
			record.completion.assumptions, -- 1347
			function(____, item) return "- " .. item end -- 1347
		) or ({"- None reported"})) -- 1347
	) -- 1347
	__TS__SparseArrayPush(____array_64, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1347
	local lines = {__TS__SparseArraySpread(____array_64)} -- 1316
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1352
	local content = table.concat(lines, "\n") .. "\n" -- 1353
	if not Content:save(path, content) then -- 1353
		return false -- 1355
	end -- 1355
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1357
	return true -- 1358
end -- 1358
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1361
	local dir = Path(projectRoot, ".agent", "subagents") -- 1362
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1362
		return {} -- 1363
	end -- 1363
	local items = {} -- 1364
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1365
		do -- 1365
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1366
			if not Content:exist(path) or not Content:isdir(path) then -- 1366
				goto __continue279 -- 1367
			end -- 1367
			local info = readSpawnInfo( -- 1368
				projectRoot, -- 1368
				Path( -- 1368
					"subagents", -- 1368
					Path:getFilename(path) -- 1368
				) -- 1368
			) -- 1368
			if not info then -- 1368
				goto __continue279 -- 1369
			end -- 1369
			local sessionId = tonumber(info.sessionId) -- 1370
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1371
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1372
			local status = sanitizeUTF8(toStr(info.status)) -- 1373
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1373
				goto __continue279 -- 1374
			end -- 1374
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1374
				goto __continue279 -- 1375
			end -- 1375
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1376
			items[#items + 1] = { -- 1377
				sessionId = sessionId, -- 1378
				rootSessionId = infoRootSessionId, -- 1379
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1380
				title = sanitizeUTF8(toStr(info.title)), -- 1381
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1382
				goal = sanitizeUTF8(toStr(info.goal)), -- 1383
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1384
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1385
					__TS__ArrayFilter( -- 1386
						info.filesHint, -- 1386
						function(____, item) return type(item) == "string" end -- 1386
					), -- 1386
					function(____, item) return sanitizeUTF8(item) end -- 1386
				) or ({}), -- 1386
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1388
				success = info.success == true, -- 1389
				cleared = info.cleared == true, -- 1390
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1391
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1392
					"subagents", -- 1392
					Path:getFilename(path) -- 1392
				)), -- 1392
				sourceTaskId = sourceTaskId or 0, -- 1393
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1394
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1395
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1396
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1397
				completion = normalizeAgentCompletionReport(info.completion), -- 1398
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1399
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1400
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1401
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1402
			} -- 1402
		end -- 1402
		::__continue279:: -- 1402
	end -- 1402
	__TS__ArraySort( -- 1405
		items, -- 1405
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1405
	) -- 1405
	return items -- 1406
end -- 1406
function getPendingHandoffDir(projectRoot, memoryScope) -- 1409
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1410
end -- 1410
function writePendingHandoff(projectRoot, memoryScope, value) -- 1413
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1414
	if not Content:exist(dir) then -- 1414
		ensureDirRecursive(dir) -- 1416
	end -- 1416
	local path = Path(dir, value.id .. ".json") -- 1418
	local text = safeJsonEncode(value) -- 1419
	if not text then -- 1419
		return false -- 1420
	end -- 1420
	local content = text .. "\n" -- 1421
	if not Content:save(path, content) then -- 1421
		return false -- 1422
	end -- 1422
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1423
	return true -- 1424
end -- 1424
function listPendingHandoffs(projectRoot, memoryScope) -- 1427
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1428
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1428
		return {} -- 1429
	end -- 1429
	local items = {} -- 1430
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1431
		do -- 1431
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1432
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1432
				goto __continue295 -- 1433
			end -- 1433
			local text = Content:load(path) -- 1434
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1434
				goto __continue295 -- 1435
			end -- 1435
			local obj = safeJsonDecode(text) -- 1436
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1436
				goto __continue295 -- 1437
			end -- 1437
			local value = obj -- 1438
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1439
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1440
			local id = sanitizeUTF8(toStr(value.id)) -- 1441
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1442
			local message = sanitizeUTF8(toStr(value.message)) -- 1443
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1444
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1445
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1446
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1446
				goto __continue295 -- 1448
			end -- 1448
			items[#items + 1] = { -- 1450
				id = id, -- 1451
				sourceSessionId = sourceSessionId, -- 1452
				sourceTitle = sourceTitle, -- 1453
				sourceTaskId = sourceTaskId, -- 1454
				message = message, -- 1455
				prompt = prompt, -- 1456
				goal = goal, -- 1457
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1458
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1459
					__TS__ArrayFilter( -- 1460
						value.filesHint, -- 1460
						function(____, item) return type(item) == "string" end -- 1460
					), -- 1460
					function(____, item) return sanitizeUTF8(item) end -- 1460
				) or ({}), -- 1460
				success = value.success == true, -- 1462
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1463
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1464
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1465
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1466
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1467
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1468
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1469
				createdAt = createdAt -- 1472
			} -- 1472
		end -- 1472
		::__continue295:: -- 1472
	end -- 1472
	__TS__ArraySort( -- 1475
		items, -- 1475
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1475
	) -- 1475
	return items -- 1476
end -- 1476
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1479
	local path = Path( -- 1480
		getPendingHandoffDir(projectRoot, memoryScope), -- 1480
		id .. ".json" -- 1480
	) -- 1480
	if Content:exist(path) then -- 1480
		if Content:remove(path) then -- 1480
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1483
		end -- 1483
	end -- 1483
end -- 1483
function normalizePromptText(prompt) -- 1488
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1489
end -- 1489
function normalizePromptTextSafe(prompt) -- 1492
	if type(prompt) == "string" then -- 1492
		local normalized = normalizePromptText(prompt) -- 1494
		if normalized ~= "" then -- 1494
			return normalized -- 1495
		end -- 1495
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1496
		if sanitized ~= "" then -- 1496
			return truncateAgentUserPrompt(sanitized) -- 1498
		end -- 1498
		return "" -- 1500
	end -- 1500
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1502
	if text == "" then -- 1502
		return "" -- 1503
	end -- 1503
	return truncateAgentUserPrompt(text) -- 1504
end -- 1504
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1507
	local sections = {} -- 1508
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1509
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1510
	local normalizedFiles = __TS__ArrayFilter( -- 1511
		__TS__ArrayMap( -- 1511
			__TS__ArrayFilter( -- 1511
				filesHint or ({}), -- 1511
				function(____, item) return type(item) == "string" end -- 1512
			), -- 1512
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1513
		), -- 1513
		function(____, item) return item ~= "" end -- 1514
	) -- 1514
	if normalizedTitle ~= "" then -- 1514
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1516
	end -- 1516
	if normalizedExpected ~= "" then -- 1516
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1519
	end -- 1519
	if #normalizedFiles > 0 then -- 1519
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1522
	end -- 1522
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1524
end -- 1524
function normalizeSessionRuntimeState(session) -- 1527
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1527
		return session -- 1529
	end -- 1529
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1529
		return session -- 1532
	end -- 1532
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1532
		return session -- 1535
	end -- 1535
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1537
		session.id, -- 1540
		session.currentTaskId, -- 1540
		"fetch_url", -- 1540
		"execute_command", -- 1540
		"analyze_image" -- 1540
	}) or ({}) -- 1540
	if #pendingToolRows > 0 then -- 1540
		local t = now() -- 1543
		do -- 1543
			local i = 0 -- 1544
			while i < #pendingToolRows do -- 1544
				local row = pendingToolRows[i + 1] -- 1545
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1546
				result.success = false -- 1547
				result.state = "failed" -- 1548
				result.interrupted = true -- 1549
				result.message = "tool call was interrupted because the program exited before it completed." -- 1550
				DB:exec( -- 1551
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1551
					{ -- 1553
						encodeJson(result), -- 1553
						t, -- 1553
						row[1] -- 1553
					} -- 1553
				) -- 1553
				i = i + 1 -- 1544
			end -- 1544
		end -- 1544
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1556
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1557
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1558
	end -- 1558
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1565
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1566
	return __TS__ObjectAssign( -- 1567
		{}, -- 1567
		session, -- 1568
		{ -- 1567
			status = "STOPPED", -- 1569
			currentTaskStatus = "STOPPED", -- 1570
			updatedAt = now() -- 1571
		} -- 1571
	) -- 1571
end -- 1571
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1575
	DB:exec( -- 1576
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1576
		{ -- 1580
			status, -- 1581
			currentTaskId or 0, -- 1582
			currentTaskStatus or status, -- 1583
			now(), -- 1584
			sessionId -- 1585
		} -- 1585
	) -- 1585
end -- 1585
function mergeAgentMetrics(current, next) -- 1590
	return __TS__ObjectAssign({}, current or ({}), next) -- 1591
end -- 1591
function updateSessionMetrics(sessionId, metrics) -- 1597
	local session = getSessionItem(sessionId) -- 1598
	if not session then -- 1598
		return nil -- 1599
	end -- 1599
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1600
	DB:exec( -- 1601
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1601
		{ -- 1605
			encodeJson(merged), -- 1606
			now(), -- 1607
			sessionId -- 1608
		} -- 1608
	) -- 1608
	return merged -- 1611
end -- 1611
function clearSessionTokenUsage(sessionId) -- 1614
	local session = getSessionItem(sessionId) -- 1615
	if not session then -- 1615
		return nil -- 1616
	end -- 1616
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1617
	__TS__Delete(metrics, "usage") -- 1618
	__TS__Delete(metrics, "visionUsage") -- 1619
	DB:exec( -- 1620
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1620
		{ -- 1624
			encodeJson(metrics), -- 1625
			now(), -- 1626
			sessionId -- 1627
		} -- 1627
	) -- 1627
	return metrics -- 1630
end -- 1630
function getInitialTokenUsage(session) -- 1633
	local ____opt_65 = session.metrics -- 1633
	local usage = ____opt_65 and ____opt_65.usage -- 1634
	if not usage or (usage.requestCount or 0) <= 0 then -- 1634
		return nil -- 1635
	end -- 1635
	return { -- 1636
		inputTokens = usage.inputTokens or 0, -- 1637
		outputTokens = usage.outputTokens or 0, -- 1638
		totalTokens = usage.totalTokens, -- 1639
		cachedInputTokens = usage.cachedInputTokens, -- 1640
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1641
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1642
		requestCount = usage.requestCount or 0, -- 1643
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1644
		model = usage.model or "", -- 1645
		phase = usage.phase or "", -- 1646
		step = usage.step or 0, -- 1647
		updatedAt = usage.updatedAt or now() -- 1648
	} -- 1648
end -- 1648
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1652
	if taskId == nil or taskId <= 0 then -- 1652
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1654
		return -- 1655
	end -- 1655
	local row = getSessionRow(sessionId) -- 1657
	if not row then -- 1657
		return -- 1658
	end -- 1658
	local session = rowToSession(row) -- 1659
	if session.currentTaskId ~= taskId then -- 1659
		Log( -- 1661
			"Info", -- 1661
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1661
		) -- 1661
		return -- 1662
	end -- 1662
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1664
end -- 1664
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1667
	local t = now() -- 1668
	DB:exec( -- 1669
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1669
		{ -- 1672
			sessionId, -- 1673
			taskId or 0, -- 1674
			role, -- 1675
			sanitizeUTF8(content), -- 1676
			displayContent and sanitizeUTF8(displayContent) or "", -- 1677
			t, -- 1678
			t -- 1679
		} -- 1679
	) -- 1679
	return getLastInsertRowId() -- 1682
end -- 1682
function updateMessage(messageId, content) -- 1685
	DB:exec( -- 1686
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1686
		{ -- 1688
			sanitizeUTF8(content), -- 1688
			now(), -- 1688
			messageId -- 1688
		} -- 1688
	) -- 1688
end -- 1688
function updateUserMessageForTask(messageId, content, taskId) -- 1692
	DB:exec( -- 1693
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1693
		{ -- 1697
			sanitizeUTF8(content), -- 1697
			taskId, -- 1697
			now(), -- 1697
			messageId -- 1697
		} -- 1697
	) -- 1697
end -- 1697
function removeContinuableTaskSummary(session) -- 1754
	local taskId = session.currentTaskId -- 1755
	if taskId == nil then -- 1755
		return -- 1756
	end -- 1756
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1757
end -- 1757
function upsertAssistantMessage(sessionId, taskId, content) -- 1769
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1770
	if row and type(row[1]) == "number" then -- 1770
		updateMessage(row[1], content) -- 1777
		return row[1] -- 1778
	end -- 1778
	return insertMessage(sessionId, "assistant", content, taskId) -- 1780
end -- 1780
function upsertStep(sessionId, taskId, step, tool, patch) -- 1783
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1793
	local reason = sanitizeUTF8(patch.reason or "") -- 1797
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1798
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1799
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1800
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1801
	local statusPatch = patch.status or "" -- 1802
	local status = patch.status or "PENDING" -- 1803
	if not row then -- 1803
		local t = now() -- 1805
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1806
			sessionId, -- 1810
			taskId, -- 1811
			step, -- 1812
			tool, -- 1813
			status, -- 1814
			reason, -- 1815
			reasoningContent, -- 1816
			paramsJson, -- 1817
			resultJson, -- 1818
			patch.checkpointId or 0, -- 1819
			patch.checkpointSeq or 0, -- 1820
			filesJson, -- 1821
			t, -- 1822
			t -- 1823
		}) -- 1823
		return -- 1826
	end -- 1826
	DB:exec( -- 1828
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1828
		{ -- 1840
			tool, -- 1841
			statusPatch, -- 1842
			status, -- 1843
			reason, -- 1844
			reason, -- 1845
			reasoningContent, -- 1846
			reasoningContent, -- 1847
			paramsJson, -- 1848
			paramsJson, -- 1849
			resultJson, -- 1850
			resultJson, -- 1851
			patch.checkpointId or 0, -- 1852
			patch.checkpointId or 0, -- 1853
			patch.checkpointSeq or 0, -- 1854
			patch.checkpointSeq or 0, -- 1855
			filesJson, -- 1856
			filesJson, -- 1857
			now(), -- 1858
			row[1] -- 1859
		} -- 1859
	) -- 1859
end -- 1859
function getNextStepNumber(sessionId, taskId) -- 1864
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1865
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1869
	return math.max(0, current) + 1 -- 1870
end -- 1870
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1911
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1919
	local t = now() -- 1920
	local sqls = { -- 1921
		{ -- 1922
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1922
			{{ -- 1925
				sessionId, -- 1926
				ownerTaskId, -- 1927
				step, -- 1928
				"sub_agent_handoff", -- 1929
				"DONE", -- 1930
				sanitizeUTF8(reason), -- 1931
				encodeJson(params), -- 1932
				encodeJson(result), -- 1933
				t, -- 1934
				t -- 1935
			}} -- 1935
		}, -- 1935
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1938
	} -- 1938
	if not DB:transaction(sqls) then -- 1938
		return nil -- 1944
	end -- 1944
	return getStepItem(sessionId, ownerTaskId, step) -- 1945
end -- 1945
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1948
	if taskId <= 0 then -- 1948
		return -- 1949
	end -- 1949
	if finalSteps ~= nil and finalSteps >= 0 then -- 1949
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1951
	end -- 1951
	if not finalStatus then -- 1951
		return -- 1957
	end -- 1957
	if finalSteps ~= nil and finalSteps >= 0 then -- 1957
		DB:exec( -- 1959
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1959
			{ -- 1963
				finalStatus, -- 1963
				now(), -- 1963
				sessionId, -- 1963
				taskId, -- 1963
				finalSteps -- 1963
			} -- 1963
		) -- 1963
		return -- 1965
	end -- 1965
	DB:exec( -- 1967
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1967
		{ -- 1971
			finalStatus, -- 1971
			now(), -- 1971
			sessionId, -- 1971
			taskId -- 1971
		} -- 1971
	) -- 1971
end -- 1971
function emitAgentSessionPatch(sessionId, patch) -- 1998
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 1999
	if not text then -- 1999
		return -- 2004
	end -- 2004
	local failed = publishSessionPatch(sessionId, text) -- 2005
	if failed > 0 then -- 2005
		Log( -- 2006
			"Warn", -- 2006
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 2006
		) -- 2006
	end -- 2006
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 2006
		emit("AppWS", "Send", text) -- 2007
	end -- 2007
end -- 2007
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 2010
	emitAgentSessionPatch( -- 2011
		sessionId, -- 2011
		{ -- 2011
			sessionDeleted = true, -- 2012
			relatedSessions = listRelatedSessions(rootSessionId) -- 2013
		} -- 2013
	) -- 2013
	local rootSession = getSessionItem(rootSessionId) -- 2015
	if rootSession then -- 2015
		emitAgentSessionPatch( -- 2017
			rootSessionId, -- 2017
			{ -- 2017
				session = rootSession, -- 2018
				relatedSessions = listRelatedSessions(rootSessionId) -- 2019
			} -- 2019
		) -- 2019
	end -- 2019
end -- 2019
function flushPendingSubAgentHandoffs(rootSession) -- 2024
	if rootSession.kind ~= "main" then -- 2024
		return -- 2025
	end -- 2025
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 2025
		return -- 2027
	end -- 2027
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 2029
	if #items == 0 then -- 2029
		return -- 2030
	end -- 2030
	local handoffTaskId = 0 -- 2031
	local previousTaskId = rootSession.currentTaskId -- 2032
	local ____rootSession_currentTaskId_69 -- 2033
	if rootSession.currentTaskId then -- 2033
		____rootSession_currentTaskId_69 = getTaskPrompt(rootSession.currentTaskId) -- 2033
	else -- 2033
		____rootSession_currentTaskId_69 = nil -- 2033
	end -- 2033
	local currentTaskPrompt = ____rootSession_currentTaskId_69 -- 2033
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 2033
		handoffTaskId = rootSession.currentTaskId -- 2041
	else -- 2041
		local taskRes = Tools.createTask( -- 2043
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 2043
			"code" -- 2043
		) -- 2043
		if not taskRes.success then -- 2043
			Log( -- 2045
				"Warn", -- 2045
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 2045
			) -- 2045
			return -- 2046
		end -- 2046
		handoffTaskId = taskRes.taskId -- 2048
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 2049
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 2050
		emitAgentSessionPatch( -- 2051
			rootSession.id, -- 2051
			{session = getSessionItem(rootSession.id)} -- 2051
		) -- 2051
	end -- 2051
	do -- 2051
		local i = 0 -- 2055
		while i < #items do -- 2055
			local item = items[i + 1] -- 2056
			local step = appendHandoffSystemStep( -- 2057
				rootSession.id, -- 2058
				handoffTaskId, -- 2059
				item.sourceTaskId, -- 2060
				item.message, -- 2061
				{ -- 2062
					sourceSessionId = item.sourceSessionId, -- 2063
					sourceTitle = item.sourceTitle, -- 2064
					sourceTaskId = item.sourceTaskId, -- 2065
					success = item.success == true, -- 2066
					summary = item.message, -- 2067
					resultFilePath = item.resultFilePath or "", -- 2068
					artifactDir = item.artifactDir or "", -- 2069
					finishedAt = item.finishedAt or "", -- 2070
					changeSet = item.changeSet, -- 2071
					handoffEvidence = item.handoffEvidence, -- 2072
					memoryEntry = item.memoryEntry, -- 2073
					completion = item.completion -- 2074
				}, -- 2074
				{ -- 2076
					sourceSessionId = item.sourceSessionId, -- 2077
					sourceTitle = item.sourceTitle, -- 2078
					sourceTaskId = item.sourceTaskId, -- 2079
					prompt = item.prompt, -- 2080
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 2081
					expectedOutput = item.expectedOutput or "", -- 2082
					filesHint = item.filesHint or ({}), -- 2083
					resultFilePath = item.resultFilePath or "", -- 2084
					artifactDir = item.artifactDir or "", -- 2085
					changeSet = item.changeSet, -- 2086
					handoffEvidence = item.handoffEvidence, -- 2087
					memoryEntry = item.memoryEntry, -- 2088
					completion = item.completion -- 2089
				} -- 2089
			) -- 2089
			if step then -- 2089
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 2093
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 2094
			else -- 2094
				Log( -- 2096
					"Warn", -- 2096
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 2096
				) -- 2096
			end -- 2096
			i = i + 1 -- 2055
		end -- 2055
	end -- 2055
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 2055
		cleanupTaskHeavyData(previousTaskId) -- 2100
	end -- 2100
end -- 2100
function applyEvent(sessionId, event) -- 2112
	if not getSessionItem(sessionId) then -- 2112
		streamUpdates:clear(sessionId) -- 2114
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 2114
			__TS__Delete(activeStopTokens, event.taskId) -- 2116
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 2117
		end -- 2117
		return -- 2119
	end -- 2119
	repeat -- 2119
		local ____switch390 = event.type -- 2119
		local metrics, startedSession -- 2119
		local ____cond390 = ____switch390 == "task_started" -- 2119
		if ____cond390 then -- 2119
			streamUpdates:clear(sessionId) -- 2123
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 2124
			local ____event_resumed_72 -- 2125
			if event.resumed then -- 2125
				local ____opt_70 = getSessionItem(sessionId) -- 2125
				____event_resumed_72 = ____opt_70 and ____opt_70.metrics -- 2126
			else -- 2126
				____event_resumed_72 = clearSessionTokenUsage(sessionId) -- 2127
			end -- 2127
			metrics = ____event_resumed_72 -- 2125
			startedSession = getSessionItem(sessionId) -- 2128
			emitAgentSessionPatch( -- 2129
				sessionId, -- 2129
				{ -- 2129
					session = startedSession, -- 2130
					metrics = metrics, -- 2131
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2132
				} -- 2132
			) -- 2132
			break -- 2136
		end -- 2136
		____cond390 = ____cond390 or ____switch390 == "decision_made" -- 2136
		if ____cond390 then -- 2136
			upsertStep( -- 2138
				sessionId, -- 2138
				event.taskId, -- 2138
				event.step, -- 2138
				event.tool, -- 2138
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 2138
			) -- 2138
			emitAgentSessionPatch( -- 2146
				sessionId, -- 2146
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2146
			) -- 2146
			break -- 2149
		end -- 2149
		____cond390 = ____cond390 or ____switch390 == "tool_started" -- 2149
		if ____cond390 then -- 2149
			upsertStep( -- 2151
				sessionId, -- 2151
				event.taskId, -- 2151
				event.step, -- 2151
				event.tool, -- 2151
				{status = "RUNNING"} -- 2151
			) -- 2151
			emitAgentSessionPatch( -- 2154
				sessionId, -- 2154
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2154
			) -- 2154
			break -- 2157
		end -- 2157
		____cond390 = ____cond390 or ____switch390 == "tool_finished" -- 2157
		if ____cond390 then -- 2157
			do -- 2157
				upsertStep( -- 2159
					sessionId, -- 2159
					event.taskId, -- 2159
					event.step, -- 2159
					event.tool, -- 2159
					{status = event.execution.status, reason = event.reason, result = event.result} -- 2159
				) -- 2159
				emitAgentSessionPatch( -- 2167
					sessionId, -- 2167
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2167
				) -- 2167
				break -- 2170
			end -- 2170
		end -- 2170
		____cond390 = ____cond390 or ____switch390 == "tool_progress" -- 2170
		if ____cond390 then -- 2170
			do -- 2170
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 2174
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 2174
					break -- 2176
				end -- 2176
			end -- 2176
			upsertStep( -- 2179
				sessionId, -- 2179
				event.taskId, -- 2179
				event.step, -- 2179
				event.tool, -- 2179
				{status = "RUNNING", result = event.result} -- 2179
			) -- 2179
			emitAgentSessionPatch( -- 2183
				sessionId, -- 2183
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2183
			) -- 2183
			break -- 2186
		end -- 2186
		____cond390 = ____cond390 or ____switch390 == "checkpoint_created" -- 2186
		if ____cond390 then -- 2186
			upsertStep( -- 2188
				sessionId, -- 2188
				event.taskId, -- 2188
				event.step, -- 2188
				event.tool, -- 2188
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2188
			) -- 2188
			emitAgentSessionPatch( -- 2193
				sessionId, -- 2193
				{ -- 2193
					step = getStepItem(sessionId, event.taskId, event.step), -- 2194
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2195
				} -- 2195
			) -- 2195
			break -- 2197
		end -- 2197
		____cond390 = ____cond390 or ____switch390 == "memory_compression_started" -- 2197
		if ____cond390 then -- 2197
			upsertStep( -- 2199
				sessionId, -- 2199
				event.taskId, -- 2199
				event.step, -- 2199
				event.tool, -- 2199
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2199
			) -- 2199
			emitAgentSessionPatch( -- 2204
				sessionId, -- 2204
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2204
			) -- 2204
			break -- 2207
		end -- 2207
		____cond390 = ____cond390 or ____switch390 == "memory_compression_finished" -- 2207
		if ____cond390 then -- 2207
			upsertStep( -- 2209
				sessionId, -- 2209
				event.taskId, -- 2209
				event.step, -- 2209
				event.tool, -- 2209
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2209
			) -- 2209
			emitAgentSessionPatch( -- 2214
				sessionId, -- 2214
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2214
			) -- 2214
			break -- 2217
		end -- 2217
		____cond390 = ____cond390 or ____switch390 == "metrics_updated" -- 2217
		if ____cond390 then -- 2217
			do -- 2217
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2219
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2220
				break -- 2223
			end -- 2223
		end -- 2223
		____cond390 = ____cond390 or ____switch390 == "assistant_message_updated" -- 2223
		if ____cond390 then -- 2223
			do -- 2223
				local session = getSessionItem(sessionId) -- 2226
				if (session and session.currentTaskId) ~= event.taskId then -- 2226
					streamUpdates:clear(sessionId, event.taskId) -- 2228
					break -- 2228
				end -- 2228
				streamUpdates:update( -- 2230
					sessionId, -- 2230
					event.taskId, -- 2230
					event.step, -- 2230
					event, -- 2230
					App.runningTime -- 2230
				) -- 2230
				scheduleStreamFlush() -- 2231
				break -- 2232
			end -- 2232
		end -- 2232
		____cond390 = ____cond390 or ____switch390 == "assistant_message_finished" -- 2232
		if ____cond390 then -- 2232
			do -- 2232
				local ____opt_75 = getSessionItem(sessionId) -- 2232
				if (____opt_75 and ____opt_75.currentTaskId) ~= event.taskId then -- 2232
					streamUpdates:clear(sessionId, event.taskId) -- 2236
					break -- 2236
				end -- 2236
				streamUpdates:finish(sessionId, event.taskId, event.step) -- 2238
				upsertStep( -- 2239
					sessionId, -- 2239
					event.taskId, -- 2239
					event.step, -- 2239
					"message", -- 2239
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2239
				) -- 2239
				emitAgentSessionPatch( -- 2245
					sessionId, -- 2245
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2245
				) -- 2245
				break -- 2248
			end -- 2248
		end -- 2248
		____cond390 = ____cond390 or ____switch390 == "task_waiting_for_user" -- 2248
		if ____cond390 then -- 2248
			do -- 2248
				local ____opt_77 = getSessionItem(sessionId) -- 2248
				if (____opt_77 and ____opt_77.currentTaskId) ~= event.taskId then -- 2248
					streamUpdates:clear(sessionId, event.taskId) -- 2252
					break -- 2252
				end -- 2252
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2254
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2255
				__TS__Delete(activeStopTokens, event.taskId) -- 2256
				emitAgentSessionPatch( -- 2257
					sessionId, -- 2257
					{ -- 2257
						session = getSessionItem(sessionId), -- 2258
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2259
					} -- 2259
				) -- 2259
				break -- 2261
			end -- 2261
		end -- 2261
		____cond390 = ____cond390 or ____switch390 == "task_finished" -- 2261
		if ____cond390 then -- 2261
			do -- 2261
				local session = getSessionItem(sessionId) -- 2264
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2264
					__TS__Delete(activeStopTokens, event.taskId) -- 2266
					streamUpdates:clear(sessionId, event.taskId) -- 2267
					Log( -- 2268
						"Info", -- 2268
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2268
					) -- 2268
					break -- 2269
				end -- 2269
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2271
				local ____opt_79 = activeStopTokens[event.taskId or -1] -- 2271
				local stopped = (____opt_79 and ____opt_79.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2272
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2274
				local isSubSession = (session and session.kind) == "sub" -- 2277
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2278
				if isSubSession and event.taskId ~= nil then -- 2278
					finalizingSubSessionTaskIds[event.taskId] = true -- 2280
				end -- 2280
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2282
				if event.taskId ~= nil then -- 2282
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2284
					local ____finalizeTaskSteps_85 = finalizeTaskSteps -- 2285
					local ____array_84 = __TS__SparseArrayNew( -- 2285
						sessionId, -- 2286
						event.taskId, -- 2287
						type(event.steps) == "number" and math.max( -- 2288
							0, -- 2288
							math.floor(event.steps) -- 2288
						) or nil -- 2288
					) -- 2288
					local ____event_success_83 -- 2289
					if event.success then -- 2289
						____event_success_83 = nil -- 2289
					else -- 2289
						____event_success_83 = stopped and "STOPPED" or "FAILED" -- 2289
					end -- 2289
					__TS__SparseArrayPush(____array_84, ____event_success_83) -- 2289
					____finalizeTaskSteps_85(__TS__SparseArraySpread(____array_84)) -- 2285
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2291
					if not isSubSession then -- 2291
						__TS__Delete(activeStopTokens, event.taskId) -- 2293
					end -- 2293
					emitAgentSessionPatch( -- 2295
						sessionId, -- 2295
						{ -- 2295
							session = getSessionItem(sessionId), -- 2296
							message = getMessageItem(messageId), -- 2297
							removedStepIds = removedStepIds -- 2298
						} -- 2298
					) -- 2298
				end -- 2298
				if session and session.kind == "main" then -- 2298
					flushPendingSubAgentHandoffs(session) -- 2302
				end -- 2302
				break -- 2304
			end -- 2304
		end -- 2304
	until true -- 2304
end -- 2304
function ____exports.createSession(projectRoot, title) -- 2309
	if title == nil then -- 2309
		title = "" -- 2309
	end -- 2309
	local storage = requireAgentStorage() -- 2310
	if not storage.success then -- 2310
		return storage -- 2311
	end -- 2311
	if not isValidProjectRoot(projectRoot) then -- 2311
		return {success = false, message = "invalid projectRoot"} -- 2313
	end -- 2313
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2315
	if row then -- 2315
		return { -- 2324
			success = true, -- 2324
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2324
		} -- 2324
	end -- 2324
	local t = now() -- 2326
	DB:exec( -- 2327
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2327
		{ -- 2330
			projectRoot, -- 2330
			title ~= "" and title or Path:getFilename(projectRoot), -- 2330
			t, -- 2330
			t -- 2330
		} -- 2330
	) -- 2330
	local sessionId = getLastInsertRowId() -- 2332
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2333
	local session = getSessionItem(sessionId) -- 2334
	if not session then -- 2334
		return {success = false, message = "failed to create session"} -- 2336
	end -- 2336
	return {success = true, session = session} -- 2338
end -- 2309
function ____exports.createSubSession(parentSessionId, title) -- 2341
	if title == nil then -- 2341
		title = "" -- 2341
	end -- 2341
	local storage = requireAgentStorage() -- 2342
	if not storage.success then -- 2342
		return storage -- 2343
	end -- 2343
	local parent = getSessionItem(parentSessionId) -- 2344
	if not parent then -- 2344
		return {success = false, message = "parent session not found"} -- 2346
	end -- 2346
	local rootId = getSessionRootId(parent) -- 2348
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2348
		return {success = false, message = "project task admission is closed"} -- 2349
	end -- 2349
	local t = now() -- 2350
	DB:exec( -- 2351
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2351
		{ -- 2354
			parent.projectRoot, -- 2354
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2354
			rootId, -- 2354
			parent.id, -- 2354
			t, -- 2354
			t -- 2354
		} -- 2354
	) -- 2354
	local sessionId = getLastInsertRowId() -- 2356
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2357
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2358
	local session = getSessionItem(sessionId) -- 2359
	if not session then -- 2359
		return {success = false, message = "failed to create sub session"} -- 2361
	end -- 2361
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2363
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2364
	subStorage:writeMemory(parentStorage:readMemory()) -- 2365
	return {success = true, session = session} -- 2366
end -- 2341
function spawnSubAgentSession(request) -- 2369
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2369
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2382
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2383
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2384
		if normalizedPrompt == "" then -- 2384
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2386
		end -- 2386
		if normalizedPrompt == "" then -- 2386
			local ____Log_91 = Log -- 2393
			local ____temp_88 = #normalizedTitle -- 2393
			local ____temp_89 = #rawPrompt -- 2393
			local ____temp_90 = #toStr(request.expectedOutput) -- 2393
			local ____opt_86 = request.filesHint -- 2393
			____Log_91( -- 2393
				"Warn", -- 2393
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_88)) .. " raw_prompt_len=") .. tostring(____temp_89)) .. " expected_len=") .. tostring(____temp_90)) .. " files_hint_count=") .. tostring(____opt_86 and #____opt_86 or 0) -- 2393
			) -- 2393
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2393
		end -- 2393
		Log( -- 2396
			"Info", -- 2396
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2396
		) -- 2396
		local parentSessionId = request.parentSessionId -- 2397
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2397
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2399
			if not fallbackParent then -- 2399
				local createdMain = ____exports.createSession(request.projectRoot) -- 2401
				if createdMain.success then -- 2401
					fallbackParent = createdMain.session -- 2403
				end -- 2403
			end -- 2403
			if fallbackParent then -- 2403
				Log( -- 2407
					"Warn", -- 2407
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2407
				) -- 2407
				parentSessionId = fallbackParent.id -- 2408
			end -- 2408
		end -- 2408
		local parentSession = getSessionItem(parentSessionId) -- 2411
		if not parentSession then -- 2411
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2411
		end -- 2411
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2415
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2415
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2415
		end -- 2415
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2415
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2415
		end -- 2415
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2420
		if not created.success then -- 2420
			return ____awaiter_resolve(nil, created) -- 2420
		end -- 2420
		writeSpawnInfo( -- 2424
			created.session.projectRoot, -- 2424
			created.session.memoryScope, -- 2424
			{ -- 2424
				sessionId = created.session.id, -- 2425
				rootSessionId = created.session.rootSessionId, -- 2426
				parentSessionId = created.session.parentSessionId, -- 2427
				title = created.session.title, -- 2428
				prompt = normalizedPrompt, -- 2429
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2430
				expectedOutput = request.expectedOutput or "", -- 2431
				filesHint = request.filesHint or ({}), -- 2432
				status = "RUNNING", -- 2433
				success = false, -- 2434
				resultFilePath = "", -- 2435
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2436
				sourceTaskId = 0, -- 2437
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2438
				createdAtTs = created.session.createdAt, -- 2439
				finishedAt = "", -- 2440
				finishedAtTs = 0 -- 2441
			} -- 2441
		) -- 2441
		local sent = ____exports.sendPrompt( -- 2443
			created.session.id, -- 2443
			normalizedPrompt, -- 2443
			request.disabledAgentTools, -- 2443
			nil, -- 2443
			nil, -- 2443
			request.llmConfig -- 2443
		) -- 2443
		if not sent.success then -- 2443
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2443
		end -- 2443
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2443
	end) -- 2443
end -- 2443
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2567
	local rootSession = getRootSessionItem(session.id) -- 2568
	if not rootSession then -- 2568
		return -- 2569
	end -- 2569
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2570
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2571
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2572
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2573
	local queueResult = writePendingHandoff( -- 2574
		rootSession.projectRoot, -- 2574
		rootSession.memoryScope, -- 2574
		{ -- 2574
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2575
			sourceSessionId = session.id, -- 2576
			sourceTitle = session.title, -- 2577
			sourceTaskId = taskId, -- 2578
			message = summary, -- 2579
			prompt = result.prompt, -- 2580
			goal = result.goal, -- 2581
			expectedOutput = result.expectedOutput or "", -- 2582
			filesHint = result.filesHint or ({}), -- 2583
			success = result.success, -- 2584
			resultFilePath = result.resultFilePath, -- 2585
			artifactDir = result.artifactDir, -- 2586
			finishedAt = result.finishedAt, -- 2587
			changeSet = changeSet, -- 2588
			handoffEvidence = result.handoffEvidence, -- 2589
			memoryEntry = result.memoryEntry, -- 2590
			completion = result.completion, -- 2591
			createdAt = createdAt -- 2592
		} -- 2592
	) -- 2592
	if not queueResult then -- 2592
		Log( -- 2595
			"Warn", -- 2595
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2595
		) -- 2595
		return -- 2596
	end -- 2596
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2596
		addTaskReference(rootSession.currentTaskId, taskId) -- 2599
	end -- 2599
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2599
		flushPendingSubAgentHandoffs(rootSession) -- 2602
	end -- 2602
end -- 2602
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2606
	if forceHandoff == nil then -- 2606
		forceHandoff = false -- 2612
	end -- 2612
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2612
		local rootSessionId = getSessionRootId(session) -- 2614
		local rootSession = getRootSessionItem(session.id) -- 2615
		if not rootSession then -- 2615
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2615
		end -- 2615
		local spawnInfo = getSessionSpawnInfo(session) -- 2619
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2620
		local finishedAtTs = now() -- 2621
		local resultText = sanitizeUTF8(message) -- 2622
		local changeSet = getTaskChangeSetSummary(taskId) -- 2623
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2624
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2625
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2629
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2629
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2631
		end -- 2631
		local completed = success and completionReport.outcome == "completed" -- 2639
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2640
		local record = { -- 2643
			sessionId = session.id, -- 2644
			rootSessionId = rootSessionId, -- 2645
			parentSessionId = session.parentSessionId, -- 2646
			title = session.title, -- 2647
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2648
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2649
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2650
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2651
			status = recordStatus, -- 2652
			success = completed, -- 2653
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2654
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2655
			sourceTaskId = taskId, -- 2656
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2657
			finishedAt = finishedAt, -- 2658
			createdAtTs = session.createdAt, -- 2659
			finishedAtTs = finishedAtTs, -- 2660
			changeSet = changeSet, -- 2661
			handoffEvidence = handoffEvidence, -- 2662
			completion = completionReport -- 2663
		} -- 2663
		local ____record_success_110 -- 2665
		if record.success then -- 2665
			____record_success_110 = buildStructuredSubAgentMemoryEntry(record) -- 2665
		else -- 2665
			____record_success_110 = nil -- 2665
		end -- 2665
		record.memoryEntry = ____record_success_110 -- 2665
		if not writeSubAgentResultFile(session, record, resultText) then -- 2665
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2665
		end -- 2665
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2665
			sessionId = record.sessionId, -- 2670
			rootSessionId = record.rootSessionId, -- 2671
			parentSessionId = record.parentSessionId, -- 2672
			title = record.title, -- 2673
			prompt = record.prompt, -- 2674
			goal = record.goal, -- 2675
			expectedOutput = record.expectedOutput or "", -- 2676
			filesHint = record.filesHint or ({}), -- 2677
			status = record.status, -- 2678
			success = record.success, -- 2679
			resultFilePath = record.resultFilePath, -- 2680
			artifactDir = record.artifactDir, -- 2681
			sourceTaskId = record.sourceTaskId, -- 2682
			createdAt = record.createdAt, -- 2683
			finishedAt = record.finishedAt, -- 2684
			createdAtTs = record.createdAtTs, -- 2685
			finishedAtTs = record.finishedAtTs, -- 2686
			changeSet = record.changeSet, -- 2687
			handoffEvidence = record.handoffEvidence, -- 2688
			memoryEntry = record.memoryEntry, -- 2689
			memoryEntryError = record.memoryEntryError, -- 2690
			completion = record.completion -- 2691
		}) then -- 2691
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2691
		end -- 2691
		if success or forceHandoff then -- 2691
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2696
			deleteSessionRecords(session.id, true) -- 2697
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2698
		end -- 2698
		return ____awaiter_resolve(nil, {success = true}) -- 2698
	end) -- 2698
end -- 2698
function stopClearedSubSession(session, taskId) -- 2703
	local spawnInfo = getSessionSpawnInfo(session) -- 2704
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2705
	local rootSessionId = getSessionRootId(session) -- 2706
	Tools.setTaskStatus(taskId, "STOPPED") -- 2707
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2708
	if not writeSpawnInfo( -- 2708
		session.projectRoot, -- 2709
		session.memoryScope, -- 2709
		{ -- 2709
			sessionId = session.id, -- 2710
			rootSessionId = rootSessionId, -- 2711
			parentSessionId = session.parentSessionId, -- 2712
			title = session.title, -- 2713
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2714
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2715
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2716
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2717
			status = "STOPPED", -- 2718
			success = false, -- 2719
			cleared = true, -- 2720
			resultFilePath = "", -- 2721
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2722
			sourceTaskId = taskId, -- 2723
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2724
			finishedAt = finishedAt, -- 2725
			createdAtTs = session.createdAt, -- 2726
			finishedAtTs = now() -- 2727
		} -- 2727
	) then -- 2727
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2729
	end -- 2729
	deleteSessionRecords(session.id, true) -- 2731
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2732
	return {success = true} -- 2733
end -- 2733
function startImmediatePrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, inputId) -- 2736
	local session = getSessionItem(sessionId) -- 2737
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2737
		return {success = false, message = "project task admission is closed"} -- 2738
	end -- 2738
	if not session then -- 2738
		return {success = false, message = "session not found"} -- 2740
	end -- 2740
	if getPendingQuestionnaire(sessionId) then -- 2740
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2742
	end -- 2742
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2742
		return {success = false, message = "session task is finalizing"} -- 2744
	end -- 2744
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2744
		return {success = false, message = "session task is still running"} -- 2747
	end -- 2747
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2749
	if normalizedPrompt == "" and session.kind == "sub" then -- 2749
		local spawnInfo = getSessionSpawnInfo(session) -- 2751
		if spawnInfo then -- 2751
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2753
			if normalizedPrompt == "" then -- 2753
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2755
			end -- 2755
		end -- 2755
	end -- 2755
	if normalizedPrompt == "" then -- 2755
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
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2771
	return startPromptTask( -- 2772
		session, -- 2772
		normalizedPrompt, -- 2772
		nil, -- 2772
		normalizeDisabledAgentTools(disabledAgentTools), -- 2772
		{ -- 2772
			workMode = nextWorkMode, -- 2772
			llmConfigId = llmConfigId, -- 2772
			llmConfig = llmConfig, -- 2772
			maxSteps = boundedMaxSteps, -- 2772
			inputId = inputId -- 2772
		} -- 2772
	) -- 2772
end -- 2772
function startLocalPrompt(sessionId, prompt, localAgentConfigId, inputId) -- 2775
	local session = getSessionItem(sessionId) -- 2776
	if not session then -- 2776
		return {success = false, message = "session not found"} -- 2777
	end -- 2777
	if session.kind ~= "main" then -- 2777
		return {success = false, message = "local Agent only supports main sessions"} -- 2778
	end -- 2778
	if getPendingQuestionnaire(sessionId) then -- 2778
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2779
	end -- 2779
	if session.currentTaskStatus == "RUNNING" then -- 2779
		return {success = false, message = "session task is still running"} -- 2780
	end -- 2780
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2781
	if normalizedPrompt == "" then -- 2781
		return {success = false, message = "prompt is empty"} -- 2782
	end -- 2782
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2783
	if not config then -- 2783
		return {success = false, message = "local Agent config not found"} -- 2784
	end -- 2784
	if not config.verifiedAt then -- 2784
		return {success = false, message = "local Agent config is not verified"} -- 2785
	end -- 2785
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2786
	if not taskRes.success then -- 2786
		return taskRes -- 2787
	end -- 2787
	local taskId = taskRes.taskId -- 2788
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2789
	if inputId ~= nil then -- 2789
		InputInbox.markDelivering(inputId, taskId) -- 2790
		InputInbox.markDelivered(inputId, messageId) -- 2790
	end -- 2790
	followup.activeRuns[sessionId] = taskId -- 2791
	Tools.setTaskStatus(taskId, "RUNNING") -- 2792
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2793
	upsertStep( -- 2794
		session.id, -- 2794
		taskId, -- 2794
		1, -- 2794
		"local_agent_message", -- 2794
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2794
	) -- 2794
	emitAgentSessionPatch( -- 2800
		session.id, -- 2800
		{ -- 2800
			session = getSessionItem(session.id), -- 2801
			message = getMessageItem(messageId), -- 2802
			step = getStepItem(session.id, taskId, 1) -- 2803
		} -- 2803
	) -- 2803
	local events = {} -- 2805
	local transcript = "" -- 2806
	local assistant = "" -- 2807
	local lastFlush = 0 -- 2808
	local function flush(force) -- 2809
		if force == nil then -- 2809
			force = false -- 2809
		end -- 2809
		if not force and App.runningTime - lastFlush < 0.075 then -- 2809
			return -- 2810
		end -- 2810
		lastFlush = App.runningTime -- 2811
		if #events > 400 then -- 2811
			events = __TS__ArraySlice(events, #events - 400) -- 2812
		end -- 2812
		if #transcript > 1024 * 1024 then -- 2812
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2813
		end -- 2813
		upsertStep( -- 2814
			session.id, -- 2814
			taskId, -- 2814
			1, -- 2814
			"local_agent_message", -- 2814
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2814
		) -- 2814
		local message -- 2819
		if assistant ~= "" then -- 2819
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2821
			message = getMessageItem(assistantId) -- 2822
		end -- 2822
		emitAgentSessionPatch( -- 2824
			session.id, -- 2824
			__TS__ObjectAssign( -- 2824
				{step = getStepItem(session.id, taskId, 1)}, -- 2824
				message and ({message = message}) or ({}) -- 2824
			) -- 2824
		) -- 2824
	end -- 2809
	local completedSynchronously = false -- 2826
	local control = LocalAgent.run( -- 2827
		session.id, -- 2827
		config, -- 2827
		session.projectRoot, -- 2827
		normalizedPrompt, -- 2827
		function(event) -- 2827
			local text = sanitizeUTF8(event.text) -- 2828
			if text == "" then -- 2828
				return -- 2829
			end -- 2829
			local previous = #events > 0 and events[#events] or nil -- 2830
			if previous and previous.kind == event.kind and previous.text == text then -- 2830
				return -- 2831
			end -- 2831
			events[#events + 1] = {kind = event.kind, text = text} -- 2832
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2833
			if event.kind == "assistant" then -- 2833
				assistant = text -- 2834
			end -- 2834
			flush(false) -- 2835
		end, -- 2827
		function(result) -- 2836
			completedSynchronously = true -- 2837
			flush(true) -- 2838
			__TS__Delete(activeLocalAgentControls, taskId) -- 2839
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2840
			Tools.setTaskStatus(taskId, status) -- 2841
			setSessionState(session.id, status, taskId, status) -- 2842
			upsertStep( -- 2843
				session.id, -- 2843
				taskId, -- 2843
				1, -- 2843
				"local_agent_message", -- 2843
				{status = status, reason = config.name .. " · full permissions", result = { -- 2843
					provider = config.provider, -- 2846
					events = events, -- 2846
					transcript = transcript, -- 2846
					exitCode = result.exitCode, -- 2846
					resumeId = result.resumeId, -- 2846
					message = result.message -- 2846
				}} -- 2846
			) -- 2846
			emitAgentSessionPatch( -- 2848
				session.id, -- 2848
				{ -- 2848
					session = getSessionItem(session.id), -- 2848
					step = getStepItem(session.id, taskId, 1) -- 2848
				} -- 2848
			) -- 2848
			followup.settle(sessionId, taskId, result.success and not result.stopped) -- 2849
		end -- 2836
	) -- 2836
	if not completedSynchronously then -- 2836
		activeLocalAgentControls[taskId] = control -- 2851
	end -- 2851
	return {success = true, sessionId = session.id, taskId = taskId} -- 2852
end -- 2852
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2910
	if disabledAgentTools == nil then -- 2910
		disabledAgentTools = {} -- 2914
	end -- 2914
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2917
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2917
		return {success = false, message = "project task admission is closed"} -- 2918
	end -- 2918
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2919
	if not llmConfigRes.success then -- 2919
		return {success = false, message = llmConfigRes.message} -- 2923
	end -- 2923
	local llmConfig = llmConfigRes.config -- 2925
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2926
	if not llmConfigValidation.success then -- 2926
		return llmConfigValidation -- 2928
	end -- 2928
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2930
	if not taskRes.success then -- 2930
		return {success = false, message = taskRes.message} -- 2933
	end -- 2933
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2933
		removeContinuableTaskSummary(session) -- 2935
	end -- 2935
	local taskId = taskRes.taskId -- 2937
	if (options and options.inputId) ~= nil then -- 2937
		InputInbox.markDelivering(options.inputId, taskId) -- 2938
	end -- 2938
	followup.activeRuns[session.id] = taskId -- 2939
	local ____temp_133 -- 2940
	if (options and options.existingTaskId) == nil then -- 2940
		____temp_133 = session.currentTaskId -- 2940
	else -- 2940
		____temp_133 = nil -- 2940
	end -- 2940
	local previousTaskId = ____temp_133 -- 2940
	local useChineseResponse = getDefaultUseChineseResponse() -- 2941
	local promptMessageId -- 2942
	if existingUserMessageId ~= nil then -- 2942
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2944
		promptMessageId = existingUserMessageId -- 2945
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2945
		promptMessageId = insertMessage( -- 2947
			session.id, -- 2947
			"user", -- 2947
			normalizedPrompt, -- 2947
			taskId, -- 2947
			options and options.displayContent -- 2947
		) -- 2947
	end -- 2947
	if (options and options.inputId) ~= nil and promptMessageId ~= nil then -- 2947
		if DB:exec("UPDATE agent.AgentSessionInput SET message_id=? WHERE id=?", {promptMessageId, options.inputId}) < 0 then -- 2947
			error( -- 2950
				__TS__New(Error, "failed to link input display"), -- 2950
				0 -- 2950
			) -- 2950
		end -- 2950
		if normalizedPrompt == "/clear" or normalizedPrompt == "/compact" then -- 2950
			InputInbox.markDelivered(options.inputId, promptMessageId) -- 2951
		end -- 2951
	end -- 2951
	local stopToken = {stopped = false} -- 2953
	activeStopTokens[taskId] = stopToken -- 2954
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2955
	emitAgentSessionPatch( -- 2959
		session.id, -- 2959
		__TS__ObjectAssign( -- 2959
			{session = getSessionItem(session.id)}, -- 2959
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 2961
		) -- 2961
	) -- 2961
	if previousTaskId and previousTaskId ~= taskId then -- 2961
		cleanupTaskHeavyData(previousTaskId) -- 2964
	end -- 2964
	activePromptRuns = activePromptRuns + 1 -- 2966
	local ____runCodingAgent_168 = runCodingAgent -- 2967
	local ____normalizedPrompt_159 = normalizedPrompt -- 2968
	local ____temp_160 = options and options.inputId -- 2969
	local ____temp_161 = { -- 2970
		pending = function() return __TS__ArrayMap( -- 2971
			__TS__ArrayFilter( -- 2971
				InputInbox.listInputs(session.id), -- 2971
				function(____, item) return item.delivery == "steer" and not item.held and item.status == "pending" end -- 2971
			), -- 2971
			function(____, item) return {id = item.id, content = item.content} end -- 2971
		) end, -- 2971
		delivered = function(id, step) return followup.delivered(session.id, taskId, id, step) end -- 2972
	} -- 2972
	local ____temp_162 = options and options.resumeConversation -- 2974
	local ____temp_163 = (options and options.existingTaskId) ~= nil -- 2975
	local ____temp_164 = options and options.initialStep -- 2976
	local ____temp_165 = options and options.initialAgentStepCount -- 2977
	local ____temp_154 -- 2978
	if (options and options.existingTaskId) ~= nil then -- 2978
		____temp_154 = getInitialTokenUsage(session) -- 2978
	else -- 2978
		____temp_154 = nil -- 2978
	end -- 2978
	____runCodingAgent_168( -- 2967
		{ -- 2967
			prompt = ____normalizedPrompt_159, -- 2968
			inputId = ____temp_160, -- 2969
			inputSource = ____temp_161, -- 2970
			resumeConversation = ____temp_162, -- 2974
			resumeTask = ____temp_163, -- 2975
			initialStep = ____temp_164, -- 2976
			initialAgentStepCount = ____temp_165, -- 2977
			initialTokenUsage = ____temp_154, -- 2978
			workDir = session.projectRoot, -- 2979
			useChineseResponse = useChineseResponse, -- 2980
			taskId = taskId, -- 2981
			sessionId = session.id, -- 2982
			memoryScope = session.memoryScope, -- 2983
			role = session.kind, -- 2984
			maxSteps = options and options.maxSteps, -- 2985
			disabledAgentTools = disabledAgentTools, -- 2986
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 2987
			llmConfig = llmConfig, -- 2988
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 2989
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 2992
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 2995
			stopToken = stopToken, -- 2996
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 2997
		}, -- 2997
		function(result) -- 2998
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2998
				local ____hasReturned, ____returnValue -- 2998
				local ____try = __TS__AsyncAwaiter(function() -- 2998
					local nextSession = getSessionItem(session.id) -- 3000
					if nextSession and nextSession.kind == "sub" then -- 3000
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 3000
							local stopped = stopClearedSubSession(nextSession, taskId) -- 3003
							if not stopped.success then -- 3003
								Log( -- 3005
									"Warn", -- 3005
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 3005
								) -- 3005
								emitAgentSessionPatch( -- 3006
									session.id, -- 3006
									{session = getSessionItem(session.id)} -- 3006
								) -- 3006
							end -- 3006
							__TS__Delete(activeStopTokens, taskId) -- 3010
							____hasReturned = true -- 3011
							return -- 3011
						end -- 3011
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3013
						emitAgentSessionPatch( -- 3014
							session.id, -- 3014
							{session = getSessionItem(session.id)} -- 3014
						) -- 3014
						local finalized = __TS__Await(finalizeSubSession( -- 3017
							nextSession, -- 3018
							taskId, -- 3019
							result.success, -- 3020
							result.message, -- 3021
							result.completion, -- 3022
							(options and options.forceSubAgentHandoff) == true -- 3023
						)) -- 3023
						if not finalized.success then -- 3023
							Log( -- 3026
								"Warn", -- 3026
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 3026
							) -- 3026
						end -- 3026
						local finalizedSession = getSessionItem(session.id) -- 3028
						if finalizedSession then -- 3028
							local stopped = stopToken.stopped == true -- 3030
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 3031
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 3034
							emitAgentSessionPatch( -- 3035
								session.id, -- 3035
								{session = getSessionItem(session.id)} -- 3035
							) -- 3035
						end -- 3035
						__TS__Delete(activeStopTokens, taskId) -- 3039
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 3040
					end -- 3040
					local fallbackSession = getSessionItem(session.id) -- 3042
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 3042
						applyEvent(session.id, { -- 3048
							type = "task_finished", -- 3049
							sessionId = session.id, -- 3050
							taskId = result.taskId, -- 3051
							success = false, -- 3052
							message = result.message, -- 3053
							steps = result.steps -- 3054
						}) -- 3054
					end -- 3054
				end) -- 3054
				____try = ____try.finally( -- 3054
					____try, -- 3054
					function() -- 3054
						return __TS__AsyncAwaiter(function() -- 3054
							activePromptRuns = activePromptRuns - 1 -- 3058
							followup.settle(session.id, taskId, result.success and not result.waitingForUser and not stopToken.stopped) -- 3059
						end) -- 3059
					end -- 3059
				) -- 3059
				__TS__Await(____try) -- 2999
				if ____hasReturned then -- 2999
					return ____awaiter_resolve(nil, ____returnValue) -- 2999
				end -- 2999
			end) -- 2999
		end -- 2998
	) -- 2998
	return {success = true, sessionId = session.id, taskId = taskId} -- 3062
end -- 3062
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3217
	local lines = {} -- 3218
	do -- 3218
		local i = 0 -- 3219
		while i < #questionnaire.schema.questions do -- 3219
			local question = questionnaire.schema.questions[i + 1] -- 3220
			local answer = __TS__ArrayFind( -- 3221
				answers, -- 3221
				function(____, item) return item.questionId == question.id end -- 3221
			) -- 3221
			local answerText = "已跳过" -- 3222
			if answer and answer.status == "answered" then -- 3222
				local parts = {} -- 3224
				do -- 3224
					local j = 0 -- 3225
					while j < #(answer.selectedOptionIds or ({})) do -- 3225
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3226
						local option = __TS__ArrayFind( -- 3227
							question.options or ({}), -- 3227
							function(____, item) return item.id == optionId end -- 3227
						) -- 3227
						if option then -- 3227
							parts[#parts + 1] = option.label -- 3228
						end -- 3228
						j = j + 1 -- 3225
					end -- 3225
				end -- 3225
				if answer.otherText then -- 3225
					parts[#parts + 1] = answer.otherText -- 3230
				end -- 3230
				if answer.text then -- 3230
					parts[#parts + 1] = answer.text -- 3231
				end -- 3231
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3232
			end -- 3232
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3234
			i = i + 1 -- 3219
		end -- 3219
	end -- 3219
	return table.concat(lines, "\n\n") -- 3236
end -- 3236
function ____exports.listRunningSubAgents(request) -- 3523
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3523
		local session = getSessionItem(request.sessionId) -- 3531
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3531
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3533
		end -- 3533
		if not session then -- 3533
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3533
		end -- 3533
		local rootSession = getRootSessionItem(session.id) -- 3538
		if not rootSession then -- 3538
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3538
		end -- 3538
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3542
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3543
		local limit = math.max( -- 3544
			1, -- 3544
			math.floor(tonumber(request.limit) or 5) -- 3544
		) -- 3544
		local offset = math.max( -- 3545
			0, -- 3545
			math.floor(tonumber(request.offset) or 0) -- 3545
		) -- 3545
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3546
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3547
		local runningSessions = {} -- 3554
		do -- 3554
			local i = 0 -- 3555
			while i < #rows do -- 3555
				do -- 3555
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3556
					if current.currentTaskStatus ~= "RUNNING" then -- 3556
						goto __continue645 -- 3558
					end -- 3558
					local spawnInfo = getSessionSpawnInfo(current) -- 3560
					runningSessions[#runningSessions + 1] = { -- 3561
						sessionId = current.id, -- 3562
						title = current.title, -- 3563
						parentSessionId = current.parentSessionId, -- 3564
						rootSessionId = current.rootSessionId, -- 3565
						status = "RUNNING", -- 3566
						currentTaskId = current.currentTaskId, -- 3567
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3568
						goal = spawnInfo and spawnInfo.goal, -- 3569
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3570
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3571
						createdAt = current.createdAt, -- 3572
						updatedAt = current.updatedAt -- 3573
					} -- 3573
				end -- 3573
				::__continue645:: -- 3573
				i = i + 1 -- 3555
			end -- 3555
		end -- 3555
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3576
		local completedSessions = __TS__ArrayMap( -- 3577
			completedRecords, -- 3577
			function(____, record) return { -- 3577
				sessionId = record.sessionId, -- 3578
				title = record.title, -- 3579
				parentSessionId = record.parentSessionId, -- 3580
				rootSessionId = record.rootSessionId, -- 3581
				status = record.status, -- 3582
				goal = record.goal, -- 3583
				expectedOutput = record.expectedOutput, -- 3584
				filesHint = record.filesHint, -- 3585
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3586
				success = record.success, -- 3587
				cleared = record.cleared, -- 3588
				resultFilePath = record.resultFilePath, -- 3589
				artifactDir = record.artifactDir, -- 3590
				finishedAt = record.finishedAt, -- 3591
				createdAt = record.createdAtTs, -- 3592
				updatedAt = record.finishedAtTs -- 3593
			} end -- 3593
		) -- 3593
		local merged = {} -- 3595
		if status == "running" then -- 3595
			merged = runningSessions -- 3597
		elseif status == "done" then -- 3597
			merged = __TS__ArrayFilter( -- 3599
				completedSessions, -- 3599
				function(____, item) return item.status == "DONE" end -- 3599
			) -- 3599
		elseif status == "failed" then -- 3599
			merged = __TS__ArrayFilter( -- 3601
				completedSessions, -- 3601
				function(____, item) return item.status == "FAILED" end -- 3601
			) -- 3601
		elseif status == "stopped" then -- 3601
			merged = __TS__ArrayFilter( -- 3603
				completedSessions, -- 3603
				function(____, item) return item.status == "STOPPED" end -- 3603
			) -- 3603
		elseif status == "all" then -- 3603
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3605
		else -- 3605
			local runningKeys = {} -- 3607
			do -- 3607
				local i = 0 -- 3608
				while i < #runningSessions do -- 3608
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3609
					i = i + 1 -- 3608
				end -- 3608
			end -- 3608
			local latestCompletedByKey = {} -- 3611
			do -- 3611
				local i = 0 -- 3612
				while i < #completedSessions do -- 3612
					do -- 3612
						local item = completedSessions[i + 1] -- 3613
						local key = getSubAgentDisplayKey(item) -- 3614
						if runningKeys[key] then -- 3614
							goto __continue660 -- 3616
						end -- 3616
						local current = latestCompletedByKey[key] -- 3618
						if current == nil or item.updatedAt > current.updatedAt then -- 3618
							latestCompletedByKey[key] = item -- 3620
						end -- 3620
					end -- 3620
					::__continue660:: -- 3620
					i = i + 1 -- 3612
				end -- 3612
			end -- 3612
			local latestCompleted = {} -- 3623
			for ____, item in pairs(latestCompletedByKey) do -- 3624
				latestCompleted[#latestCompleted + 1] = item -- 3625
			end -- 3625
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3627
		end -- 3627
		if query ~= "" then -- 3627
			merged = __TS__ArrayFilter( -- 3630
				merged, -- 3630
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3630
			) -- 3630
		end -- 3630
		__TS__ArraySort( -- 3636
			merged, -- 3636
			function(____, a, b) -- 3636
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3636
					return -1 -- 3637
				end -- 3637
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3637
					return 1 -- 3638
				end -- 3638
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3638
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3640
				end -- 3640
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3642
			end -- 3636
		) -- 3636
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3644
		return ____awaiter_resolve(nil, { -- 3644
			success = true, -- 3646
			rootSessionId = rootSession.id, -- 3647
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3648
			status = status, -- 3649
			limit = limit, -- 3650
			offset = offset, -- 3651
			hasMore = offset + limit < #merged, -- 3652
			sessions = paged -- 3653
		}) -- 3653
	end) -- 3653
end -- 3523
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 283
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 284
SPAWN_INFO_FILE = "SPAWN.json" -- 285
RESULT_FILE = "RESULT.md" -- 286
PENDING_HANDOFF_DIR = "pending-handoffs" -- 287
MAX_CONCURRENT_SUB_AGENTS = 4 -- 288
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 289
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 290
activeStopTokens = {} -- 340
followup = { -- 343
	activeRuns = {}, -- 344
	pendingWakes = 0, -- 345
	configs = {}, -- 346
	recovered = {}, -- 347
	bindings = {}, -- 348
	publish = nil, -- 349
	recover = nil, -- 350
	delivered = nil, -- 351
	dispatch = nil, -- 352
	settle = nil, -- 353
	submit = nil -- 354
} -- 354
followup.publish = function(sessionId) -- 359
	emitAgentSessionPatch( -- 360
		sessionId, -- 360
		{session = getSessionItem(sessionId)} -- 360
	) -- 360
end -- 359
followup.recover = function(session) -- 362
	if followup.recovered[session.id] or followup.activeRuns[session.id] then -- 362
		return -- 363
	end -- 363
	followup.recovered[session.id] = true -- 364
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 365
	local history = storage:readSessionState().messages -- 366
	for ____, input in ipairs(InputInbox.listInputs(session.id)) do -- 367
		local message = __TS__ArrayFind( -- 368
			history, -- 368
			function(____, item) return item.inputId == input.id end -- 368
		) -- 368
		if message then -- 368
			followup.delivered(session.id, message.taskId or session.currentTaskId or 0, input.id, message.afterStep or 0) -- 369
		end -- 369
	end -- 369
	InputInbox.recoverInputs(session.id) -- 371
end -- 362
followup.delivered = function(sessionId, taskId, inputId, step) -- 373
	local input = InputInbox.getInput(sessionId, inputId) -- 374
	if not input or input.status == "delivered" then -- 374
		return -- 375
	end -- 375
	local receipt = queryOne("SELECT message_id FROM agent.AgentSessionInput WHERE id=?", {inputId}) -- 376
	local messageId = type(receipt and receipt[1]) == "number" and receipt[1] > 0 and receipt[1] or nil -- 377
	if not messageId then -- 377
		if not DB:transaction({ -- 377
			{ -- 380
				("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id,task_id,role,content,display_content,created_at,updated_at) VALUES(?,?,'user',?,'',?,?)", -- 380
				{{ -- 380
					sessionId, -- 380
					taskId, -- 380
					input.content, -- 380
					now(), -- 380
					now() -- 380
				}} -- 380
			}, -- 380
			{"UPDATE agent.AgentSessionInput SET message_id=last_insert_rowid(),delivered_step=?,status='delivered' WHERE id=?", {{step, inputId}}} -- 381
		}) then -- 381
			error( -- 382
				__TS__New(Error, "failed to commit input display"), -- 382
				0 -- 382
			) -- 382
		end -- 382
		local saved = queryOne("SELECT message_id FROM agent.AgentSessionInput WHERE id=?", {inputId}) -- 383
		messageId = saved and saved[1] -- 384
	else -- 384
		InputInbox.markDelivered(inputId, messageId, step) -- 385
	end -- 385
	__TS__Delete(followup.configs, inputId) -- 386
	emitAgentSessionPatch( -- 387
		sessionId, -- 387
		{ -- 387
			session = getSessionItem(sessionId), -- 387
			message = getMessageItem(messageId) -- 387
		} -- 387
	) -- 387
end -- 373
followup.dispatch = function(sessionId) -- 389
	local session = getSessionItem(sessionId) -- 390
	if not session or followup.activeRuns[sessionId] or session.currentTaskFinalizing or getPendingQuestionnaire(sessionId) or isProjectTaskAdmissionClosed(session.projectRoot) or session.currentTaskStatus == "RUNNING" then -- 390
		return nil -- 392
	end -- 392
	local input = InputInbox.listInputs(sessionId)[1] -- 393
	if not input then -- 393
		__TS__Delete(followup.bindings, sessionId) -- 394
		return nil -- 394
	end -- 394
	if input.held or input.status ~= "pending" then -- 394
		return nil -- 395
	end -- 395
	local binding = followup.bindings[sessionId] -- 396
	if not binding then -- 396
		InputInbox.holdInputs(sessionId) -- 397
		followup.publish(sessionId) -- 397
		return nil -- 397
	end -- 397
	local options = input.options -- 398
	local result -- 399
	if type(options.localAgentConfigId) == "number" then -- 399
		result = startLocalPrompt(sessionId, input.content, options.localAgentConfigId, input.id) -- 401
	else -- 401
		local ____startImmediatePrompt_6 = startImmediatePrompt -- 403
		local ____array_5 = __TS__SparseArrayNew(sessionId, input.content, options.disabledAgentTools, options.workMode) -- 403
		local ____options_llmConfigId_4 = options.llmConfigId -- 404
		if ____options_llmConfigId_4 == nil then -- 404
			____options_llmConfigId_4 = binding.llmConfigId -- 404
		end -- 404
		__TS__SparseArrayPush( -- 404
			____array_5, -- 404
			____options_llmConfigId_4, -- 404
			followup.configs[input.id] or binding.llmConfig, -- 404
			options.maxSteps, -- 404
			input.id -- 404
		) -- 404
		result = ____startImmediatePrompt_6(__TS__SparseArraySpread(____array_5)) -- 403
	end -- 403
	if not result.success then -- 403
		InputInbox.holdInputs(sessionId) -- 406
		followup.publish(sessionId) -- 406
	end -- 406
	return result -- 407
end -- 389
followup.settle = function(sessionId, taskId, succeeded) -- 409
	if followup.activeRuns[sessionId] ~= taskId then -- 409
		return -- 410
	end -- 410
	__TS__Delete(followup.activeRuns, sessionId) -- 411
	if not succeeded then -- 411
		InputInbox.holdInputs(sessionId) -- 412
	else -- 412
		DB:exec("UPDATE agent.AgentSessionInput SET delivery='queue' WHERE session_id=? AND status='pending'", {sessionId}) -- 415
	end -- 415
	followup.publish(sessionId) -- 417
	if succeeded then -- 417
		followup.pendingWakes = followup.pendingWakes + 1 -- 419
		Director.systemScheduler:schedule(function() -- 420
			do -- 420
				local ____try, ____error = pcall(function() -- 420
					followup.dispatch(sessionId) -- 420
				end) -- 420
				do -- 420
					followup.pendingWakes = followup.pendingWakes - 1 -- 420
				end -- 420
				if not ____try then -- 420
					error(____error, 0) -- 420
				end -- 420
			end -- 420
			return true -- 420
		end) -- 420
	end -- 420
end -- 409
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId, submission) -- 428
	local ____opt_7 = getSessionItem(sessionId) -- 428
	if (____opt_7 and ____opt_7.kind) ~= "main" then -- 428
		return {success = false, message = "local Agent only supports main sessions"} -- 429
	end -- 429
	local id = tonumber(localAgentConfigId) -- 430
	if not id then -- 430
		return {success = false, message = "invalid local Agent config"} -- 431
	end -- 431
	return followup.submit( -- 432
		sessionId, -- 432
		prompt, -- 432
		{localAgentConfigId = id}, -- 432
		{localAgentConfigId = id}, -- 432
		submission -- 432
	) -- 432
end -- 428
followup.submit = function(sessionId, prompt, options, binding, submission) -- 434
	if submission ~= nil and type(submission) ~= "table" then -- 434
		return {success = false, message = "invalid input submission"} -- 435
	end -- 435
	local session = getSessionItem(sessionId) -- 436
	if not session then -- 436
		return {success = false, message = "session not found"} -- 437
	end -- 437
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 437
		return {success = false, message = "project task admission is closed"} -- 438
	end -- 438
	if session.kind ~= "main" then -- 438
		return startImmediatePrompt( -- 439
			sessionId, -- 439
			prompt, -- 439
			options.disabledAgentTools, -- 439
			options.workMode, -- 439
			options.llmConfigId, -- 439
			binding.llmConfig, -- 439
			options.maxSteps -- 439
		) -- 439
	end -- 439
	if (submission and submission.delivery) ~= nil and submission.delivery ~= "steer" and submission.delivery ~= "queue" then -- 439
		return {success = false, message = "invalid input delivery"} -- 440
	end -- 440
	if (submission and submission.requestId) ~= nil and (type(submission.requestId) ~= "string" or #submission.requestId > 128 or submission.requestId == "") then -- 440
		return {success = false, message = "invalid input request ID"} -- 441
	end -- 441
	do -- 441
		local function ____catch(____error) -- 441
			return true, { -- 478
				success = false, -- 478
				message = tostring(____error) -- 478
			} -- 478
		end -- 478
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 478
			followup.recover(session) -- 443
			followup.bindings[sessionId] = binding -- 444
			if submission and submission.action then -- 444
				if submission.action == "resume" and binding.llmConfig then -- 444
					for ____, item in ipairs(InputInbox.listInputs(sessionId)) do -- 447
						followup.configs[item.id] = binding.llmConfig -- 447
					end -- 447
				end -- 447
				InputInbox.mutateInput( -- 449
					sessionId, -- 449
					submission, -- 449
					normalizePromptTextSafe(prompt) -- 449
				) -- 449
				if submission.action == "cancel" and submission.inputId ~= nil then -- 449
					__TS__Delete(followup.configs, submission.inputId) -- 450
				end -- 450
				followup.publish(sessionId) -- 451
				local next = followup.dispatch(sessionId) -- 452
				return true, next or ({success = true, sessionId = sessionId, taskId = session.currentTaskId or 0}) -- 453
			end -- 453
			if getPendingQuestionnaire(sessionId) then -- 453
				return true, {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 455
			end -- 455
			if binding.localAgentConfigId ~= nil then -- 455
				local config = LocalAgent.getConfig(binding.localAgentConfigId) -- 457
				if not (config and config.verifiedAt) then -- 457
					return true, {success = false, message = "local Agent config is not verified"} -- 458
				end -- 458
			else -- 458
				local resolved = binding.llmConfig and ({success = true, config = binding.llmConfig}) or getLLMConfig(binding.llmConfigId) -- 460
				if not resolved.success then -- 460
					return true, {success = false, message = resolved.message} -- 461
				end -- 461
				local valid = validateAgentLLMConfig(resolved.config) -- 462
				if not valid.success then -- 462
					return true, valid -- 463
				end -- 463
			end -- 463
			local content = normalizePromptTextSafe(prompt) -- 465
			if content == "" then -- 465
				return true, {success = false, message = "prompt is empty"} -- 466
			end -- 466
			local requestId = submission and submission.requestId or (((("input-" .. tostring(sessionId)) .. "-") .. tostring(os.time())) .. "-") .. tostring(math.random(1, 1000000000)) -- 467
			local ____temp_21 = followup.activeRuns[sessionId] ~= nil -- 468
			if ____temp_21 then -- 468
				local ____opt_19 = activeStopTokens[session.currentTaskId or -1] -- 468
				____temp_21 = not (____opt_19 and ____opt_19.stopped) -- 468
			end -- 468
			local isActive = ____temp_21 -- 468
			local delivery = content ~= "/clear" and content ~= "/compact" and isActive and not binding.localAgentConfigId and (submission and submission.delivery) == "steer" and "steer" or "queue" -- 469
			local wasPaused = __TS__ArraySome( -- 470
				InputInbox.listInputs(sessionId), -- 470
				function(____, item) return item.held end -- 470
			) -- 470
			local ____InputInbox_admitInput_27 = InputInbox.admitInput -- 471
			local ____sessionId_25 = sessionId -- 471
			local ____options_26 = options -- 471
			local ____temp_24 -- 471
			if delivery == "steer" then -- 471
				____temp_24 = session.currentTaskId -- 471
			else -- 471
				____temp_24 = nil -- 471
			end -- 471
			local input = ____InputInbox_admitInput_27( -- 471
				____sessionId_25, -- 471
				content, -- 471
				delivery, -- 471
				requestId, -- 471
				____options_26, -- 471
				____temp_24 -- 471
			) -- 471
			if wasPaused and delivery == "queue" then -- 471
				InputInbox.holdInputs(sessionId) -- 472
			end -- 472
			followup.publish(sessionId) -- 473
			if input.status == "delivered" or input.status == "cancelled" then -- 473
				return true, {success = true, sessionId = sessionId, taskId = input.taskId or session.currentTaskId or 0} -- 474
			end -- 474
			if binding.llmConfig then -- 474
				followup.configs[input.id] = binding.llmConfig -- 475
			end -- 475
			local next = followup.dispatch(sessionId) -- 476
			return true, next or ({success = true, sessionId = sessionId, taskId = session.currentTaskId or 0}) -- 477
		end) -- 477
		if not ____try then -- 477
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 477
		end -- 477
		if ____hasReturned then -- 477
			return ____returnValue -- 442
		end -- 442
	end -- 442
end -- 434
activeLocalAgentControls = {} -- 480
finalizingSubSessionTaskIds = {} -- 481
activePromptRuns = 0 -- 482
streamUpdates = __TS__New( -- 484
	StreamUpdates, -- 484
	function(sessionId, taskId, step, value) -- 484
		local ____opt_28 = getSessionItem(sessionId) -- 484
		if (____opt_28 and ____opt_28.currentTaskId) ~= taskId then -- 484
			return -- 485
		end -- 485
		upsertStep( -- 486
			sessionId, -- 486
			taskId, -- 486
			step, -- 486
			"message", -- 486
			{status = "RUNNING", reason = value.content, reasoningContent = value.reasoningContent} -- 486
		) -- 486
		emitAgentSessionPatch( -- 489
			sessionId, -- 489
			{step = getStepItem(sessionId, taskId, step)} -- 489
		) -- 489
	end -- 484
) -- 484
streamFlushScheduled = false -- 491
--- Runtime ownership, including asynchronous completion after task status changes.
function ____exports.isRuntimeIdle() -- 504
	return followup.pendingWakes == 0 and activePromptRuns == 0 and #__TS__ObjectKeys(activeStopTokens) == 0 and #__TS__ObjectKeys(activeLocalAgentControls) == 0 and #__TS__ObjectKeys(finalizingSubSessionTaskIds) == 0 -- 505
end -- 504
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 510
now = function() return os.time() end -- 511
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1172
	if projectRoot == oldRoot then -- 1172
		return newRoot -- 1174
	end -- 1174
	for ____, separator in ipairs({"/", "\\"}) do -- 1176
		local prefix = oldRoot .. separator -- 1177
		if __TS__StringStartsWith(projectRoot, prefix) then -- 1177
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1179
		end -- 1179
	end -- 1179
	return nil -- 1182
end -- 1172
local function clearSessionAfterMessage(sessionId, message) -- 1701
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1702
	local removedStepIds = {} -- 1710
	do -- 1710
		local i = 0 -- 1711
		while i < #removedStepRows do -- 1711
			local row = removedStepRows[i + 1] -- 1712
			if type(row[1]) == "number" then -- 1712
				removedStepIds[#removedStepIds + 1] = row[1] -- 1714
			end -- 1714
			i = i + 1 -- 1711
		end -- 1711
	end -- 1711
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1717
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1725
	return removedStepIds -- 1730
end -- 1701
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1733
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1734
	local persisted = storage:readSessionState() -- 1735
	local userIndex = -1 -- 1736
	do -- 1736
		local i = #persisted.messages - 1 -- 1737
		while i >= 0 do -- 1737
			if persisted.messages[i + 1].role == "user" and persisted.messages[i + 1].inputKind ~= "steer" then -- 1737
				userIndex = i -- 1739
				break -- 1740
			end -- 1740
			i = i - 1 -- 1737
		end -- 1737
	end -- 1737
	if userIndex < 0 then -- 1737
		return -- 1743
	end -- 1743
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1744
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1745
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1746
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1751
end -- 1733
local function listCurrentTaskCheckpoints(sessionId) -- 1763
	local session = getSessionItem(sessionId) -- 1764
	local taskId = session and session.currentTaskId -- 1765
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1766
end -- 1763
local function getAgentStepCount(sessionId, taskId) -- 1873
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1874
		sessionId, -- 1879
		taskId, -- 1880
		"compress_memory", -- 1881
		"merge_memory", -- 1882
		"sub_agent_handoff", -- 1883
		"questionnaire_answer", -- 1884
		"message" -- 1885
	}) -- 1885
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1888
end -- 1873
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1891
	if status == nil then -- 1891
		status = "DONE" -- 1899
	end -- 1899
	local step = getNextStepNumber(sessionId, taskId) -- 1901
	upsertStep( -- 1902
		sessionId, -- 1902
		taskId, -- 1902
		step, -- 1902
		tool, -- 1902
		{status = status, reason = reason, params = params, result = result} -- 1902
	) -- 1902
	return getStepItem(sessionId, taskId, step) -- 1908
end -- 1891
local function sanitizeStoredSteps(sessionId) -- 1975
	DB:exec( -- 1976
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1976
		{ -- 1994
			now(), -- 1994
			sessionId -- 1994
		} -- 1994
	) -- 1994
end -- 1975
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2455
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2455
		return {success = false, message = "invalid projectRoot"} -- 2457
	end -- 2457
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2459
	for ____, row in ipairs(rows) do -- 2460
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2461
		if sessionId > 0 then -- 2461
			deleteSessionRecords(sessionId) -- 2463
		end -- 2463
	end -- 2463
	return {success = true, deleted = #rows} -- 2466
end -- 2455
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2469
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2469
		return {success = false, message = "invalid projectRoot"} -- 2471
	end -- 2471
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2473
	local renamed = 0 -- 2474
	for ____, row in ipairs(rows) do -- 2475
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2476
		local projectRoot = toStr(row[2]) -- 2477
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2478
		if sessionId > 0 and nextProjectRoot then -- 2478
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2480
			DB:exec( -- 2481
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2481
				{ -- 2483
					nextProjectRoot, -- 2483
					Path:getFilename(nextProjectRoot), -- 2483
					now(), -- 2483
					sessionId -- 2483
				} -- 2483
			) -- 2483
			renamed = renamed + 1 -- 2485
		end -- 2485
	end -- 2485
	return {success = true, renamed = renamed} -- 2488
end -- 2469
function ____exports.getSession(sessionId, view) -- 2491
	local session = getSessionItem(sessionId) -- 2492
	if not session then -- 2492
		return {success = false, message = "session not found"} -- 2494
	end -- 2494
	if not followup.activeRuns[sessionId] then -- 2494
		followup.recover(session) -- 2496
	end -- 2496
	local restored = restorePendingQuestionnaireState(session) -- 2497
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2498
	local ____opt_92 = getSessionItem(sessionId) -- 2498
	normalizedSession.pendingInputs = ____opt_92 and ____opt_92.pendingInputs -- 2499
	local relatedSessions = listRelatedSessions(sessionId) -- 2500
	sanitizeStoredSteps(sessionId) -- 2501
	local firstMessageId = 0 -- 2502
	local hasEarlierMessages = false -- 2503
	if view then -- 2503
		local limit = math.max( -- 2505
			1, -- 2505
			math.min( -- 2505
				1000, -- 2505
				math.floor(view.recentRounds) -- 2505
			) -- 2505
		) -- 2505
		local requests = queryRows(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m WHERE m.session_id = ? AND m.role = 'user'\n    AND NOT EXISTS (SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n\t\t\tORDER BY m.id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2506
		if #requests > limit then -- 2506
			firstMessageId = requests[limit][1] -- 2512
			hasEarlierMessages = true -- 2513
		end -- 2513
	end -- 2513
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2516
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2523
	local ____relatedSessions_99 = relatedSessions -- 2535
	local ____temp_98 -- 2536
	if normalizedSession.kind == "sub" then -- 2536
		____temp_98 = getSessionSpawnInfo(normalizedSession) -- 2536
	else -- 2536
		____temp_98 = nil -- 2536
	end -- 2536
	return { -- 2532
		success = true, -- 2533
		session = normalizedSession, -- 2534
		relatedSessions = ____relatedSessions_99, -- 2535
		spawnInfo = ____temp_98, -- 2536
		messages = __TS__ArrayMap( -- 2537
			messages, -- 2537
			function(____, row) return rowToMessage(row) end -- 2537
		), -- 2537
		hasEarlierMessages = hasEarlierMessages, -- 2538
		steps = __TS__ArrayMap( -- 2539
			steps, -- 2539
			function(____, row) return rowToStep(row) end -- 2539
		), -- 2539
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2540
		pendingQuestionnaire = restored.questionnaire, -- 2541
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2542
	} -- 2542
end -- 2491
function ____exports.setWorkMode(sessionId, workMode) -- 2547
	local session = getSessionItem(sessionId) -- 2548
	if not session then -- 2548
		return {success = false, message = "session not found"} -- 2549
	end -- 2549
	if session.kind ~= "main" then -- 2549
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2550
	end -- 2550
	if workMode ~= "code" and workMode ~= "plan" then -- 2550
		return {success = false, message = "invalid work mode"} -- 2551
	end -- 2551
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2552
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2552
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2554
	end -- 2554
	if getPendingQuestionnaire(sessionId) then -- 2554
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2557
	end -- 2557
	if normalizedSession.workMode ~= workMode then -- 2557
		DB:exec( -- 2560
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2560
			{ -- 2560
				workMode, -- 2560
				now(), -- 2560
				sessionId -- 2560
			} -- 2560
		) -- 2560
	end -- 2560
	local updated = getSessionItem(sessionId) -- 2562
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2563
	return { -- 2564
		success = true, -- 2564
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2564
	} -- 2564
end -- 2547
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId) -- 2855
	local session = getSessionItem(sessionId) -- 2856
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2856
		return {success = false, message = "project task admission is closed"} -- 2857
	end -- 2857
	if not session then -- 2857
		return {success = false, message = "session not found"} -- 2859
	end -- 2859
	if getPendingQuestionnaire(sessionId) then -- 2859
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2861
	end -- 2861
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2861
		return {success = false, message = "session task is finalizing"} -- 2863
	end -- 2863
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2863
		return {success = false, message = "session task is still stopping"} -- 2866
	end -- 2866
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2866
		return {success = false, message = "session task is not continuable"} -- 2869
	end -- 2869
	if session.currentTaskId == nil then -- 2869
		return {success = false, message = "session task not found"} -- 2872
	end -- 2872
	local taskId = session.currentTaskId -- 2874
	return startPromptTask( -- 2875
		session, -- 2876
		"", -- 2877
		nil, -- 2878
		normalizeDisabledAgentTools(disabledAgentTools), -- 2879
		{ -- 2880
			workMode = session.workMode, -- 2881
			persistUserMessage = false, -- 2882
			resumeConversation = true, -- 2883
			existingTaskId = taskId, -- 2884
			initialStep = math.max( -- 2885
				0, -- 2885
				getNextStepNumber(session.id, taskId) - 1 -- 2885
			), -- 2885
			initialAgentStepCount = 0, -- 2889
			llmConfigId = llmConfigId -- 2890
		} -- 2890
	) -- 2890
end -- 2855
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 3065
	local session = getSessionItem(sessionId) -- 3066
	if not session then -- 3066
		return {success = false, message = "session not found"} -- 3068
	end -- 3068
	if session.kind ~= "sub" then -- 3068
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 3071
	end -- 3071
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3071
		return {success = false, message = "session task is finalizing"} -- 3074
	end -- 3074
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3076
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 3076
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 3081
	end -- 3081
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 3081
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 3084
	end -- 3084
	local disabledAgentTools = __TS__ArrayFilter( -- 3086
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 3086
		function(____, tool) return tool ~= "finish" end -- 3087
	) -- 3087
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 3088
	return startPromptTask( -- 3091
		session, -- 3091
		prompt, -- 3091
		nil, -- 3091
		disabledAgentTools, -- 3091
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 3091
	) -- 3091
end -- 3065
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 3098
	local session = getSessionItem(sessionId) -- 3099
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3099
		return {success = false, message = "project task admission is closed"} -- 3100
	end -- 3100
	if not session then -- 3100
		return {success = false, message = "session not found"} -- 3102
	end -- 3102
	if #InputInbox.listInputs(sessionId) > 0 then -- 3102
		return {success = false, message = "finish or remove pending messages before editing task history"} -- 3104
	end -- 3104
	if getPendingQuestionnaire(sessionId) then -- 3104
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 3105
	end -- 3105
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3105
		return {success = false, message = "session task is finalizing"} -- 3107
	end -- 3107
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 3107
		return {success = false, message = "session task is still running"} -- 3110
	end -- 3110
	local message = getMessageItem(messageId) -- 3112
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 3112
		return {success = false, message = "message not found"} -- 3114
	end -- 3114
	local latestUserRow = queryOne(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m\n  WHERE m.session_id = ? AND m.role = ? AND NOT EXISTS (\n   SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n  ORDER BY m.id DESC LIMIT 1", {sessionId, "user"}) -- 3116
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 3123
	if latestUserMessageId ~= messageId then -- 3123
		return {success = false, message = "only the latest user prompt can be edited"} -- 3125
	end -- 3125
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 3127
	if normalizedPrompt == "" then -- 3127
		return {success = false, message = "prompt is empty"} -- 3129
	end -- 3129
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 3131
	if session.workMode ~= nextWorkMode then -- 3131
		DB:exec( -- 3133
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 3133
			{ -- 3133
				nextWorkMode, -- 3133
				now(), -- 3133
				session.id -- 3133
			} -- 3133
		) -- 3133
		session.workMode = nextWorkMode -- 3134
	end -- 3134
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 3136
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 3137
	local result = startPromptTask( -- 3138
		session, -- 3138
		normalizedPrompt, -- 3138
		messageId, -- 3138
		normalizeDisabledAgentTools(disabledAgentTools), -- 3138
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 3138
	) -- 3138
	if result.success and #removedStepIds > 0 then -- 3138
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 3140
	end -- 3140
	return result -- 3142
end -- 3098
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 3147
	if status == "dismissed" then -- 3147
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 3153
	end -- 3153
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3155
end -- 3147
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3158
	if status == "dismissed" then -- 3158
		return { -- 3164
			success = true, -- 3165
			status = "dismissed", -- 3166
			source = "user", -- 3167
			questionnaireId = questionnaire.id, -- 3168
			title = questionnaire.schema.title, -- 3169
			answers = {}, -- 3170
			responses = {}, -- 3171
			displayText = "用户关闭了调查问卷，未作答。", -- 3172
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 3173
		} -- 3173
	end -- 3173
	local responses = {} -- 3176
	do -- 3176
		local i = 0 -- 3177
		while i < #questionnaire.schema.questions do -- 3177
			do -- 3177
				local question = questionnaire.schema.questions[i + 1] -- 3178
				local answer = __TS__ArrayFind( -- 3179
					answers, -- 3179
					function(____, item) return item.questionId == question.id end -- 3179
				) -- 3179
				if not answer or answer.status == "skipped" then -- 3179
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3181
					goto __continue557 -- 3186
				end -- 3186
				local selectedOptionLabels = {} -- 3188
				do -- 3188
					local j = 0 -- 3189
					while j < #(answer.selectedOptionIds or ({})) do -- 3189
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3190
						local option = __TS__ArrayFind( -- 3191
							question.options or ({}), -- 3191
							function(____, item) return item.id == optionId end -- 3191
						) -- 3191
						if option then -- 3191
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3192
						end -- 3192
						j = j + 1 -- 3189
					end -- 3189
				end -- 3189
				responses[#responses + 1] = { -- 3194
					questionId = question.id, -- 3195
					prompt = question.prompt, -- 3196
					status = "answered", -- 3197
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3198
					selectedOptionLabels = selectedOptionLabels, -- 3199
					otherText = answer.otherText, -- 3200
					text = answer.text -- 3201
				} -- 3201
			end -- 3201
			::__continue557:: -- 3201
			i = i + 1 -- 3177
		end -- 3177
	end -- 3177
	return { -- 3204
		success = true, -- 3205
		status = "answered", -- 3206
		source = "user", -- 3207
		questionnaireId = questionnaire.id, -- 3208
		title = questionnaire.schema.title, -- 3209
		answers = answers, -- 3210
		responses = responses, -- 3211
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3212
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3213
	} -- 3213
end -- 3158
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3239
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3245
	local persisted = storage:readSessionState() -- 3246
	local messages = __TS__ArraySlice(persisted.messages) -- 3247
	local toolResultIndex = -1 -- 3248
	local existingResult -- 3249
	do -- 3249
		local i = #messages - 1 -- 3250
		while i >= 0 do -- 3250
			do -- 3250
				local message = messages[i + 1] -- 3251
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3251
					goto __continue577 -- 3252
				end -- 3252
				local decoded = safeJsonDecode(message.content) -- 3253
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3253
					goto __continue577 -- 3254
				end -- 3254
				local row = decoded -- 3255
				if row.questionnaireId ~= questionnaire.id then -- 3255
					goto __continue577 -- 3256
				end -- 3256
				toolResultIndex = i -- 3257
				existingResult = row -- 3258
				break -- 3259
			end -- 3259
			::__continue577:: -- 3259
			i = i - 1 -- 3250
		end -- 3250
	end -- 3250
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3261
	local guidance = {} -- 3262
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3262
		guidance[#guidance + 1] = existingResult.guidance -- 3264
	end -- 3264
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3264
		guidance[#guidance + 1] = result.guidance -- 3267
	end -- 3267
	result.guidance = table.concat(guidance, "\n") -- 3269
	if toolResultIndex < 0 then -- 3269
		messages[#messages + 1] = { -- 3271
			role = "user", -- 3272
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3273
		} -- 3273
		toolResultIndex = #messages - 1 -- 3275
	else -- 3275
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3277
			{}, -- 3277
			messages[toolResultIndex + 1], -- 3278
			{content = encodeJson(result)} -- 3277
		) -- 3277
	end -- 3277
	local pairStartIndex = toolResultIndex -- 3283
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3284
	if toolCallId and toolCallId ~= "" then -- 3284
		do -- 3284
			local i = toolResultIndex - 1 -- 3286
			while i >= 0 do -- 3286
				do -- 3286
					local message = messages[i + 1] -- 3287
					if message.role ~= "assistant" or not message.tool_calls then -- 3287
						goto __continue587 -- 3288
					end -- 3288
					if __TS__ArraySome( -- 3288
						message.tool_calls, -- 3289
						function(____, call) return call.id == toolCallId end -- 3289
					) then -- 3289
						pairStartIndex = i -- 3290
						break -- 3291
					end -- 3291
				end -- 3291
				::__continue587:: -- 3291
				i = i - 1 -- 3286
			end -- 3286
		end -- 3286
	end -- 3286
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3295
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3298
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3302
	upsertStep( -- 3304
		session.id, -- 3304
		questionnaire.taskId, -- 3304
		questionnaire.step, -- 3304
		"ask_user", -- 3304
		{status = "DONE", result = result} -- 3304
	) -- 3304
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3308
	upsertStep( -- 3309
		session.id, -- 3309
		questionnaire.taskId, -- 3309
		answerStep, -- 3309
		"questionnaire_answer", -- 3309
		{status = "DONE", result = result} -- 3309
	) -- 3309
	return {success = true, answerStep = answerStep, result = result} -- 3313
end -- 3239
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3316
	local session = getSessionItem(sessionId) -- 3317
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3317
		return {success = false, message = "project task admission is closed"} -- 3318
	end -- 3318
	if not session then -- 3318
		return {success = false, message = "session not found"} -- 3319
	end -- 3319
	if session.kind ~= "main" then -- 3319
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3320
	end -- 3320
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3321
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3321
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3323
	end -- 3323
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3325
	if not llmConfigRes.success then -- 3325
		return {success = false, message = llmConfigRes.message} -- 3326
	end -- 3326
	if not removePendingQuestionnaire(session) then -- 3326
		return {success = false, message = "failed to consume questionnaire file"} -- 3327
	end -- 3327
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3328
	if not replaced.success then -- 3328
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3330
		return replaced -- 3331
	end -- 3331
	local t = now() -- 3333
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3334
	session.workMode = "plan" -- 3335
	local result = startPromptTask( -- 3336
		session, -- 3336
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3336
		nil, -- 3336
		{}, -- 3336
		{ -- 3336
			workMode = "plan", -- 3337
			persistUserMessage = false, -- 3338
			resumeConversation = true, -- 3339
			existingTaskId = questionnaire.taskId, -- 3340
			initialStep = replaced.answerStep, -- 3341
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3342
			llmConfig = llmConfigRes.config -- 3343
		} -- 3343
	) -- 3343
	if not result.success then -- 3343
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3346
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3347
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3348
		emitAgentSessionPatch( -- 3349
			session.id, -- 3349
			{ -- 3349
				session = getSessionItem(session.id), -- 3350
				pendingQuestionnaire = questionnaire -- 3351
			} -- 3351
		) -- 3351
		return result -- 3353
	end -- 3353
	emitAgentSessionPatch( -- 3355
		sessionId, -- 3355
		{ -- 3355
			session = getSessionItem(sessionId), -- 3356
			pendingQuestionnaire = false -- 3357
		} -- 3357
	) -- 3357
	return result -- 3359
end -- 3316
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3362
	local session = getSessionItem(sessionId) -- 3363
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3363
		return {success = false, message = "project task admission is closed"} -- 3364
	end -- 3364
	if not session then -- 3364
		return {success = false, message = "session not found"} -- 3365
	end -- 3365
	if session.kind ~= "main" then -- 3365
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3366
	end -- 3366
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3367
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3367
		return {success = false, message = "pending questionnaire not found"} -- 3368
	end -- 3368
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3369
	if not validated.success then -- 3369
		return validated -- 3370
	end -- 3370
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3371
	if not llmConfigRes.success then -- 3371
		return {success = false, message = llmConfigRes.message} -- 3372
	end -- 3372
	local t = now() -- 3373
	if not removePendingQuestionnaire(session) then -- 3373
		return {success = false, message = "failed to consume questionnaire file"} -- 3374
	end -- 3374
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3375
	if not replaced.success then -- 3375
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3377
		return replaced -- 3378
	end -- 3378
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3380
	session.workMode = "plan" -- 3381
	local result = startPromptTask( -- 3382
		session, -- 3382
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3382
		nil, -- 3382
		{}, -- 3382
		{ -- 3382
			workMode = "plan", -- 3383
			persistUserMessage = false, -- 3384
			resumeConversation = true, -- 3385
			existingTaskId = questionnaire.taskId, -- 3386
			initialStep = replaced.answerStep, -- 3387
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3388
			llmConfig = llmConfigRes.config -- 3389
		} -- 3389
	) -- 3389
	if not result.success then -- 3389
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3392
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3393
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3394
		emitAgentSessionPatch( -- 3395
			session.id, -- 3395
			{ -- 3395
				session = getSessionItem(session.id), -- 3396
				pendingQuestionnaire = questionnaire -- 3397
			} -- 3397
		) -- 3397
		return result -- 3399
	end -- 3399
	emitAgentSessionPatch( -- 3401
		sessionId, -- 3401
		{ -- 3401
			session = getSessionItem(sessionId), -- 3402
			pendingQuestionnaire = false -- 3403
		} -- 3403
	) -- 3403
	return result -- 3405
end -- 3362
function ____exports.stopSessionTask(sessionId) -- 3408
	InputInbox.holdInputs(sessionId) -- 3409
	followup.publish(sessionId) -- 3410
	local session = getSessionItem(sessionId) -- 3411
	if not session or session.currentTaskId == nil then -- 3411
		return {success = false, message = "session task not found"} -- 3413
	end -- 3413
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3413
		return {success = false, message = "session task is finalizing"} -- 3416
	end -- 3416
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime) -- 3418
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3419
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3420
	if localControl ~= nil then -- 3420
		localControl:stop() -- 3422
		return {success = true, stopping = true} -- 3423
	end -- 3423
	local stopToken = activeStopTokens[session.currentTaskId] -- 3425
	if stopToken == nil then -- 3425
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3425
			return {success = true, recovered = true} -- 3428
		end -- 3428
		return {success = false, message = "task is not running"} -- 3430
	end -- 3430
	if stopToken.stopped then -- 3430
		return {success = true, stopping = true} -- 3433
	end -- 3433
	stopToken.stopped = true -- 3435
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3436
	return {success = true, stopping = true} -- 3440
end -- 3408
function ____exports.getCurrentTaskId(sessionId) -- 3443
	local ____opt_171 = getSessionItem(sessionId) -- 3443
	return ____opt_171 and ____opt_171.currentTaskId -- 3444
end -- 3443
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3448
	local owner = getSessionItem(sessionId) -- 3449
	if not owner then -- 3449
		return {success = false, message = "session not found"} -- 3450
	end -- 3450
	local projectRoot = owner.projectRoot -- 3451
	local release = holdProjectTaskAdmission(projectRoot) -- 3452
	local closed = false -- 3453
	return { -- 3454
		success = true, -- 3455
		projectRoot = projectRoot, -- 3456
		close = function() -- 3457
			if not closed then -- 3457
				closed = true -- 3457
				release() -- 3457
			end -- 3457
		end, -- 3457
		poll = function() -- 3458
			if closed then -- 3458
				return {success = false, message = "quiescence handle closed"} -- 3459
			end -- 3459
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3460
			if not rows then -- 3460
				return {success = false, message = "failed to inspect project tasks"} -- 3461
			end -- 3461
			local pending = {} -- 3462
			for ____, row in ipairs(rows) do -- 3463
				do -- 3463
					local session = rowToSession(row) -- 3464
					local taskId = session.currentTaskId -- 3465
					if taskId == nil then -- 3465
						goto __continue625 -- 3466
					end -- 3466
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3467
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3467
						goto __continue625 -- 3468
					end -- 3468
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3470
					local ____session_id_174 = session.id -- 3471
					local ____taskId_175 = taskId -- 3471
					local ____finalizing_176 = finalizing -- 3471
					local ____result_success_177 = result.success -- 3471
					local ____result_success_173 -- 3471
					if result.success then -- 3471
						____result_success_173 = nil -- 3471
					else -- 3471
						____result_success_173 = result.message -- 3471
					end -- 3471
					pending[#pending + 1] = { -- 3471
						sessionId = ____session_id_174, -- 3471
						taskId = ____taskId_175, -- 3471
						finalizing = ____finalizing_176, -- 3471
						stopRequested = ____result_success_177, -- 3471
						message = ____result_success_173 -- 3471
					} -- 3471
				end -- 3471
				::__continue625:: -- 3471
			end -- 3471
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3475
		end -- 3458
	} -- 3458
end -- 3448
function ____exports.validateTaskAccess(sessionId, taskId) -- 3480
	local session = getSessionItem(sessionId) -- 3481
	if not session then -- 3481
		return {success = false, message = "session not found"} -- 3482
	end -- 3482
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3482
		getSessionOperableTaskIds(sessionId), -- 3483
		taskId -- 3483
	) < 0 then -- 3483
		return {success = false, message = "task is not operable for this session"} -- 3484
	end -- 3484
	return {success = true, session = session} -- 3486
end -- 3480
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3489
	if checkpointId <= 0 then -- 3489
		return {success = false, message = "invalid checkpointId"} -- 3491
	end -- 3491
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3493
	if not checkpoint then -- 3493
		return {success = false, message = "checkpoint not found"} -- 3495
	end -- 3495
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3497
	if not taskAccess.success then -- 3497
		return taskAccess -- 3498
	end -- 3498
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3499
end -- 3489
function ____exports.listRunningSessions() -- 3502
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3503
	local sessions = {} -- 3510
	do -- 3510
		local i = 0 -- 3511
		while i < #rows do -- 3511
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3512
			if session.currentTaskStatus == "RUNNING" then -- 3512
				sessions[#sessions + 1] = session -- 3514
			end -- 3514
			i = i + 1 -- 3511
		end -- 3511
	end -- 3511
	return {success = true, sessions = sessions} -- 3517
end -- 3502
return ____exports -- 3502