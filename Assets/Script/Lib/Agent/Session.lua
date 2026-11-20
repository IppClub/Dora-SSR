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
local scheduleStreamFlush, getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getPendingSessionInputs, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, decodeSessionMetrics, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startImmediatePrompt, startLocalPrompt, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, followup, activeLocalAgentControls, finalizingSubSessionTaskIds, activePromptRuns, streamUpdates, streamFlushScheduled, SESSION_SELECT_COLUMNS, now -- 1
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
function scheduleStreamFlush() -- 504
	if streamFlushScheduled or not streamUpdates:hasPending() then -- 504
		return -- 505
	end -- 505
	streamFlushScheduled = true -- 506
	Director.systemScheduler:schedule(function() -- 507
		streamUpdates:flushDue(App.runningTime) -- 508
		if streamUpdates:hasPending() then -- 508
			return false -- 509
		end -- 509
		streamFlushScheduled = false -- 510
		return true -- 511
	end) -- 507
end -- 507
function getDefaultUseChineseResponse() -- 525
	local zh = string.match(App.locale, "^zh") -- 526
	return zh ~= nil -- 527
end -- 527
function encodeJson(value) -- 530
	local text = safeJsonEncode(value) -- 531
	return text or "" -- 532
end -- 532
function decodeJsonObject(text) -- 535
	if text == "" then -- 535
		return nil -- 536
	end -- 536
	local value = safeJsonDecode(text) -- 537
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 537
		return value -- 539
	end -- 539
	return nil -- 541
end -- 541
function decodeJsonFiles(text) -- 544
	if text == "" then -- 544
		return nil -- 545
	end -- 545
	local value = safeJsonDecode(text) -- 546
	if not value or not __TS__ArrayIsArray(value) then -- 546
		return nil -- 547
	end -- 547
	local files = {} -- 548
	do -- 548
		local i = 0 -- 549
		while i < #value do -- 549
			do -- 549
				local item = value[i + 1] -- 550
				if type(item) ~= "table" then -- 550
					goto __continue78 -- 551
				end -- 551
				files[#files + 1] = { -- 552
					path = sanitizeUTF8(toStr(item.path)), -- 553
					op = sanitizeUTF8(toStr(item.op)) -- 554
				} -- 554
			end -- 554
			::__continue78:: -- 554
			i = i + 1 -- 549
		end -- 549
	end -- 549
	return files -- 557
end -- 557
function decodeChangeSetSummary(value) -- 560
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 560
		return nil -- 561
	end -- 561
	local row = value -- 562
	if row.success ~= true then -- 562
		return nil -- 563
	end -- 563
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 564
	if taskId <= 0 then -- 564
		return nil -- 565
	end -- 565
	local files = {} -- 566
	if __TS__ArrayIsArray(row.files) then -- 566
		do -- 566
			local i = 0 -- 568
			while i < #row.files do -- 568
				do -- 568
					local file = row.files[i + 1] -- 569
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 569
						goto __continue86 -- 570
					end -- 570
					local fileRow = file -- 571
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 572
					if path == "" then -- 572
						goto __continue86 -- 573
					end -- 573
					local checkpointIds = {} -- 574
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 574
						do -- 574
							local j = 0 -- 576
							while j < #fileRow.checkpointIds do -- 576
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 577
								if checkpointId > 0 then -- 577
									checkpointIds[#checkpointIds + 1] = checkpointId -- 578
								end -- 578
								j = j + 1 -- 576
							end -- 576
						end -- 576
					end -- 576
					local op = toStr(fileRow.op) -- 581
					files[#files + 1] = { -- 582
						path = path, -- 583
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 584
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 585
						checkpointIds = checkpointIds -- 586
					} -- 586
				end -- 586
				::__continue86:: -- 586
				i = i + 1 -- 568
			end -- 568
		end -- 568
	end -- 568
	return { -- 590
		success = true, -- 591
		taskId = taskId, -- 592
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 593
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 594
		files = files, -- 595
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 596
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 597
	} -- 597
end -- 597
function decodeHandoffEvidence(value) -- 601
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 601
		return nil -- 602
	end -- 602
	local row = value -- 603
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 604
		__TS__ArrayFilter( -- 605
			row.modifiedFiles, -- 605
			function(____, item) return type(item) == "string" end -- 605
		), -- 605
		function(____, item) return sanitizeUTF8(item) end -- 605
	) or ({}) -- 605
	local lastBuild = nil -- 607
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 607
		local build = row.lastBuild -- 609
		lastBuild = { -- 610
			result = build.result == "passed" and "passed" or "failed", -- 611
			path = sanitizeUTF8(toStr(build.path)), -- 612
			evidence = takeUtf8Head( -- 613
				sanitizeUTF8(toStr(build.evidence)), -- 613
				600 -- 613
			) -- 613
		} -- 613
	end -- 613
	local commands = {} -- 616
	if __TS__ArrayIsArray(row.commands) then -- 616
		do -- 616
			local i = 0 -- 618
			while i < #row.commands and #commands < 8 do -- 618
				do -- 618
					local raw = row.commands[i + 1] -- 619
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 619
						goto __continue100 -- 620
					end -- 620
					local item = raw -- 621
					commands[#commands + 1] = { -- 622
						mode = sanitizeUTF8(toStr(item.mode)), -- 623
						command = takeUtf8Head( -- 624
							sanitizeUTF8(toStr(item.command)), -- 624
							600 -- 624
						), -- 624
						result = item.result == "passed" and "passed" or "failed", -- 625
						evidence = takeUtf8Head( -- 626
							sanitizeUTF8(toStr(item.evidence)), -- 626
							600 -- 626
						) -- 626
					} -- 626
				end -- 626
				::__continue100:: -- 626
				i = i + 1 -- 618
			end -- 618
		end -- 618
	end -- 618
	local authoritativeSources = {} -- 630
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 630
		do -- 630
			local i = 0 -- 632
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 632
				do -- 632
					local raw = row.authoritativeSources[i + 1] -- 633
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 633
						goto __continue104 -- 634
					end -- 634
					local item = raw -- 635
					authoritativeSources[#authoritativeSources + 1] = { -- 636
						tool = "search_dora_doc", -- 637
						query = takeUtf8Head( -- 638
							sanitizeUTF8(toStr(item.query)), -- 638
							300 -- 638
						), -- 638
						source = sanitizeUTF8(toStr(item.source)), -- 639
						result = item.result == "passed" and "passed" or "failed" -- 640
					} -- 640
				end -- 640
				::__continue104:: -- 640
				i = i + 1 -- 632
			end -- 632
		end -- 632
	end -- 632
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 644
end -- 644
function takeUtf8Head(text, maxChars) -- 647
	if maxChars <= 0 or text == "" then -- 647
		return "" -- 648
	end -- 648
	local nextPos = utf8.offset(text, maxChars + 1) -- 649
	if nextPos == nil then -- 649
		return text -- 650
	end -- 650
	return string.sub(text, 1, nextPos - 1) -- 651
end -- 651
function normalizeMemoryEntryEvidence(value) -- 654
	local evidence = {} -- 655
	if not __TS__ArrayIsArray(value) then -- 655
		return evidence -- 656
	end -- 656
	do -- 656
		local i = 0 -- 657
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 657
			do -- 657
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 658
				if item == "" then -- 658
					goto __continue112 -- 659
				end -- 659
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 659
					evidence[#evidence + 1] = item -- 661
				end -- 661
			end -- 661
			::__continue112:: -- 661
			i = i + 1 -- 657
		end -- 657
	end -- 657
	return evidence -- 664
end -- 664
function decodeSubAgentMemoryEntry(value) -- 667
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 667
		return nil -- 668
	end -- 668
	local row = value -- 669
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 670
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 671
	local content = takeUtf8Head( -- 672
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 672
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 672
	) -- 672
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 672
		return nil -- 673
	end -- 673
	return { -- 674
		sourceSessionId = sourceSessionId, -- 675
		sourceTaskId = sourceTaskId, -- 676
		content = content, -- 677
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 678
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 679
	} -- 679
end -- 679
function getTaskChangeSetSummary(taskId) -- 683
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 684
	return summary.success and summary or nil -- 685
end -- 685
function summarizeHandoffResult(result) -- 688
	local candidates = {result.output, result.message, result.state, result.phase} -- 689
	do -- 689
		local i = 0 -- 690
		while i < #candidates do -- 690
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 691
			if text ~= "" then -- 691
				return takeUtf8Head(text, 600) -- 692
			end -- 692
			i = i + 1 -- 690
		end -- 690
	end -- 690
	local messages = result.messages -- 694
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 694
		local parts = {} -- 696
		do -- 696
			local i = 0 -- 697
			while i < #messages and #parts < 4 do -- 697
				do -- 697
					local row = messages[i + 1] -- 698
					if not row or type(row) ~= "table" then -- 698
						goto __continue125 -- 699
					end -- 699
					local item = row -- 700
					local ____sanitizeUTF8_33 = sanitizeUTF8 -- 701
					local ____toStr_32 = toStr -- 701
					local ____item_message_30 = item.message -- 701
					if ____item_message_30 == nil then -- 701
						____item_message_30 = item.error -- 701
					end -- 701
					local ____item_message_30_31 = ____item_message_30 -- 701
					if ____item_message_30_31 == nil then -- 701
						____item_message_30_31 = item.file -- 701
					end -- 701
					local text = __TS__StringTrim(____sanitizeUTF8_33(____toStr_32(____item_message_30_31))) -- 701
					if text ~= "" then -- 701
						parts[#parts + 1] = text -- 702
					end -- 702
				end -- 702
				::__continue125:: -- 702
				i = i + 1 -- 697
			end -- 697
		end -- 697
		if #parts > 0 then -- 697
			return takeUtf8Head( -- 704
				table.concat(parts, "; "), -- 704
				600 -- 704
			) -- 704
		end -- 704
	end -- 704
	return result.success == true and "tool result success=true" or "tool result success=false" -- 706
end -- 706
function getTaskHandoffEvidence(taskId, changeSet) -- 709
	local ____opt_34 = changeSet -- 709
	local evidence = { -- 710
		modifiedFiles = ____opt_34 and __TS__ArrayMap( -- 711
			changeSet and changeSet.files, -- 711
			function(____, item) return item.path end -- 711
		) or ({}), -- 711
		commands = {}, -- 712
		authoritativeSources = {} -- 713
	} -- 713
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 715
	do -- 715
		local i = 0 -- 720
		while i < #rows do -- 720
			local tool = toStr(rows[i + 1][1]) -- 721
			local status = toStr(rows[i + 1][2]) -- 722
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 723
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 724
			local passed = status == "DONE" and result.success == true -- 725
			if tool == "build" then -- 725
				evidence.lastBuild = { -- 727
					result = passed and "passed" or "failed", -- 728
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 729
					evidence = summarizeHandoffResult(result) -- 730
				} -- 730
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 730
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 733
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 734
				local ____evidence_commands_38 = evidence.commands -- 734
				____evidence_commands_38[#____evidence_commands_38 + 1] = { -- 735
					mode = mode, -- 736
					command = takeUtf8Head( -- 737
						__TS__StringTrim(sanitizeUTF8(command)), -- 737
						600 -- 737
					), -- 737
					result = passed and "passed" or "failed", -- 738
					evidence = summarizeHandoffResult(result) -- 739
				} -- 739
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 739
				local ____evidence_authoritativeSources_39 = evidence.authoritativeSources -- 739
				____evidence_authoritativeSources_39[#____evidence_authoritativeSources_39 + 1] = { -- 742
					tool = "search_dora_doc", -- 743
					query = takeUtf8Head( -- 744
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 744
						300 -- 744
					), -- 744
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 745
					result = passed and "passed" or "failed" -- 746
				} -- 746
			end -- 746
			i = i + 1 -- 720
		end -- 720
	end -- 720
	return evidence -- 750
end -- 750
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 753
	local lastBuild = evidence.lastBuild -- 757
	if not lastBuild or lastBuild.result ~= "failed" then -- 757
		return completion -- 758
	end -- 758
	local validation = __TS__ArraySlice(completion.validation) -- 759
	local foundBuild = false -- 760
	do -- 760
		local i = 0 -- 761
		while i < #validation do -- 761
			do -- 761
				if validation[i + 1].kind ~= "build" then -- 761
					goto __continue139 -- 762
				end -- 762
				foundBuild = true -- 763
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 764
			end -- 764
			::__continue139:: -- 764
			i = i + 1 -- 761
		end -- 761
	end -- 761
	if not foundBuild then -- 761
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 771
	end -- 771
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 773
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 774
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 774
		knownIssues[#knownIssues + 1] = issue -- 775
	end -- 775
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 776
end -- 776
function isValidProjectRoot(path) -- 784
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 785
end -- 785
function rowToSession(row) -- 788
	return { -- 789
		id = row[1], -- 790
		projectRoot = toStr(row[2]), -- 791
		title = toStr(row[3]), -- 792
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 793
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 794
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 795
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 796
		status = toStr(row[8]), -- 797
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 798
		currentTaskStatus = toStr(row[10]), -- 799
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 800
		createdAt = row[11], -- 801
		updatedAt = row[12], -- 802
		metrics = decodeSessionMetrics(toStr(row[13])), -- 803
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 804
	} -- 804
end -- 804
function rowToMessage(row) -- 808
	local message = { -- 809
		id = row[1], -- 810
		sessionId = row[2], -- 811
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 812
		role = toStr(row[4]), -- 813
		content = toStr(row[5]), -- 814
		createdAt = row[7], -- 815
		updatedAt = row[8] -- 816
	} -- 816
	local displayContent = toStr(row[6]) -- 818
	if displayContent ~= "" then -- 818
		message.displayContent = displayContent -- 819
	end -- 819
	local receipt = queryOne("SELECT delivery,delivered_step FROM agent.AgentSessionInput WHERE message_id=? AND status='delivered'", {message.id}) -- 820
	if (receipt and receipt[1]) == "steer" then -- 820
		message.inputKind = "steer" -- 821
		message.afterStep = type(receipt[2]) == "number" and receipt[2] or 0 -- 821
	end -- 821
	return message -- 822
end -- 822
function rowToStep(row) -- 825
	return { -- 826
		id = row[1], -- 827
		sessionId = row[2], -- 828
		taskId = row[3], -- 829
		step = row[4], -- 830
		tool = toStr(row[5]), -- 831
		status = toStr(row[6]), -- 832
		reason = toStr(row[7]), -- 833
		reasoningContent = toStr(row[8]), -- 834
		params = decodeJsonObject(toStr(row[9])), -- 835
		result = decodeJsonObject(toStr(row[10])), -- 836
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 837
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 838
		files = decodeJsonFiles(toStr(row[13])), -- 839
		createdAt = row[14], -- 840
		updatedAt = row[15] -- 841
	} -- 841
end -- 841
function getQuestionnairePath(projectRoot) -- 845
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 846
end -- 846
function decodeQuestionnaireFile(text) -- 849
	local value = decodeJsonObject(text) -- 850
	if not value then -- 850
		return nil -- 851
	end -- 851
	local schema = value.schema -- 852
	local id = type(value.id) == "number" and value.id or 0 -- 853
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 854
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 855
	local step = type(value.step) == "number" and value.step or 0 -- 856
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 857
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 857
		return nil -- 859
	end -- 859
	return { -- 861
		id = id, -- 861
		sessionId = sessionId, -- 861
		taskId = taskId, -- 861
		step = step, -- 861
		status = "PENDING", -- 861
		schema = schema, -- 861
		createdAt = createdAt -- 861
	} -- 861
end -- 861
function getPendingQuestionnaire(sessionId) -- 864
	local session = getSessionItem(sessionId) -- 865
	if not session or session.kind ~= "main" then -- 865
		return nil -- 866
	end -- 866
	local path = getQuestionnairePath(session.projectRoot) -- 867
	if not Content:exist(path) then -- 867
		return nil -- 868
	end -- 868
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 869
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 870
end -- 870
function restorePendingQuestionnaireState(session) -- 873
	local questionnaire = getPendingQuestionnaire(session.id) -- 874
	if not questionnaire then -- 874
		return {session = session} -- 875
	end -- 875
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 875
		local t = now() -- 882
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 883
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 889
		local restored = getSessionItem(session.id) -- 890
		if restored then -- 890
			session = restored -- 891
		end -- 891
	end -- 891
	return {session = session, questionnaire = questionnaire} -- 893
end -- 893
function savePendingQuestionnaire(projectRoot, questionnaire) -- 896
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 897
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 897
		return false -- 898
	end -- 898
	local path = getQuestionnairePath(projectRoot) -- 899
	local tempPath = path .. ".tmp" -- 900
	local backupPath = path .. ".bak" -- 901
	Content:remove(tempPath) -- 902
	Content:remove(backupPath) -- 903
	if not Content:save( -- 903
		tempPath, -- 904
		encodeJson(questionnaire) -- 904
	) then -- 904
		return false -- 904
	end -- 904
	local hadOriginal = Content:exist(path) -- 905
	if hadOriginal and not Content:move(path, backupPath) then -- 905
		Content:remove(tempPath) -- 907
		return false -- 908
	end -- 908
	if Content:move(tempPath, path) then -- 908
		Content:remove(backupPath) -- 911
		Tools.sendWebIDEFileUpdate( -- 912
			path, -- 912
			true, -- 912
			encodeJson(questionnaire) -- 912
		) -- 912
		return true -- 913
	end -- 913
	Content:remove(tempPath) -- 915
	if hadOriginal and Content:exist(backupPath) then -- 915
		Content:move(backupPath, path) -- 917
	end -- 917
	return false -- 919
end -- 919
function removePendingQuestionnaire(session) -- 922
	local path = getQuestionnairePath(session.projectRoot) -- 923
	if not Content:exist(path) then -- 923
		return true -- 924
	end -- 924
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 925
	if questionnaire and questionnaire.sessionId ~= session.id then -- 925
		return false -- 926
	end -- 926
	if not Content:remove(path) then -- 926
		return false -- 927
	end -- 927
	Tools.sendWebIDEFileUpdate(path, false, "") -- 928
	return true -- 929
end -- 929
function publishQuestionnaire(request) -- 932
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 932
		local session = getSessionItem(request.sessionId) -- 938
		if not session or session.kind ~= "main" then -- 938
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 938
		end -- 938
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 940
		if Content:exist(pendingPath) then -- 940
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 940
		end -- 940
		local questionnaire = { -- 942
			id = request.taskId, -- 943
			sessionId = request.sessionId, -- 944
			taskId = request.taskId, -- 945
			step = request.step, -- 946
			status = "PENDING", -- 947
			schema = request.schema, -- 948
			createdAt = now() -- 949
		} -- 949
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 949
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 949
		end -- 949
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 949
	end) -- 949
end -- 949
function getMessageItem(messageId) -- 957
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 958
	return row and rowToMessage(row) or nil -- 964
end -- 964
function getStepItem(sessionId, taskId, step) -- 967
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 968
	return row and rowToStep(row) or nil -- 974
end -- 974
function deleteMessageSteps(sessionId, taskId) -- 977
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 978
	local ids = {} -- 983
	do -- 983
		local i = 0 -- 984
		while i < #rows do -- 984
			local row = rows[i + 1] -- 985
			if type(row[1]) == "number" then -- 985
				ids[#ids + 1] = row[1] -- 987
			end -- 987
			i = i + 1 -- 984
		end -- 984
	end -- 984
	if #ids > 0 then -- 984
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 991
	end -- 991
	return ids -- 997
end -- 997
function normalizeDisabledAgentTools(value) -- 1000
	if not __TS__ArrayIsArray(value) then -- 1000
		return {} -- 1001
	end -- 1001
	local tools = {} -- 1002
	do -- 1002
		local i = 0 -- 1003
		while i < #value do -- 1003
			do -- 1003
				local name = value[i + 1] -- 1004
				if name == "edit_file" and __TS__ArrayIndexOf(tools, "write_file") < 0 then -- 1004
					tools[#tools + 1] = "write_file" -- 1005
				end -- 1005
				if name == "delete_file" then -- 1005
					name = "edit_file" -- 1006
				end -- 1006
				if name == "glob_files" then -- 1006
					name = "grep_files" -- 1007
				end -- 1007
				if name == "spawn_sub_agent" or name == "list_sub_agents" then -- 1007
					name = "spawn_agent" -- 1008
				end -- 1008
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 1008
					goto __continue184 -- 1009
				end -- 1009
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 1009
					tools[#tools + 1] = name -- 1010
				end -- 1010
			end -- 1010
			::__continue184:: -- 1010
			i = i + 1 -- 1003
		end -- 1003
	end -- 1003
	return tools -- 1012
end -- 1012
function normalizeWorkMode(value, fallback) -- 1015
	if fallback == nil then -- 1015
		fallback = "code" -- 1015
	end -- 1015
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 1016
end -- 1016
function getSessionRow(sessionId) -- 1019
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 1020
end -- 1020
function getPendingSessionInputs(sessionId) -- 1028
	return __TS__ArrayMap( -- 1031
		__TS__ArrayFilter( -- 1031
			InputInbox.listInputs(sessionId), -- 1031
			function(____, item) return item.status ~= "delivering" end -- 1031
		), -- 1031
		function(____, item) return { -- 1032
			id = item.id, -- 1032
			content = item.content, -- 1032
			delivery = item.delivery, -- 1032
			held = item.held, -- 1032
			status = item.status -- 1032
		} end -- 1032
	) -- 1032
end -- 1032
function getSessionItem(sessionId) -- 1035
	local row = getSessionRow(sessionId) -- 1036
	if not row then -- 1036
		return nil -- 1037
	end -- 1037
	local session = rowToSession(row) -- 1038
	session.pendingInputs = getPendingSessionInputs(session.id) -- 1039
	return session -- 1040
end -- 1040
function getTaskPrompt(taskId) -- 1043
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1044
	if not row or type(row[1]) ~= "string" then -- 1044
		return nil -- 1045
	end -- 1045
	return toStr(row[1]) -- 1046
end -- 1046
function getLatestMainSessionByProjectRoot(projectRoot) -- 1049
	if not isValidProjectRoot(projectRoot) then -- 1049
		return nil -- 1050
	end -- 1050
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1051
	if not row then -- 1051
		return nil -- 1059
	end -- 1059
	local session = rowToSession(row) -- 1060
	session.pendingInputs = getPendingSessionInputs(session.id) -- 1061
	return session -- 1062
end -- 1062
function countRunningSubSessions(rootSessionId) -- 1065
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 1066
	local count = 0 -- 1073
	do -- 1073
		local i = 0 -- 1074
		while i < #rows do -- 1074
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1075
			if session.currentTaskStatus == "RUNNING" then -- 1075
				count = count + 1 -- 1077
			end -- 1077
			i = i + 1 -- 1074
		end -- 1074
	end -- 1074
	return count -- 1080
end -- 1080
function deleteSessionRecords(sessionId, preserveArtifacts) -- 1083
	if preserveArtifacts == nil then -- 1083
		preserveArtifacts = false -- 1083
	end -- 1083
	for ____, input in ipairs(InputInbox.listInputs(sessionId, true)) do -- 1084
		__TS__Delete(followup.configs, input.id) -- 1084
	end -- 1084
	DB:exec("DELETE FROM agent.AgentSessionInput WHERE session_id=?", {sessionId}) -- 1085
	__TS__Delete(followup.bindings, sessionId) -- 1086
	__TS__Delete(followup.recovered, sessionId) -- 1087
	streamUpdates:clear(sessionId) -- 1088
	local session = getSessionItem(sessionId) -- 1089
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 1090
	local taskIds = {} -- 1098
	do -- 1098
		local i = 0 -- 1099
		while i < #taskRows do -- 1099
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 1100
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 1100
				taskIds[#taskIds + 1] = taskId -- 1102
				local stopToken = activeStopTokens[taskId] -- 1103
				if stopToken ~= nil then -- 1103
					stopToken.stopped = true -- 1105
					stopToken.reason = "session deleted" -- 1106
				end -- 1106
			end -- 1106
			i = i + 1 -- 1099
		end -- 1099
	end -- 1099
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 1110
	do -- 1110
		local i = 0 -- 1111
		while i < #children do -- 1111
			local row = children[i + 1] -- 1112
			if type(row[1]) == "number" and row[1] > 0 then -- 1112
				deleteSessionRecords(row[1], preserveArtifacts) -- 1114
			end -- 1114
			i = i + 1 -- 1111
		end -- 1111
	end -- 1111
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 1117
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 1118
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 1119
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 1120
	if session and session.kind == "main" then -- 1120
		removePendingQuestionnaire(session) -- 1122
	end -- 1122
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 1122
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 1122
			Tools.sendWebIDERefreshTree() -- 1126
		end -- 1126
	end -- 1126
	do -- 1126
		local i = 0 -- 1129
		while i < #taskIds do -- 1129
			cleanupTaskHeavyData(taskIds[i + 1]) -- 1130
			i = i + 1 -- 1129
		end -- 1129
	end -- 1129
end -- 1129
function getSessionRootId(session) -- 1134
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 1135
end -- 1135
function getRootSessionItem(sessionId) -- 1138
	local session = getSessionItem(sessionId) -- 1139
	if not session then -- 1139
		return nil -- 1140
	end -- 1140
	return getSessionItem(getSessionRootId(session)) or session -- 1141
end -- 1141
function listRelatedSessions(sessionId) -- 1144
	local root = getRootSessionItem(sessionId) -- 1145
	if not root then -- 1145
		return {} -- 1146
	end -- 1146
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 1147
	return __TS__ArrayMap( -- 1156
		rows, -- 1156
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 1156
	) -- 1156
end -- 1156
function getSessionSpawnInfo(session) -- 1159
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1160
	if not info then -- 1160
		return nil -- 1161
	end -- 1161
	local ____temp_47 = type(info.sessionId) == "number" and info.sessionId or nil -- 1163
	local ____temp_48 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 1164
	local ____temp_49 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 1165
	local ____temp_50 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 1166
	local ____temp_51 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 1167
	local ____temp_52 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 1168
	local ____temp_53 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 1169
	local ____temp_54 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1170
		__TS__ArrayFilter( -- 1171
			info.filesHint, -- 1171
			function(____, item) return type(item) == "string" end -- 1171
		), -- 1171
		function(____, item) return sanitizeUTF8(item) end -- 1171
	) or nil -- 1171
	local ____temp_55 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 1173
	local ____temp_45 -- 1176
	if info.success == true then -- 1176
		____temp_45 = true -- 1176
	else -- 1176
		local ____temp_44 -- 1176
		if info.success == false then -- 1176
			____temp_44 = false -- 1176
		else -- 1176
			____temp_44 = nil -- 1176
		end -- 1176
		____temp_45 = ____temp_44 -- 1176
	end -- 1176
	local ____temp_46 -- 1177
	if info.cleared == true then -- 1177
		____temp_46 = true -- 1177
	else -- 1177
		____temp_46 = nil -- 1177
	end -- 1177
	return { -- 1162
		sessionId = ____temp_47, -- 1163
		rootSessionId = ____temp_48, -- 1164
		parentSessionId = ____temp_49, -- 1165
		title = ____temp_50, -- 1166
		prompt = ____temp_51, -- 1167
		goal = ____temp_52, -- 1168
		expectedOutput = ____temp_53, -- 1169
		filesHint = ____temp_54, -- 1170
		status = ____temp_55, -- 1173
		success = ____temp_45, -- 1176
		cleared = ____temp_46, -- 1177
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 1178
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 1179
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 1180
		changeSet = decodeChangeSetSummary(info.changeSet), -- 1181
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1182
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1183
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 1184
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 1185
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 1188
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 1189
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 1190
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 1191
	} -- 1191
end -- 1191
function ensureDirRecursive(dir) -- 1208
	if dir == "" then -- 1208
		return false -- 1209
	end -- 1209
	if Content:exist(dir) then -- 1209
		return Content:isdir(dir) -- 1210
	end -- 1210
	local parent = Path:getPath(dir) -- 1211
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1211
		if not ensureDirRecursive(parent) then -- 1211
			return false -- 1214
		end -- 1214
	end -- 1214
	return Content:mkdir(dir) -- 1217
end -- 1217
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1220
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1221
	if not Content:exist(dir) then -- 1221
		ensureDirRecursive(dir) -- 1223
	end -- 1223
	local path = Path(dir, SPAWN_INFO_FILE) -- 1225
	local text = safeJsonEncode(value) -- 1226
	if not text then -- 1226
		return false -- 1227
	end -- 1227
	local content = text .. "\n" -- 1228
	if not Content:save(path, content) then -- 1228
		return false -- 1230
	end -- 1230
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1232
	return true -- 1233
end -- 1233
function readSpawnInfo(projectRoot, memoryScope) -- 1236
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1237
	if not Content:exist(path) then -- 1237
		return nil -- 1238
	end -- 1238
	local text = Content:load(path) -- 1239
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1239
		return nil -- 1240
	end -- 1240
	local value = safeJsonDecode(text) -- 1241
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1241
		return value -- 1243
	end -- 1243
	return nil -- 1245
end -- 1245
function getArtifactRelativeDir(memoryScope) -- 1248
	return Path(".agent", memoryScope) -- 1249
end -- 1249
function getArtifactDir(projectRoot, memoryScope) -- 1252
	return Path( -- 1253
		projectRoot, -- 1253
		getArtifactRelativeDir(memoryScope) -- 1253
	) -- 1253
end -- 1253
function getResultRelativePath(memoryScope) -- 1256
	return Path( -- 1257
		getArtifactRelativeDir(memoryScope), -- 1257
		RESULT_FILE -- 1257
	) -- 1257
end -- 1257
function getResultPath(projectRoot, memoryScope) -- 1260
	return Path( -- 1261
		projectRoot, -- 1261
		getResultRelativePath(memoryScope) -- 1261
	) -- 1261
end -- 1261
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1264
	if resultFilePath == "" then -- 1264
		return "" -- 1265
	end -- 1265
	local path = Path(projectRoot, resultFilePath) -- 1266
	if not Content:exist(path) then -- 1266
		return "" -- 1267
	end -- 1267
	local text = sanitizeUTF8(Content:load(path)) -- 1268
	if __TS__StringTrim(text) == "" then -- 1268
		return "" -- 1269
	end -- 1269
	local marker = "\n## Summary\n" -- 1270
	local start = string.find(text, marker, 1, true) -- 1271
	if start ~= nil then -- 1271
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1273
	end -- 1273
	return __TS__StringTrim(text) -- 1275
end -- 1275
function buildStructuredSubAgentMemoryEntry(record) -- 1278
	local hasPassedValidation = false -- 1279
	do -- 1279
		local i = 0 -- 1280
		while i < #record.completion.validation do -- 1280
			local result = record.completion.validation[i + 1].result -- 1281
			if result == "failed" then -- 1281
				return nil -- 1286
			end -- 1286
			if result == "passed" then -- 1286
				hasPassedValidation = true -- 1288
			end -- 1288
			i = i + 1 -- 1280
		end -- 1280
	end -- 1280
	if not hasPassedValidation then -- 1280
		return nil -- 1291
	end -- 1291
	local candidates = record.completion.learningCandidates -- 1292
	local claims = {} -- 1293
	local evidence = {} -- 1294
	do -- 1294
		local i = 0 -- 1295
		while i < #candidates do -- 1295
			do -- 1295
				local candidate = candidates[i + 1] -- 1296
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1296
					goto __continue266 -- 1297
				end -- 1297
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1298
				do -- 1298
					local j = 0 -- 1299
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1299
						local item = candidate.evidence[j + 1] -- 1300
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1300
							evidence[#evidence + 1] = item -- 1301
						end -- 1301
						j = j + 1 -- 1299
					end -- 1299
				end -- 1299
			end -- 1299
			::__continue266:: -- 1299
			i = i + 1 -- 1295
		end -- 1295
	end -- 1295
	local content = takeUtf8Head( -- 1304
		table.concat(claims, "\n"), -- 1304
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1304
	) -- 1304
	if content == "" then -- 1304
		return nil -- 1305
	end -- 1305
	return { -- 1306
		sourceSessionId = record.sessionId, -- 1307
		sourceTaskId = record.sourceTaskId, -- 1308
		content = content, -- 1309
		evidence = evidence, -- 1310
		createdAt = record.finishedAt -- 1311
	} -- 1311
end -- 1311
function containsNormalizedText(text, query) -- 1315
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1316
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1317
	if normalizedQuery == "" then -- 1317
		return true -- 1318
	end -- 1318
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1319
end -- 1319
function getSubAgentDisplayKey(item) -- 1322
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1328
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1329
	local label = goal ~= "" and goal or title -- 1330
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1331
end -- 1331
function writeSubAgentResultFile(session, record, resultText) -- 1334
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1335
	if not Content:exist(dir) then -- 1335
		ensureDirRecursive(dir) -- 1337
	end -- 1337
	local ____array_64 = __TS__SparseArrayNew( -- 1337
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1340
		"- Status: " .. record.status, -- 1341
		"- Success: " .. (record.success and "true" or "false"), -- 1342
		"- Outcome: " .. record.completion.outcome, -- 1343
		"- Session ID: " .. tostring(record.sessionId), -- 1344
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1345
		"- Goal: " .. record.goal, -- 1346
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1347
	) -- 1347
	__TS__SparseArrayPush( -- 1347
		____array_64, -- 1347
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1348
	) -- 1348
	__TS__SparseArrayPush( -- 1348
		____array_64, -- 1348
		"- Finished At: " .. record.finishedAt, -- 1349
		"", -- 1350
		"## Validation", -- 1351
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1352
			record.completion.validation, -- 1353
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1353
		) or ({"- Not reported"})) -- 1353
	) -- 1353
	__TS__SparseArrayPush(____array_64, "", "## Recorded Evidence") -- 1353
	local ____opt_56 = record.handoffEvidence -- 1353
	__TS__SparseArrayPush( -- 1353
		____array_64, -- 1353
		table.unpack(____opt_56 and #____opt_56.modifiedFiles and __TS__ArrayMap( -- 1357
			record.handoffEvidence.modifiedFiles, -- 1358
			function(____, item) return "- modified: " .. item end -- 1358
		) or ({"- modified: none recorded"})) -- 1358
	) -- 1358
	local ____opt_58 = record.handoffEvidence -- 1358
	__TS__SparseArrayPush( -- 1358
		____array_64, -- 1358
		table.unpack(____opt_58 and ____opt_58.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1360
	) -- 1360
	local ____opt_60 = record.handoffEvidence -- 1360
	__TS__SparseArrayPush( -- 1360
		____array_64, -- 1360
		table.unpack(__TS__ArrayMap( -- 1363
			____opt_60 and ____opt_60.commands or ({}), -- 1363
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1363
		)) -- 1363
	) -- 1363
	local ____opt_62 = record.handoffEvidence -- 1363
	__TS__SparseArrayPush( -- 1363
		____array_64, -- 1363
		table.unpack(__TS__ArrayMap( -- 1364
			____opt_62 and ____opt_62.authoritativeSources or ({}), -- 1364
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1364
		)) -- 1364
	) -- 1364
	__TS__SparseArrayPush( -- 1364
		____array_64, -- 1364
		"", -- 1365
		"## Known Issues", -- 1366
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1367
			record.completion.knownIssues, -- 1367
			function(____, item) return "- " .. item end -- 1367
		) or ({"- None reported"})) -- 1367
	) -- 1367
	__TS__SparseArrayPush( -- 1367
		____array_64, -- 1367
		"", -- 1368
		"## Assumptions", -- 1369
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1370
			record.completion.assumptions, -- 1370
			function(____, item) return "- " .. item end -- 1370
		) or ({"- None reported"})) -- 1370
	) -- 1370
	__TS__SparseArrayPush(____array_64, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1370
	local lines = {__TS__SparseArraySpread(____array_64)} -- 1339
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1375
	local content = table.concat(lines, "\n") .. "\n" -- 1376
	if not Content:save(path, content) then -- 1376
		return false -- 1378
	end -- 1378
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1380
	return true -- 1381
end -- 1381
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1384
	local dir = Path(projectRoot, ".agent", "subagents") -- 1385
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1385
		return {} -- 1386
	end -- 1386
	local items = {} -- 1387
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1388
		do -- 1388
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1389
			if not Content:exist(path) or not Content:isdir(path) then -- 1389
				goto __continue286 -- 1390
			end -- 1390
			local info = readSpawnInfo( -- 1391
				projectRoot, -- 1391
				Path( -- 1391
					"subagents", -- 1391
					Path:getFilename(path) -- 1391
				) -- 1391
			) -- 1391
			if not info then -- 1391
				goto __continue286 -- 1392
			end -- 1392
			local sessionId = tonumber(info.sessionId) -- 1393
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1394
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1395
			local status = sanitizeUTF8(toStr(info.status)) -- 1396
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1396
				goto __continue286 -- 1397
			end -- 1397
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1397
				goto __continue286 -- 1398
			end -- 1398
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1399
			items[#items + 1] = { -- 1400
				sessionId = sessionId, -- 1401
				rootSessionId = infoRootSessionId, -- 1402
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1403
				title = sanitizeUTF8(toStr(info.title)), -- 1404
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1405
				goal = sanitizeUTF8(toStr(info.goal)), -- 1406
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1407
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1408
					__TS__ArrayFilter( -- 1409
						info.filesHint, -- 1409
						function(____, item) return type(item) == "string" end -- 1409
					), -- 1409
					function(____, item) return sanitizeUTF8(item) end -- 1409
				) or ({}), -- 1409
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1411
				success = info.success == true, -- 1412
				cleared = info.cleared == true, -- 1413
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1414
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1415
					"subagents", -- 1415
					Path:getFilename(path) -- 1415
				)), -- 1415
				sourceTaskId = sourceTaskId or 0, -- 1416
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1417
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1418
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1419
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1420
				completion = normalizeAgentCompletionReport(info.completion), -- 1421
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1422
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1423
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1424
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1425
			} -- 1425
		end -- 1425
		::__continue286:: -- 1425
	end -- 1425
	__TS__ArraySort( -- 1428
		items, -- 1428
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1428
	) -- 1428
	return items -- 1429
end -- 1429
function getPendingHandoffDir(projectRoot, memoryScope) -- 1432
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1433
end -- 1433
function writePendingHandoff(projectRoot, memoryScope, value) -- 1436
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1437
	if not Content:exist(dir) then -- 1437
		ensureDirRecursive(dir) -- 1439
	end -- 1439
	local path = Path(dir, value.id .. ".json") -- 1441
	local text = safeJsonEncode(value) -- 1442
	if not text then -- 1442
		return false -- 1443
	end -- 1443
	local content = text .. "\n" -- 1444
	if not Content:save(path, content) then -- 1444
		return false -- 1445
	end -- 1445
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1446
	return true -- 1447
end -- 1447
function listPendingHandoffs(projectRoot, memoryScope) -- 1450
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1451
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1451
		return {} -- 1452
	end -- 1452
	local items = {} -- 1453
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1454
		do -- 1454
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1455
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1455
				goto __continue302 -- 1456
			end -- 1456
			local text = Content:load(path) -- 1457
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1457
				goto __continue302 -- 1458
			end -- 1458
			local obj = safeJsonDecode(text) -- 1459
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1459
				goto __continue302 -- 1460
			end -- 1460
			local value = obj -- 1461
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1462
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1463
			local id = sanitizeUTF8(toStr(value.id)) -- 1464
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1465
			local message = sanitizeUTF8(toStr(value.message)) -- 1466
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1467
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1468
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1469
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1469
				goto __continue302 -- 1471
			end -- 1471
			items[#items + 1] = { -- 1473
				id = id, -- 1474
				sourceSessionId = sourceSessionId, -- 1475
				sourceTitle = sourceTitle, -- 1476
				sourceTaskId = sourceTaskId, -- 1477
				message = message, -- 1478
				prompt = prompt, -- 1479
				goal = goal, -- 1480
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1481
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1482
					__TS__ArrayFilter( -- 1483
						value.filesHint, -- 1483
						function(____, item) return type(item) == "string" end -- 1483
					), -- 1483
					function(____, item) return sanitizeUTF8(item) end -- 1483
				) or ({}), -- 1483
				success = value.success == true, -- 1485
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1486
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1487
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1488
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1489
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1490
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1491
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1492
				createdAt = createdAt -- 1495
			} -- 1495
		end -- 1495
		::__continue302:: -- 1495
	end -- 1495
	__TS__ArraySort( -- 1498
		items, -- 1498
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1498
	) -- 1498
	return items -- 1499
end -- 1499
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1502
	local path = Path( -- 1503
		getPendingHandoffDir(projectRoot, memoryScope), -- 1503
		id .. ".json" -- 1503
	) -- 1503
	if Content:exist(path) then -- 1503
		if Content:remove(path) then -- 1503
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1506
		end -- 1506
	end -- 1506
end -- 1506
function normalizePromptText(prompt) -- 1511
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1512
end -- 1512
function normalizePromptTextSafe(prompt) -- 1515
	if type(prompt) == "string" then -- 1515
		local normalized = normalizePromptText(prompt) -- 1517
		if normalized ~= "" then -- 1517
			return normalized -- 1518
		end -- 1518
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1519
		if sanitized ~= "" then -- 1519
			return truncateAgentUserPrompt(sanitized) -- 1521
		end -- 1521
		return "" -- 1523
	end -- 1523
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1525
	if text == "" then -- 1525
		return "" -- 1526
	end -- 1526
	return truncateAgentUserPrompt(text) -- 1527
end -- 1527
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1530
	local sections = {} -- 1531
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1532
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1533
	local normalizedFiles = __TS__ArrayFilter( -- 1534
		__TS__ArrayMap( -- 1534
			__TS__ArrayFilter( -- 1534
				filesHint or ({}), -- 1534
				function(____, item) return type(item) == "string" end -- 1535
			), -- 1535
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1536
		), -- 1536
		function(____, item) return item ~= "" end -- 1537
	) -- 1537
	if normalizedTitle ~= "" then -- 1537
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1539
	end -- 1539
	if normalizedExpected ~= "" then -- 1539
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1542
	end -- 1542
	if #normalizedFiles > 0 then -- 1542
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1545
	end -- 1545
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1547
end -- 1547
function normalizeSessionRuntimeState(session) -- 1550
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1550
		return session -- 1552
	end -- 1552
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1552
		return session -- 1555
	end -- 1555
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1555
		return session -- 1558
	end -- 1558
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1560
		session.id, -- 1563
		session.currentTaskId, -- 1563
		"fetch_url", -- 1563
		"execute_command", -- 1563
		"analyze_image" -- 1563
	}) or ({}) -- 1563
	if #pendingToolRows > 0 then -- 1563
		local t = now() -- 1566
		do -- 1566
			local i = 0 -- 1567
			while i < #pendingToolRows do -- 1567
				local row = pendingToolRows[i + 1] -- 1568
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1569
				result.success = false -- 1570
				result.state = "failed" -- 1571
				result.interrupted = true -- 1572
				result.message = "tool call was interrupted because the program exited before it completed." -- 1573
				DB:exec( -- 1574
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1574
					{ -- 1576
						encodeJson(result), -- 1576
						t, -- 1576
						row[1] -- 1576
					} -- 1576
				) -- 1576
				i = i + 1 -- 1567
			end -- 1567
		end -- 1567
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1579
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1580
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1581
	end -- 1581
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1588
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1589
	return __TS__ObjectAssign( -- 1590
		{}, -- 1590
		session, -- 1591
		{ -- 1590
			status = "STOPPED", -- 1592
			currentTaskStatus = "STOPPED", -- 1593
			updatedAt = now() -- 1594
		} -- 1594
	) -- 1594
end -- 1594
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1598
	DB:exec( -- 1599
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1599
		{ -- 1603
			status, -- 1604
			currentTaskId or 0, -- 1605
			currentTaskStatus or status, -- 1606
			now(), -- 1607
			sessionId -- 1608
		} -- 1608
	) -- 1608
end -- 1608
function decodeSessionMetrics(text) -- 1613
	local metrics = decodeJsonObject(text) -- 1614
	local context = metrics and metrics.context -- 1615
	if (context and context.source) == "llm_input_estimate" and type(context.maxTokens) == "number" and context.maxTokens > 0 and type(context.messagesTokens) == "number" then -- 1615
		local usedTokens = context.messagesTokens + (context.optionsTokens or 0) + (context.toolDefinitionsTokens or 0) + (context.structuralOverhead or 0) -- 1618
		return __TS__ObjectAssign( -- 1620
			{}, -- 1620
			metrics, -- 1621
			{context = __TS__ObjectAssign( -- 1620
				{}, -- 1622
				context, -- 1623
				{ -- 1622
					usedTokens = usedTokens, -- 1624
					ratio = math.max( -- 1625
						0, -- 1625
						math.min(1, usedTokens / context.maxTokens) -- 1625
					), -- 1625
					source = "llm_input_only_estimate" -- 1626
				} -- 1626
			)} -- 1626
		) -- 1626
	end -- 1626
	return metrics -- 1630
end -- 1630
function mergeAgentMetrics(current, next) -- 1633
	return __TS__ObjectAssign({}, current or ({}), next) -- 1634
end -- 1634
function updateSessionMetrics(sessionId, metrics) -- 1640
	local session = getSessionItem(sessionId) -- 1641
	if not session then -- 1641
		return nil -- 1642
	end -- 1642
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1643
	DB:exec( -- 1644
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1644
		{ -- 1648
			encodeJson(merged), -- 1649
			now(), -- 1650
			sessionId -- 1651
		} -- 1651
	) -- 1651
	return merged -- 1654
end -- 1654
function clearSessionTokenUsage(sessionId) -- 1657
	local session = getSessionItem(sessionId) -- 1658
	if not session then -- 1658
		return nil -- 1659
	end -- 1659
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1660
	__TS__Delete(metrics, "usage") -- 1661
	__TS__Delete(metrics, "visionUsage") -- 1662
	DB:exec( -- 1663
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1663
		{ -- 1667
			encodeJson(metrics), -- 1668
			now(), -- 1669
			sessionId -- 1670
		} -- 1670
	) -- 1670
	return metrics -- 1673
end -- 1673
function getInitialTokenUsage(session) -- 1676
	local ____opt_69 = session.metrics -- 1676
	local usage = ____opt_69 and ____opt_69.usage -- 1677
	if not usage or (usage.requestCount or 0) <= 0 then -- 1677
		return nil -- 1678
	end -- 1678
	return { -- 1679
		inputTokens = usage.inputTokens or 0, -- 1680
		outputTokens = usage.outputTokens or 0, -- 1681
		totalTokens = usage.totalTokens, -- 1682
		cachedInputTokens = usage.cachedInputTokens, -- 1683
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1684
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1685
		requestCount = usage.requestCount or 0, -- 1686
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1687
		model = usage.model or "", -- 1688
		phase = usage.phase or "", -- 1689
		step = usage.step or 0, -- 1690
		updatedAt = usage.updatedAt or now() -- 1691
	} -- 1691
end -- 1691
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1695
	if taskId == nil or taskId <= 0 then -- 1695
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1697
		return -- 1698
	end -- 1698
	local row = getSessionRow(sessionId) -- 1700
	if not row then -- 1700
		return -- 1701
	end -- 1701
	local session = rowToSession(row) -- 1702
	if session.currentTaskId ~= taskId then -- 1702
		Log( -- 1704
			"Info", -- 1704
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1704
		) -- 1704
		return -- 1705
	end -- 1705
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1707
end -- 1707
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1710
	local t = now() -- 1711
	DB:exec( -- 1712
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1712
		{ -- 1715
			sessionId, -- 1716
			taskId or 0, -- 1717
			role, -- 1718
			sanitizeUTF8(content), -- 1719
			displayContent and sanitizeUTF8(displayContent) or "", -- 1720
			t, -- 1721
			t -- 1722
		} -- 1722
	) -- 1722
	return getLastInsertRowId() -- 1725
end -- 1725
function updateMessage(messageId, content) -- 1728
	DB:exec( -- 1729
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1729
		{ -- 1731
			sanitizeUTF8(content), -- 1731
			now(), -- 1731
			messageId -- 1731
		} -- 1731
	) -- 1731
end -- 1731
function updateUserMessageForTask(messageId, content, taskId) -- 1735
	DB:exec( -- 1736
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1736
		{ -- 1740
			sanitizeUTF8(content), -- 1740
			taskId, -- 1740
			now(), -- 1740
			messageId -- 1740
		} -- 1740
	) -- 1740
end -- 1740
function removeContinuableTaskSummary(session) -- 1797
	local taskId = session.currentTaskId -- 1798
	if taskId == nil then -- 1798
		return -- 1799
	end -- 1799
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1800
end -- 1800
function upsertAssistantMessage(sessionId, taskId, content) -- 1812
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1813
	if row and type(row[1]) == "number" then -- 1813
		updateMessage(row[1], content) -- 1820
		return row[1] -- 1821
	end -- 1821
	return insertMessage(sessionId, "assistant", content, taskId) -- 1823
end -- 1823
function upsertStep(sessionId, taskId, step, tool, patch) -- 1826
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1836
	local reason = sanitizeUTF8(patch.reason or "") -- 1840
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1841
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1842
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1843
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1844
	local statusPatch = patch.status or "" -- 1845
	local status = patch.status or "PENDING" -- 1846
	if not row then -- 1846
		local t = now() -- 1848
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1849
			sessionId, -- 1853
			taskId, -- 1854
			step, -- 1855
			tool, -- 1856
			status, -- 1857
			reason, -- 1858
			reasoningContent, -- 1859
			paramsJson, -- 1860
			resultJson, -- 1861
			patch.checkpointId or 0, -- 1862
			patch.checkpointSeq or 0, -- 1863
			filesJson, -- 1864
			t, -- 1865
			t -- 1866
		}) -- 1866
		return -- 1869
	end -- 1869
	DB:exec( -- 1871
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1871
		{ -- 1883
			tool, -- 1884
			statusPatch, -- 1885
			status, -- 1886
			reason, -- 1887
			reason, -- 1888
			reasoningContent, -- 1889
			reasoningContent, -- 1890
			paramsJson, -- 1891
			paramsJson, -- 1892
			resultJson, -- 1893
			resultJson, -- 1894
			patch.checkpointId or 0, -- 1895
			patch.checkpointId or 0, -- 1896
			patch.checkpointSeq or 0, -- 1897
			patch.checkpointSeq or 0, -- 1898
			filesJson, -- 1899
			filesJson, -- 1900
			now(), -- 1901
			row[1] -- 1902
		} -- 1902
	) -- 1902
end -- 1902
function getNextStepNumber(sessionId, taskId) -- 1907
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1908
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1912
	return math.max(0, current) + 1 -- 1913
end -- 1913
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1954
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1962
	local t = now() -- 1963
	local sqls = { -- 1964
		{ -- 1965
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1965
			{{ -- 1968
				sessionId, -- 1969
				ownerTaskId, -- 1970
				step, -- 1971
				"sub_agent_handoff", -- 1972
				"DONE", -- 1973
				sanitizeUTF8(reason), -- 1974
				encodeJson(params), -- 1975
				encodeJson(result), -- 1976
				t, -- 1977
				t -- 1978
			}} -- 1978
		}, -- 1978
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1981
	} -- 1981
	if not DB:transaction(sqls) then -- 1981
		return nil -- 1987
	end -- 1987
	return getStepItem(sessionId, ownerTaskId, step) -- 1988
end -- 1988
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1991
	if taskId <= 0 then -- 1991
		return -- 1992
	end -- 1992
	if finalSteps ~= nil and finalSteps >= 0 then -- 1992
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1994
	end -- 1994
	if not finalStatus then -- 1994
		return -- 2000
	end -- 2000
	if finalSteps ~= nil and finalSteps >= 0 then -- 2000
		DB:exec( -- 2002
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 2002
			{ -- 2006
				finalStatus, -- 2006
				now(), -- 2006
				sessionId, -- 2006
				taskId, -- 2006
				finalSteps -- 2006
			} -- 2006
		) -- 2006
		return -- 2008
	end -- 2008
	DB:exec( -- 2010
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 2010
		{ -- 2014
			finalStatus, -- 2014
			now(), -- 2014
			sessionId, -- 2014
			taskId -- 2014
		} -- 2014
	) -- 2014
end -- 2014
function emitAgentSessionPatch(sessionId, patch) -- 2041
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 2042
	if not text then -- 2042
		return -- 2047
	end -- 2047
	local failed = publishSessionPatch(sessionId, text) -- 2048
	if failed > 0 then -- 2048
		Log( -- 2049
			"Warn", -- 2049
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 2049
		) -- 2049
	end -- 2049
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 2049
		emit("AppWS", "Send", text) -- 2050
	end -- 2050
end -- 2050
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 2053
	emitAgentSessionPatch( -- 2054
		sessionId, -- 2054
		{ -- 2054
			sessionDeleted = true, -- 2055
			relatedSessions = listRelatedSessions(rootSessionId) -- 2056
		} -- 2056
	) -- 2056
	local rootSession = getSessionItem(rootSessionId) -- 2058
	if rootSession then -- 2058
		emitAgentSessionPatch( -- 2060
			rootSessionId, -- 2060
			{ -- 2060
				session = rootSession, -- 2061
				relatedSessions = listRelatedSessions(rootSessionId) -- 2062
			} -- 2062
		) -- 2062
	end -- 2062
end -- 2062
function flushPendingSubAgentHandoffs(rootSession) -- 2067
	if rootSession.kind ~= "main" then -- 2067
		return -- 2068
	end -- 2068
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 2068
		return -- 2070
	end -- 2070
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 2072
	if #items == 0 then -- 2072
		return -- 2073
	end -- 2073
	local handoffTaskId = 0 -- 2074
	local previousTaskId = rootSession.currentTaskId -- 2075
	local ____rootSession_currentTaskId_73 -- 2076
	if rootSession.currentTaskId then -- 2076
		____rootSession_currentTaskId_73 = getTaskPrompt(rootSession.currentTaskId) -- 2076
	else -- 2076
		____rootSession_currentTaskId_73 = nil -- 2076
	end -- 2076
	local currentTaskPrompt = ____rootSession_currentTaskId_73 -- 2076
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 2076
		handoffTaskId = rootSession.currentTaskId -- 2084
	else -- 2084
		local taskRes = Tools.createTask( -- 2086
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 2086
			"code" -- 2086
		) -- 2086
		if not taskRes.success then -- 2086
			Log( -- 2088
				"Warn", -- 2088
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 2088
			) -- 2088
			return -- 2089
		end -- 2089
		handoffTaskId = taskRes.taskId -- 2091
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 2092
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 2093
		emitAgentSessionPatch( -- 2094
			rootSession.id, -- 2094
			{session = getSessionItem(rootSession.id)} -- 2094
		) -- 2094
	end -- 2094
	do -- 2094
		local i = 0 -- 2098
		while i < #items do -- 2098
			local item = items[i + 1] -- 2099
			local step = appendHandoffSystemStep( -- 2100
				rootSession.id, -- 2101
				handoffTaskId, -- 2102
				item.sourceTaskId, -- 2103
				item.message, -- 2104
				{ -- 2105
					sourceSessionId = item.sourceSessionId, -- 2106
					sourceTitle = item.sourceTitle, -- 2107
					sourceTaskId = item.sourceTaskId, -- 2108
					success = item.success == true, -- 2109
					summary = item.message, -- 2110
					resultFilePath = item.resultFilePath or "", -- 2111
					artifactDir = item.artifactDir or "", -- 2112
					finishedAt = item.finishedAt or "", -- 2113
					changeSet = item.changeSet, -- 2114
					handoffEvidence = item.handoffEvidence, -- 2115
					memoryEntry = item.memoryEntry, -- 2116
					completion = item.completion -- 2117
				}, -- 2117
				{ -- 2119
					sourceSessionId = item.sourceSessionId, -- 2120
					sourceTitle = item.sourceTitle, -- 2121
					sourceTaskId = item.sourceTaskId, -- 2122
					prompt = item.prompt, -- 2123
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 2124
					expectedOutput = item.expectedOutput or "", -- 2125
					filesHint = item.filesHint or ({}), -- 2126
					resultFilePath = item.resultFilePath or "", -- 2127
					artifactDir = item.artifactDir or "", -- 2128
					changeSet = item.changeSet, -- 2129
					handoffEvidence = item.handoffEvidence, -- 2130
					memoryEntry = item.memoryEntry, -- 2131
					completion = item.completion -- 2132
				} -- 2132
			) -- 2132
			if step then -- 2132
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 2136
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 2137
			else -- 2137
				Log( -- 2139
					"Warn", -- 2139
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 2139
				) -- 2139
			end -- 2139
			i = i + 1 -- 2098
		end -- 2098
	end -- 2098
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 2098
		cleanupTaskHeavyData(previousTaskId) -- 2143
	end -- 2143
end -- 2143
function applyEvent(sessionId, event) -- 2155
	if not getSessionItem(sessionId) then -- 2155
		streamUpdates:clear(sessionId) -- 2157
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 2157
			__TS__Delete(activeStopTokens, event.taskId) -- 2159
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 2160
		end -- 2160
		return -- 2162
	end -- 2162
	repeat -- 2162
		local ____switch399 = event.type -- 2162
		local metrics, startedSession -- 2162
		local ____cond399 = ____switch399 == "task_started" -- 2162
		if ____cond399 then -- 2162
			streamUpdates:clear(sessionId) -- 2166
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 2167
			local ____event_resumed_76 -- 2168
			if event.resumed then -- 2168
				local ____opt_74 = getSessionItem(sessionId) -- 2168
				____event_resumed_76 = ____opt_74 and ____opt_74.metrics -- 2169
			else -- 2169
				____event_resumed_76 = clearSessionTokenUsage(sessionId) -- 2170
			end -- 2170
			metrics = ____event_resumed_76 -- 2168
			startedSession = getSessionItem(sessionId) -- 2171
			emitAgentSessionPatch( -- 2172
				sessionId, -- 2172
				{ -- 2172
					session = startedSession, -- 2173
					metrics = metrics, -- 2174
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2175
				} -- 2175
			) -- 2175
			break -- 2179
		end -- 2179
		____cond399 = ____cond399 or ____switch399 == "decision_made" -- 2179
		if ____cond399 then -- 2179
			upsertStep( -- 2181
				sessionId, -- 2181
				event.taskId, -- 2181
				event.step, -- 2181
				event.tool, -- 2181
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 2181
			) -- 2181
			emitAgentSessionPatch( -- 2189
				sessionId, -- 2189
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2189
			) -- 2189
			break -- 2192
		end -- 2192
		____cond399 = ____cond399 or ____switch399 == "tool_started" -- 2192
		if ____cond399 then -- 2192
			upsertStep( -- 2194
				sessionId, -- 2194
				event.taskId, -- 2194
				event.step, -- 2194
				event.tool, -- 2194
				{status = "RUNNING"} -- 2194
			) -- 2194
			emitAgentSessionPatch( -- 2197
				sessionId, -- 2197
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2197
			) -- 2197
			break -- 2200
		end -- 2200
		____cond399 = ____cond399 or ____switch399 == "tool_finished" -- 2200
		if ____cond399 then -- 2200
			do -- 2200
				upsertStep( -- 2202
					sessionId, -- 2202
					event.taskId, -- 2202
					event.step, -- 2202
					event.tool, -- 2202
					{status = event.execution.status, reason = event.reason, result = event.result} -- 2202
				) -- 2202
				emitAgentSessionPatch( -- 2210
					sessionId, -- 2210
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2210
				) -- 2210
				break -- 2213
			end -- 2213
		end -- 2213
		____cond399 = ____cond399 or ____switch399 == "tool_progress" -- 2213
		if ____cond399 then -- 2213
			do -- 2213
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 2217
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 2217
					break -- 2219
				end -- 2219
			end -- 2219
			upsertStep( -- 2222
				sessionId, -- 2222
				event.taskId, -- 2222
				event.step, -- 2222
				event.tool, -- 2222
				{status = "RUNNING", result = event.result} -- 2222
			) -- 2222
			emitAgentSessionPatch( -- 2226
				sessionId, -- 2226
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2226
			) -- 2226
			break -- 2229
		end -- 2229
		____cond399 = ____cond399 or ____switch399 == "checkpoint_created" -- 2229
		if ____cond399 then -- 2229
			upsertStep( -- 2231
				sessionId, -- 2231
				event.taskId, -- 2231
				event.step, -- 2231
				event.tool, -- 2231
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2231
			) -- 2231
			emitAgentSessionPatch( -- 2236
				sessionId, -- 2236
				{ -- 2236
					step = getStepItem(sessionId, event.taskId, event.step), -- 2237
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2238
				} -- 2238
			) -- 2238
			break -- 2240
		end -- 2240
		____cond399 = ____cond399 or ____switch399 == "memory_compression_started" -- 2240
		if ____cond399 then -- 2240
			upsertStep( -- 2242
				sessionId, -- 2242
				event.taskId, -- 2242
				event.step, -- 2242
				event.tool, -- 2242
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2242
			) -- 2242
			emitAgentSessionPatch( -- 2247
				sessionId, -- 2247
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2247
			) -- 2247
			break -- 2250
		end -- 2250
		____cond399 = ____cond399 or ____switch399 == "memory_compression_finished" -- 2250
		if ____cond399 then -- 2250
			upsertStep( -- 2252
				sessionId, -- 2252
				event.taskId, -- 2252
				event.step, -- 2252
				event.tool, -- 2252
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2252
			) -- 2252
			emitAgentSessionPatch( -- 2257
				sessionId, -- 2257
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2257
			) -- 2257
			break -- 2260
		end -- 2260
		____cond399 = ____cond399 or ____switch399 == "metrics_updated" -- 2260
		if ____cond399 then -- 2260
			do -- 2260
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2262
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2263
				break -- 2266
			end -- 2266
		end -- 2266
		____cond399 = ____cond399 or ____switch399 == "assistant_message_updated" -- 2266
		if ____cond399 then -- 2266
			do -- 2266
				local session = getSessionItem(sessionId) -- 2269
				if (session and session.currentTaskId) ~= event.taskId then -- 2269
					streamUpdates:clear(sessionId, event.taskId) -- 2271
					break -- 2271
				end -- 2271
				streamUpdates:update( -- 2273
					sessionId, -- 2273
					event.taskId, -- 2273
					event.step, -- 2273
					event, -- 2273
					App.runningTime -- 2273
				) -- 2273
				scheduleStreamFlush() -- 2274
				break -- 2275
			end -- 2275
		end -- 2275
		____cond399 = ____cond399 or ____switch399 == "assistant_message_finished" -- 2275
		if ____cond399 then -- 2275
			do -- 2275
				local ____opt_79 = getSessionItem(sessionId) -- 2275
				if (____opt_79 and ____opt_79.currentTaskId) ~= event.taskId then -- 2275
					streamUpdates:clear(sessionId, event.taskId) -- 2279
					break -- 2279
				end -- 2279
				streamUpdates:finish(sessionId, event.taskId, event.step) -- 2281
				upsertStep( -- 2282
					sessionId, -- 2282
					event.taskId, -- 2282
					event.step, -- 2282
					"message", -- 2282
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2282
				) -- 2282
				emitAgentSessionPatch( -- 2288
					sessionId, -- 2288
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2288
				) -- 2288
				break -- 2291
			end -- 2291
		end -- 2291
		____cond399 = ____cond399 or ____switch399 == "task_waiting_for_user" -- 2291
		if ____cond399 then -- 2291
			do -- 2291
				local ____opt_81 = getSessionItem(sessionId) -- 2291
				if (____opt_81 and ____opt_81.currentTaskId) ~= event.taskId then -- 2291
					streamUpdates:clear(sessionId, event.taskId) -- 2295
					break -- 2295
				end -- 2295
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2297
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2298
				__TS__Delete(activeStopTokens, event.taskId) -- 2299
				emitAgentSessionPatch( -- 2300
					sessionId, -- 2300
					{ -- 2300
						session = getSessionItem(sessionId), -- 2301
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2302
					} -- 2302
				) -- 2302
				break -- 2304
			end -- 2304
		end -- 2304
		____cond399 = ____cond399 or ____switch399 == "task_finished" -- 2304
		if ____cond399 then -- 2304
			do -- 2304
				local session = getSessionItem(sessionId) -- 2307
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2307
					__TS__Delete(activeStopTokens, event.taskId) -- 2309
					streamUpdates:clear(sessionId, event.taskId) -- 2310
					Log( -- 2311
						"Info", -- 2311
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2311
					) -- 2311
					break -- 2312
				end -- 2312
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2314
				local ____opt_83 = activeStopTokens[event.taskId or -1] -- 2314
				local stopped = (____opt_83 and ____opt_83.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2315
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2317
				local isSubSession = (session and session.kind) == "sub" -- 2320
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2321
				if isSubSession and event.taskId ~= nil then -- 2321
					finalizingSubSessionTaskIds[event.taskId] = true -- 2323
				end -- 2323
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2325
				if event.taskId ~= nil then -- 2325
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2327
					local ____finalizeTaskSteps_89 = finalizeTaskSteps -- 2328
					local ____array_88 = __TS__SparseArrayNew( -- 2328
						sessionId, -- 2329
						event.taskId, -- 2330
						type(event.steps) == "number" and math.max( -- 2331
							0, -- 2331
							math.floor(event.steps) -- 2331
						) or nil -- 2331
					) -- 2331
					local ____event_success_87 -- 2332
					if event.success then -- 2332
						____event_success_87 = nil -- 2332
					else -- 2332
						____event_success_87 = stopped and "STOPPED" or "FAILED" -- 2332
					end -- 2332
					__TS__SparseArrayPush(____array_88, ____event_success_87) -- 2332
					____finalizeTaskSteps_89(__TS__SparseArraySpread(____array_88)) -- 2328
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2334
					if not isSubSession then -- 2334
						__TS__Delete(activeStopTokens, event.taskId) -- 2336
					end -- 2336
					emitAgentSessionPatch( -- 2338
						sessionId, -- 2338
						{ -- 2338
							session = getSessionItem(sessionId), -- 2339
							message = getMessageItem(messageId), -- 2340
							removedStepIds = removedStepIds -- 2341
						} -- 2341
					) -- 2341
				end -- 2341
				if session and session.kind == "main" then -- 2341
					flushPendingSubAgentHandoffs(session) -- 2345
				end -- 2345
				break -- 2347
			end -- 2347
		end -- 2347
	until true -- 2347
end -- 2347
function ____exports.createSession(projectRoot, title) -- 2352
	if title == nil then -- 2352
		title = "" -- 2352
	end -- 2352
	local storage = requireAgentStorage() -- 2353
	if not storage.success then -- 2353
		return storage -- 2354
	end -- 2354
	if not isValidProjectRoot(projectRoot) then -- 2354
		return {success = false, message = "invalid projectRoot"} -- 2356
	end -- 2356
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2358
	if row then -- 2358
		return { -- 2367
			success = true, -- 2367
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2367
		} -- 2367
	end -- 2367
	local t = now() -- 2369
	DB:exec( -- 2370
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2370
		{ -- 2373
			projectRoot, -- 2373
			title ~= "" and title or Path:getFilename(projectRoot), -- 2373
			t, -- 2373
			t -- 2373
		} -- 2373
	) -- 2373
	local sessionId = getLastInsertRowId() -- 2375
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2376
	local session = getSessionItem(sessionId) -- 2377
	if not session then -- 2377
		return {success = false, message = "failed to create session"} -- 2379
	end -- 2379
	return {success = true, session = session} -- 2381
end -- 2352
function ____exports.createSubSession(parentSessionId, title) -- 2384
	if title == nil then -- 2384
		title = "" -- 2384
	end -- 2384
	local storage = requireAgentStorage() -- 2385
	if not storage.success then -- 2385
		return storage -- 2386
	end -- 2386
	local parent = getSessionItem(parentSessionId) -- 2387
	if not parent then -- 2387
		return {success = false, message = "parent session not found"} -- 2389
	end -- 2389
	local rootId = getSessionRootId(parent) -- 2391
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2391
		return {success = false, message = "project task admission is closed"} -- 2392
	end -- 2392
	local t = now() -- 2393
	DB:exec( -- 2394
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2394
		{ -- 2397
			parent.projectRoot, -- 2397
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2397
			rootId, -- 2397
			parent.id, -- 2397
			t, -- 2397
			t -- 2397
		} -- 2397
	) -- 2397
	local sessionId = getLastInsertRowId() -- 2399
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2400
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2401
	local session = getSessionItem(sessionId) -- 2402
	if not session then -- 2402
		return {success = false, message = "failed to create sub session"} -- 2404
	end -- 2404
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2406
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2407
	subStorage:writeMemory(parentStorage:readMemory()) -- 2408
	return {success = true, session = session} -- 2409
end -- 2384
function spawnSubAgentSession(request) -- 2412
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2412
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2425
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2426
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2427
		if normalizedPrompt == "" then -- 2427
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2429
		end -- 2429
		if normalizedPrompt == "" then -- 2429
			local ____Log_95 = Log -- 2436
			local ____temp_92 = #normalizedTitle -- 2436
			local ____temp_93 = #rawPrompt -- 2436
			local ____temp_94 = #toStr(request.expectedOutput) -- 2436
			local ____opt_90 = request.filesHint -- 2436
			____Log_95( -- 2436
				"Warn", -- 2436
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_92)) .. " raw_prompt_len=") .. tostring(____temp_93)) .. " expected_len=") .. tostring(____temp_94)) .. " files_hint_count=") .. tostring(____opt_90 and #____opt_90 or 0) -- 2436
			) -- 2436
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2436
		end -- 2436
		Log( -- 2439
			"Info", -- 2439
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2439
		) -- 2439
		local parentSessionId = request.parentSessionId -- 2440
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2440
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2442
			if not fallbackParent then -- 2442
				local createdMain = ____exports.createSession(request.projectRoot) -- 2444
				if createdMain.success then -- 2444
					fallbackParent = createdMain.session -- 2446
				end -- 2446
			end -- 2446
			if fallbackParent then -- 2446
				Log( -- 2450
					"Warn", -- 2450
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2450
				) -- 2450
				parentSessionId = fallbackParent.id -- 2451
			end -- 2451
		end -- 2451
		local parentSession = getSessionItem(parentSessionId) -- 2454
		if not parentSession then -- 2454
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2454
		end -- 2454
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2458
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2458
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2458
		end -- 2458
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2458
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2458
		end -- 2458
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2463
		if not created.success then -- 2463
			return ____awaiter_resolve(nil, created) -- 2463
		end -- 2463
		writeSpawnInfo( -- 2467
			created.session.projectRoot, -- 2467
			created.session.memoryScope, -- 2467
			{ -- 2467
				sessionId = created.session.id, -- 2468
				rootSessionId = created.session.rootSessionId, -- 2469
				parentSessionId = created.session.parentSessionId, -- 2470
				title = created.session.title, -- 2471
				prompt = normalizedPrompt, -- 2472
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2473
				expectedOutput = request.expectedOutput or "", -- 2474
				filesHint = request.filesHint or ({}), -- 2475
				status = "RUNNING", -- 2476
				success = false, -- 2477
				resultFilePath = "", -- 2478
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2479
				sourceTaskId = 0, -- 2480
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2481
				createdAtTs = created.session.createdAt, -- 2482
				finishedAt = "", -- 2483
				finishedAtTs = 0 -- 2484
			} -- 2484
		) -- 2484
		local sent = ____exports.sendPrompt( -- 2486
			created.session.id, -- 2486
			normalizedPrompt, -- 2486
			request.disabledAgentTools, -- 2486
			nil, -- 2486
			nil, -- 2486
			request.llmConfig -- 2486
		) -- 2486
		if not sent.success then -- 2486
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2486
		end -- 2486
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2486
	end) -- 2486
end -- 2486
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2610
	local rootSession = getRootSessionItem(session.id) -- 2611
	if not rootSession then -- 2611
		return -- 2612
	end -- 2612
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2613
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2614
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2615
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2616
	local queueResult = writePendingHandoff( -- 2617
		rootSession.projectRoot, -- 2617
		rootSession.memoryScope, -- 2617
		{ -- 2617
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2618
			sourceSessionId = session.id, -- 2619
			sourceTitle = session.title, -- 2620
			sourceTaskId = taskId, -- 2621
			message = summary, -- 2622
			prompt = result.prompt, -- 2623
			goal = result.goal, -- 2624
			expectedOutput = result.expectedOutput or "", -- 2625
			filesHint = result.filesHint or ({}), -- 2626
			success = result.success, -- 2627
			resultFilePath = result.resultFilePath, -- 2628
			artifactDir = result.artifactDir, -- 2629
			finishedAt = result.finishedAt, -- 2630
			changeSet = changeSet, -- 2631
			handoffEvidence = result.handoffEvidence, -- 2632
			memoryEntry = result.memoryEntry, -- 2633
			completion = result.completion, -- 2634
			createdAt = createdAt -- 2635
		} -- 2635
	) -- 2635
	if not queueResult then -- 2635
		Log( -- 2638
			"Warn", -- 2638
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2638
		) -- 2638
		return -- 2639
	end -- 2639
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2639
		addTaskReference(rootSession.currentTaskId, taskId) -- 2642
	end -- 2642
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2642
		flushPendingSubAgentHandoffs(rootSession) -- 2645
	end -- 2645
end -- 2645
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2649
	if forceHandoff == nil then -- 2649
		forceHandoff = false -- 2655
	end -- 2655
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2655
		local rootSessionId = getSessionRootId(session) -- 2657
		local rootSession = getRootSessionItem(session.id) -- 2658
		if not rootSession then -- 2658
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2658
		end -- 2658
		local spawnInfo = getSessionSpawnInfo(session) -- 2662
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2663
		local finishedAtTs = now() -- 2664
		local resultText = sanitizeUTF8(message) -- 2665
		local changeSet = getTaskChangeSetSummary(taskId) -- 2666
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2667
		local ____completion_107 = completion -- 2669
		if ____completion_107 == nil then -- 2669
			local ____normalizeAgentCompletionReport_106 = normalizeAgentCompletionReport -- 2669
			local ____opt_104 = handoffEvidence.lastBuild -- 2669
			____completion_107 = ____normalizeAgentCompletionReport_106({outcome = (____opt_104 and ____opt_104.result) == "passed" and "completed" or "partial", knownIssues = {}}) -- 2669
		end -- 2669
		local completionReport = ____completion_107 -- 2669
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2673
		if not success and completionReport.outcome == "completed" and not forceHandoff then -- 2673
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "blocked", knownIssues = {resultText ~= "" and resultText or "The sub-agent did not complete."}})) -- 2675
		end -- 2675
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2675
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2682
		end -- 2682
		local completed = success and completionReport.outcome == "completed" -- 2690
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2691
		local record = { -- 2694
			sessionId = session.id, -- 2695
			rootSessionId = rootSessionId, -- 2696
			parentSessionId = session.parentSessionId, -- 2697
			title = session.title, -- 2698
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2699
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2700
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2701
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2702
			status = recordStatus, -- 2703
			success = completed, -- 2704
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2705
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2706
			sourceTaskId = taskId, -- 2707
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2708
			finishedAt = finishedAt, -- 2709
			createdAtTs = session.createdAt, -- 2710
			finishedAtTs = finishedAtTs, -- 2711
			changeSet = changeSet, -- 2712
			handoffEvidence = handoffEvidence, -- 2713
			completion = completionReport -- 2714
		} -- 2714
		local ____record_success_118 -- 2716
		if record.success then -- 2716
			____record_success_118 = buildStructuredSubAgentMemoryEntry(record) -- 2716
		else -- 2716
			____record_success_118 = nil -- 2716
		end -- 2716
		record.memoryEntry = ____record_success_118 -- 2716
		if not writeSubAgentResultFile(session, record, resultText) then -- 2716
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2716
		end -- 2716
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2716
			sessionId = record.sessionId, -- 2721
			rootSessionId = record.rootSessionId, -- 2722
			parentSessionId = record.parentSessionId, -- 2723
			title = record.title, -- 2724
			prompt = record.prompt, -- 2725
			goal = record.goal, -- 2726
			expectedOutput = record.expectedOutput or "", -- 2727
			filesHint = record.filesHint or ({}), -- 2728
			status = record.status, -- 2729
			success = record.success, -- 2730
			resultFilePath = record.resultFilePath, -- 2731
			artifactDir = record.artifactDir, -- 2732
			sourceTaskId = record.sourceTaskId, -- 2733
			createdAt = record.createdAt, -- 2734
			finishedAt = record.finishedAt, -- 2735
			createdAtTs = record.createdAtTs, -- 2736
			finishedAtTs = record.finishedAtTs, -- 2737
			changeSet = record.changeSet, -- 2738
			handoffEvidence = record.handoffEvidence, -- 2739
			memoryEntry = record.memoryEntry, -- 2740
			memoryEntryError = record.memoryEntryError, -- 2741
			completion = record.completion -- 2742
		}) then -- 2742
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2742
		end -- 2742
		if success or forceHandoff then -- 2742
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2747
			deleteSessionRecords(session.id, true) -- 2748
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2749
		end -- 2749
		return ____awaiter_resolve(nil, {success = true}) -- 2749
	end) -- 2749
end -- 2749
function stopClearedSubSession(session, taskId) -- 2754
	local spawnInfo = getSessionSpawnInfo(session) -- 2755
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2756
	local rootSessionId = getSessionRootId(session) -- 2757
	Tools.setTaskStatus(taskId, "STOPPED") -- 2758
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2759
	if not writeSpawnInfo( -- 2759
		session.projectRoot, -- 2760
		session.memoryScope, -- 2760
		{ -- 2760
			sessionId = session.id, -- 2761
			rootSessionId = rootSessionId, -- 2762
			parentSessionId = session.parentSessionId, -- 2763
			title = session.title, -- 2764
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2765
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2766
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2767
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2768
			status = "STOPPED", -- 2769
			success = false, -- 2770
			cleared = true, -- 2771
			resultFilePath = "", -- 2772
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2773
			sourceTaskId = taskId, -- 2774
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2775
			finishedAt = finishedAt, -- 2776
			createdAtTs = session.createdAt, -- 2777
			finishedAtTs = now() -- 2778
		} -- 2778
	) then -- 2778
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2780
	end -- 2780
	deleteSessionRecords(session.id, true) -- 2782
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2783
	return {success = true} -- 2784
end -- 2784
function startImmediatePrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, inputId) -- 2787
	local session = getSessionItem(sessionId) -- 2788
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2788
		return {success = false, message = "project task admission is closed"} -- 2789
	end -- 2789
	if not session then -- 2789
		return {success = false, message = "session not found"} -- 2791
	end -- 2791
	if getPendingQuestionnaire(sessionId) then -- 2791
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2793
	end -- 2793
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2793
		return {success = false, message = "session task is finalizing"} -- 2795
	end -- 2795
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2795
		return {success = false, message = "session task is still running"} -- 2798
	end -- 2798
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2800
	if normalizedPrompt == "" and session.kind == "sub" then -- 2800
		local spawnInfo = getSessionSpawnInfo(session) -- 2802
		if spawnInfo then -- 2802
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2804
			if normalizedPrompt == "" then -- 2804
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2806
			end -- 2806
		end -- 2806
	end -- 2806
	if normalizedPrompt == "" then -- 2806
		return {success = false, message = "prompt is empty"} -- 2815
	end -- 2815
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2817
	if session.workMode ~= nextWorkMode then -- 2817
		DB:exec( -- 2819
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2819
			{ -- 2819
				nextWorkMode, -- 2819
				now(), -- 2819
				session.id -- 2819
			} -- 2819
		) -- 2819
		session.workMode = nextWorkMode -- 2820
	end -- 2820
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2822
	return startPromptTask( -- 2823
		session, -- 2823
		normalizedPrompt, -- 2823
		nil, -- 2823
		normalizeDisabledAgentTools(disabledAgentTools), -- 2823
		{ -- 2823
			workMode = nextWorkMode, -- 2823
			llmConfigId = llmConfigId, -- 2823
			llmConfig = llmConfig, -- 2823
			maxSteps = boundedMaxSteps, -- 2823
			inputId = inputId -- 2823
		} -- 2823
	) -- 2823
end -- 2823
function startLocalPrompt(sessionId, prompt, localAgentConfigId, inputId) -- 2826
	local session = getSessionItem(sessionId) -- 2827
	if not session then -- 2827
		return {success = false, message = "session not found"} -- 2828
	end -- 2828
	if session.kind ~= "main" then -- 2828
		return {success = false, message = "local Agent only supports main sessions"} -- 2829
	end -- 2829
	if getPendingQuestionnaire(sessionId) then -- 2829
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2830
	end -- 2830
	if session.currentTaskStatus == "RUNNING" then -- 2830
		return {success = false, message = "session task is still running"} -- 2831
	end -- 2831
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2832
	if normalizedPrompt == "" then -- 2832
		return {success = false, message = "prompt is empty"} -- 2833
	end -- 2833
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2834
	if not config then -- 2834
		return {success = false, message = "local Agent config not found"} -- 2835
	end -- 2835
	if not config.verifiedAt then -- 2835
		return {success = false, message = "local Agent config is not verified"} -- 2836
	end -- 2836
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2837
	if not taskRes.success then -- 2837
		return taskRes -- 2838
	end -- 2838
	local taskId = taskRes.taskId -- 2839
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2840
	if inputId ~= nil then -- 2840
		InputInbox.markDelivering(inputId, taskId) -- 2841
		InputInbox.markDelivered(inputId, messageId) -- 2841
	end -- 2841
	followup.activeRuns[sessionId] = taskId -- 2842
	Tools.setTaskStatus(taskId, "RUNNING") -- 2843
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2844
	upsertStep( -- 2845
		session.id, -- 2845
		taskId, -- 2845
		1, -- 2845
		"local_agent_message", -- 2845
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2845
	) -- 2845
	emitAgentSessionPatch( -- 2851
		session.id, -- 2851
		{ -- 2851
			session = getSessionItem(session.id), -- 2852
			message = getMessageItem(messageId), -- 2853
			step = getStepItem(session.id, taskId, 1) -- 2854
		} -- 2854
	) -- 2854
	local events = {} -- 2856
	local transcript = "" -- 2857
	local assistant = "" -- 2858
	local lastFlush = 0 -- 2859
	local function flush(force) -- 2860
		if force == nil then -- 2860
			force = false -- 2860
		end -- 2860
		if not force and App.runningTime - lastFlush < 0.075 then -- 2860
			return -- 2861
		end -- 2861
		lastFlush = App.runningTime -- 2862
		if #events > 400 then -- 2862
			events = __TS__ArraySlice(events, #events - 400) -- 2863
		end -- 2863
		if #transcript > 1024 * 1024 then -- 2863
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2864
		end -- 2864
		upsertStep( -- 2865
			session.id, -- 2865
			taskId, -- 2865
			1, -- 2865
			"local_agent_message", -- 2865
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2865
		) -- 2865
		local message -- 2870
		if assistant ~= "" then -- 2870
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2872
			message = getMessageItem(assistantId) -- 2873
		end -- 2873
		emitAgentSessionPatch( -- 2875
			session.id, -- 2875
			__TS__ObjectAssign( -- 2875
				{step = getStepItem(session.id, taskId, 1)}, -- 2875
				message and ({message = message}) or ({}) -- 2875
			) -- 2875
		) -- 2875
	end -- 2860
	local completedSynchronously = false -- 2877
	local control = LocalAgent.run( -- 2878
		session.id, -- 2878
		config, -- 2878
		session.projectRoot, -- 2878
		normalizedPrompt, -- 2878
		function(event) -- 2878
			local text = sanitizeUTF8(event.text) -- 2879
			if text == "" then -- 2879
				return -- 2880
			end -- 2880
			local previous = #events > 0 and events[#events] or nil -- 2881
			if previous and previous.kind == event.kind and previous.text == text then -- 2881
				return -- 2882
			end -- 2882
			events[#events + 1] = {kind = event.kind, text = text} -- 2883
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2884
			if event.kind == "assistant" then -- 2884
				assistant = text -- 2885
			end -- 2885
			flush(false) -- 2886
		end, -- 2878
		function(result) -- 2887
			completedSynchronously = true -- 2888
			flush(true) -- 2889
			__TS__Delete(activeLocalAgentControls, taskId) -- 2890
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2891
			Tools.setTaskStatus(taskId, status) -- 2892
			setSessionState(session.id, status, taskId, status) -- 2893
			upsertStep( -- 2894
				session.id, -- 2894
				taskId, -- 2894
				1, -- 2894
				"local_agent_message", -- 2894
				{status = status, reason = config.name .. " · full permissions", result = { -- 2894
					provider = config.provider, -- 2897
					events = events, -- 2897
					transcript = transcript, -- 2897
					exitCode = result.exitCode, -- 2897
					resumeId = result.resumeId, -- 2897
					message = result.message -- 2897
				}} -- 2897
			) -- 2897
			emitAgentSessionPatch( -- 2899
				session.id, -- 2899
				{ -- 2899
					session = getSessionItem(session.id), -- 2899
					step = getStepItem(session.id, taskId, 1) -- 2899
				} -- 2899
			) -- 2899
			followup.settle(sessionId, taskId, result.success and not result.stopped) -- 2900
		end -- 2887
	) -- 2887
	if not completedSynchronously then -- 2887
		activeLocalAgentControls[taskId] = control -- 2902
	end -- 2902
	return {success = true, sessionId = session.id, taskId = taskId} -- 2903
end -- 2903
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2976
	if disabledAgentTools == nil then -- 2976
		disabledAgentTools = {} -- 2980
	end -- 2980
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2983
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2983
		return {success = false, message = "project task admission is closed"} -- 2984
	end -- 2984
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2985
	if not llmConfigRes.success then -- 2985
		return {success = false, message = llmConfigRes.message} -- 2989
	end -- 2989
	local llmConfig = llmConfigRes.config -- 2991
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2992
	if not llmConfigValidation.success then -- 2992
		return llmConfigValidation -- 2994
	end -- 2994
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2996
	if not taskRes.success then -- 2996
		return {success = false, message = taskRes.message} -- 2999
	end -- 2999
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2999
		removeContinuableTaskSummary(session) -- 3001
	end -- 3001
	local taskId = taskRes.taskId -- 3003
	if (options and options.inputId) ~= nil then -- 3003
		InputInbox.markDelivering(options.inputId, taskId) -- 3004
	end -- 3004
	followup.activeRuns[session.id] = taskId -- 3005
	local ____temp_141 -- 3006
	if (options and options.existingTaskId) == nil then -- 3006
		____temp_141 = session.currentTaskId -- 3006
	else -- 3006
		____temp_141 = nil -- 3006
	end -- 3006
	local previousTaskId = ____temp_141 -- 3006
	local useChineseResponse = getDefaultUseChineseResponse() -- 3007
	local promptMessageId -- 3008
	if existingUserMessageId ~= nil then -- 3008
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 3010
		promptMessageId = existingUserMessageId -- 3011
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 3011
		promptMessageId = insertMessage( -- 3013
			session.id, -- 3013
			"user", -- 3013
			normalizedPrompt, -- 3013
			taskId, -- 3013
			options and options.displayContent -- 3013
		) -- 3013
	end -- 3013
	if (options and options.inputId) ~= nil and promptMessageId ~= nil then -- 3013
		if DB:exec("UPDATE agent.AgentSessionInput SET message_id=? WHERE id=?", {promptMessageId, options.inputId}) < 0 then -- 3013
			error( -- 3016
				__TS__New(Error, "failed to link input display"), -- 3016
				0 -- 3016
			) -- 3016
		end -- 3016
		if normalizedPrompt == "/clear" or normalizedPrompt == "/compact" then -- 3016
			InputInbox.markDelivered(options.inputId, promptMessageId) -- 3017
		end -- 3017
	end -- 3017
	local stopToken = {stopped = false} -- 3019
	activeStopTokens[taskId] = stopToken -- 3020
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3021
	emitAgentSessionPatch( -- 3025
		session.id, -- 3025
		__TS__ObjectAssign( -- 3025
			{session = getSessionItem(session.id)}, -- 3025
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 3027
		) -- 3027
	) -- 3027
	if previousTaskId and previousTaskId ~= taskId then -- 3027
		cleanupTaskHeavyData(previousTaskId) -- 3030
	end -- 3030
	activePromptRuns = activePromptRuns + 1 -- 3032
	local ____runCodingAgent_176 = runCodingAgent -- 3033
	local ____normalizedPrompt_167 = normalizedPrompt -- 3034
	local ____temp_168 = options and options.inputId -- 3035
	local ____temp_169 = { -- 3036
		pending = function() return __TS__ArrayMap( -- 3037
			__TS__ArrayFilter( -- 3037
				InputInbox.listInputs(session.id), -- 3037
				function(____, item) return item.delivery == "steer" and not item.held and item.status == "pending" end -- 3037
			), -- 3037
			function(____, item) return {id = item.id, content = item.content} end -- 3037
		) end, -- 3037
		delivered = function(id, step) return followup.delivered(session.id, taskId, id, step) end -- 3038
	} -- 3038
	local ____temp_170 = options and options.resumeConversation -- 3040
	local ____temp_171 = (options and options.existingTaskId) ~= nil -- 3041
	local ____temp_172 = options and options.initialStep -- 3042
	local ____temp_173 = options and options.initialAgentStepCount -- 3043
	local ____temp_162 -- 3044
	if (options and options.existingTaskId) ~= nil then -- 3044
		____temp_162 = getInitialTokenUsage(session) -- 3044
	else -- 3044
		____temp_162 = nil -- 3044
	end -- 3044
	____runCodingAgent_176( -- 3033
		{ -- 3033
			prompt = ____normalizedPrompt_167, -- 3034
			inputId = ____temp_168, -- 3035
			inputSource = ____temp_169, -- 3036
			resumeConversation = ____temp_170, -- 3040
			resumeTask = ____temp_171, -- 3041
			initialStep = ____temp_172, -- 3042
			initialAgentStepCount = ____temp_173, -- 3043
			initialTokenUsage = ____temp_162, -- 3044
			workDir = session.projectRoot, -- 3045
			useChineseResponse = useChineseResponse, -- 3046
			taskId = taskId, -- 3047
			sessionId = session.id, -- 3048
			memoryScope = session.memoryScope, -- 3049
			role = session.kind, -- 3050
			maxSteps = options and options.maxSteps, -- 3051
			disabledAgentTools = disabledAgentTools, -- 3052
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 3053
			llmConfig = llmConfig, -- 3054
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 3055
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 3058
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 3061
			stopToken = stopToken, -- 3062
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 3063
		}, -- 3063
		function(result) -- 3064
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3064
				local ____hasReturned, ____returnValue -- 3064
				local ____try = __TS__AsyncAwaiter(function() -- 3064
					local nextSession = getSessionItem(session.id) -- 3066
					if nextSession and nextSession.kind == "sub" then -- 3066
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 3066
							local stopped = stopClearedSubSession(nextSession, taskId) -- 3069
							if not stopped.success then -- 3069
								Log( -- 3071
									"Warn", -- 3071
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 3071
								) -- 3071
								emitAgentSessionPatch( -- 3072
									session.id, -- 3072
									{session = getSessionItem(session.id)} -- 3072
								) -- 3072
							end -- 3072
							__TS__Delete(activeStopTokens, taskId) -- 3076
							____hasReturned = true -- 3077
							return -- 3077
						end -- 3077
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3079
						emitAgentSessionPatch( -- 3080
							session.id, -- 3080
							{session = getSessionItem(session.id)} -- 3080
						) -- 3080
						local finalized = __TS__Await(finalizeSubSession( -- 3083
							nextSession, -- 3084
							taskId, -- 3085
							result.success, -- 3086
							result.message, -- 3087
							result.completion, -- 3088
							(options and options.forceSubAgentHandoff) == true -- 3089
						)) -- 3089
						if not finalized.success then -- 3089
							Log( -- 3092
								"Warn", -- 3092
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 3092
							) -- 3092
						end -- 3092
						local finalizedSession = getSessionItem(session.id) -- 3094
						if finalizedSession then -- 3094
							local stopped = stopToken.stopped == true -- 3096
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 3097
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 3100
							emitAgentSessionPatch( -- 3101
								session.id, -- 3101
								{session = getSessionItem(session.id)} -- 3101
							) -- 3101
						end -- 3101
						__TS__Delete(activeStopTokens, taskId) -- 3105
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 3106
					end -- 3106
					local fallbackSession = getSessionItem(session.id) -- 3108
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 3108
						applyEvent(session.id, { -- 3114
							type = "task_finished", -- 3115
							sessionId = session.id, -- 3116
							taskId = result.taskId, -- 3117
							success = false, -- 3118
							message = result.message, -- 3119
							steps = result.steps -- 3120
						}) -- 3120
					end -- 3120
				end) -- 3120
				____try = ____try.finally( -- 3120
					____try, -- 3120
					function() -- 3120
						return __TS__AsyncAwaiter(function() -- 3120
							activePromptRuns = activePromptRuns - 1 -- 3124
							followup.settle(session.id, taskId, result.success and not result.waitingForUser and not stopToken.stopped) -- 3125
						end) -- 3125
					end -- 3125
				) -- 3125
				__TS__Await(____try) -- 3065
				if ____hasReturned then -- 3065
					return ____awaiter_resolve(nil, ____returnValue) -- 3065
				end -- 3065
			end) -- 3065
		end -- 3064
	) -- 3064
	return {success = true, sessionId = session.id, taskId = taskId} -- 3128
end -- 3128
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3282
	local lines = {} -- 3283
	do -- 3283
		local i = 0 -- 3284
		while i < #questionnaire.schema.questions do -- 3284
			local question = questionnaire.schema.questions[i + 1] -- 3285
			local answer = __TS__ArrayFind( -- 3286
				answers, -- 3286
				function(____, item) return item.questionId == question.id end -- 3286
			) -- 3286
			local answerText = "已跳过" -- 3287
			if answer and answer.status == "answered" then -- 3287
				local parts = {} -- 3289
				do -- 3289
					local j = 0 -- 3290
					while j < #(answer.selectedOptionIds or ({})) do -- 3290
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3291
						local option = __TS__ArrayFind( -- 3292
							question.options or ({}), -- 3292
							function(____, item) return item.id == optionId end -- 3292
						) -- 3292
						if option then -- 3292
							parts[#parts + 1] = option.label -- 3293
						end -- 3293
						j = j + 1 -- 3290
					end -- 3290
				end -- 3290
				if answer.otherText then -- 3290
					parts[#parts + 1] = answer.otherText -- 3295
				end -- 3295
				if answer.text then -- 3295
					parts[#parts + 1] = answer.text -- 3296
				end -- 3296
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3297
			end -- 3297
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3299
			i = i + 1 -- 3284
		end -- 3284
	end -- 3284
	return table.concat(lines, "\n\n") -- 3301
end -- 3301
function ____exports.listRunningSubAgents(request) -- 3588
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3588
		local session = getSessionItem(request.sessionId) -- 3596
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3596
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3598
		end -- 3598
		if not session then -- 3598
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3598
		end -- 3598
		local rootSession = getRootSessionItem(session.id) -- 3603
		if not rootSession then -- 3603
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3603
		end -- 3603
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3607
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3608
		local limit = math.max( -- 3609
			1, -- 3609
			math.floor(tonumber(request.limit) or 5) -- 3609
		) -- 3609
		local offset = math.max( -- 3610
			0, -- 3610
			math.floor(tonumber(request.offset) or 0) -- 3610
		) -- 3610
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3611
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3612
		local runningSessions = {} -- 3619
		do -- 3619
			local i = 0 -- 3620
			while i < #rows do -- 3620
				do -- 3620
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3621
					if current.currentTaskStatus ~= "RUNNING" then -- 3621
						goto __continue660 -- 3623
					end -- 3623
					local spawnInfo = getSessionSpawnInfo(current) -- 3625
					runningSessions[#runningSessions + 1] = { -- 3626
						sessionId = current.id, -- 3627
						title = current.title, -- 3628
						parentSessionId = current.parentSessionId, -- 3629
						rootSessionId = current.rootSessionId, -- 3630
						status = "RUNNING", -- 3631
						currentTaskId = current.currentTaskId, -- 3632
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3633
						goal = spawnInfo and spawnInfo.goal, -- 3634
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3635
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3636
						createdAt = current.createdAt, -- 3637
						updatedAt = current.updatedAt -- 3638
					} -- 3638
				end -- 3638
				::__continue660:: -- 3638
				i = i + 1 -- 3620
			end -- 3620
		end -- 3620
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3641
		local completedSessions = __TS__ArrayMap( -- 3642
			completedRecords, -- 3642
			function(____, record) return { -- 3642
				sessionId = record.sessionId, -- 3643
				title = record.title, -- 3644
				parentSessionId = record.parentSessionId, -- 3645
				rootSessionId = record.rootSessionId, -- 3646
				status = record.status, -- 3647
				goal = record.goal, -- 3648
				expectedOutput = record.expectedOutput, -- 3649
				filesHint = record.filesHint, -- 3650
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3651
				success = record.success, -- 3652
				cleared = record.cleared, -- 3653
				resultFilePath = record.resultFilePath, -- 3654
				artifactDir = record.artifactDir, -- 3655
				finishedAt = record.finishedAt, -- 3656
				createdAt = record.createdAtTs, -- 3657
				updatedAt = record.finishedAtTs -- 3658
			} end -- 3658
		) -- 3658
		local merged = {} -- 3660
		if status == "running" then -- 3660
			merged = runningSessions -- 3662
		elseif status == "done" then -- 3662
			merged = __TS__ArrayFilter( -- 3664
				completedSessions, -- 3664
				function(____, item) return item.status == "DONE" end -- 3664
			) -- 3664
		elseif status == "failed" then -- 3664
			merged = __TS__ArrayFilter( -- 3666
				completedSessions, -- 3666
				function(____, item) return item.status == "FAILED" end -- 3666
			) -- 3666
		elseif status == "stopped" then -- 3666
			merged = __TS__ArrayFilter( -- 3668
				completedSessions, -- 3668
				function(____, item) return item.status == "STOPPED" end -- 3668
			) -- 3668
		elseif status == "all" then -- 3668
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3670
		else -- 3670
			local runningKeys = {} -- 3672
			do -- 3672
				local i = 0 -- 3673
				while i < #runningSessions do -- 3673
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3674
					i = i + 1 -- 3673
				end -- 3673
			end -- 3673
			local latestCompletedByKey = {} -- 3676
			do -- 3676
				local i = 0 -- 3677
				while i < #completedSessions do -- 3677
					do -- 3677
						local item = completedSessions[i + 1] -- 3678
						local key = getSubAgentDisplayKey(item) -- 3679
						if runningKeys[key] then -- 3679
							goto __continue675 -- 3681
						end -- 3681
						local current = latestCompletedByKey[key] -- 3683
						if current == nil or item.updatedAt > current.updatedAt then -- 3683
							latestCompletedByKey[key] = item -- 3685
						end -- 3685
					end -- 3685
					::__continue675:: -- 3685
					i = i + 1 -- 3677
				end -- 3677
			end -- 3677
			local latestCompleted = {} -- 3688
			for ____, item in pairs(latestCompletedByKey) do -- 3689
				latestCompleted[#latestCompleted + 1] = item -- 3690
			end -- 3690
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3692
		end -- 3692
		if query ~= "" then -- 3692
			merged = __TS__ArrayFilter( -- 3695
				merged, -- 3695
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3695
			) -- 3695
		end -- 3695
		__TS__ArraySort( -- 3701
			merged, -- 3701
			function(____, a, b) -- 3701
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3701
					return -1 -- 3702
				end -- 3702
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3702
					return 1 -- 3703
				end -- 3703
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3703
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3705
				end -- 3705
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3707
			end -- 3701
		) -- 3701
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3709
		return ____awaiter_resolve(nil, { -- 3709
			success = true, -- 3711
			rootSessionId = rootSession.id, -- 3712
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3713
			status = status, -- 3714
			limit = limit, -- 3715
			offset = offset, -- 3716
			hasMore = offset + limit < #merged, -- 3717
			sessions = paged -- 3718
		}) -- 3718
	end) -- 3718
end -- 3588
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
	if not session or followup.activeRuns[sessionId] ~= nil or session.currentTaskFinalizing or getPendingQuestionnaire(sessionId) or isProjectTaskAdmissionClosed(session.projectRoot) or session.currentTaskStatus == "RUNNING" then -- 390
		return nil -- 392
	end -- 392
	local input = InputInbox.listInputs(sessionId)[1] -- 393
	if input == nil then -- 393
		__TS__Delete(followup.bindings, sessionId) -- 394
		return nil -- 394
	end -- 394
	if input.held or input.status ~= "pending" then -- 394
		return nil -- 395
	end -- 395
	local binding = followup.bindings[sessionId] -- 396
	if binding == nil then -- 396
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
			return true, { -- 490
				success = false, -- 490
				message = tostring(____error) -- 490
			} -- 490
		end -- 490
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 490
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
			local pending = InputInbox.listInputs(sessionId) -- 467
			if followup.activeRuns[sessionId] == nil and session.currentTaskStatus ~= "RUNNING" and not session.currentTaskFinalizing and #pending == 0 then -- 467
				return true, binding.localAgentConfigId ~= nil and startLocalPrompt(sessionId, content, binding.localAgentConfigId) or startImmediatePrompt( -- 472
					sessionId, -- 474
					content, -- 474
					options.disabledAgentTools, -- 474
					options.workMode, -- 474
					options.llmConfigId, -- 475
					binding.llmConfig, -- 475
					options.maxSteps -- 475
				) -- 475
			end -- 475
			local requestId = submission and submission.requestId or (((("input-" .. tostring(sessionId)) .. "-") .. tostring(os.time())) .. "-") .. tostring(math.random(1, 1000000000)) -- 477
			local ____temp_21 = followup.activeRuns[sessionId] ~= nil -- 478
			if ____temp_21 then -- 478
				local ____opt_19 = activeStopTokens[session.currentTaskId or -1] -- 478
				____temp_21 = not (____opt_19 and ____opt_19.stopped) -- 478
			end -- 478
			local isActive = ____temp_21 -- 478
			local delivery = content ~= "/clear" and content ~= "/compact" and isActive and not binding.localAgentConfigId and (submission and submission.delivery) == "steer" and "steer" or "queue" -- 479
			local wasPaused = __TS__ArraySome( -- 480
				pending, -- 480
				function(____, item) return item.held end -- 480
			) -- 480
			local ____InputInbox_admitInput_27 = InputInbox.admitInput -- 481
			local ____sessionId_25 = sessionId -- 481
			local ____options_26 = options -- 481
			local ____temp_24 -- 481
			if delivery == "steer" then -- 481
				____temp_24 = session.currentTaskId -- 481
			else -- 481
				____temp_24 = nil -- 481
			end -- 481
			local input = ____InputInbox_admitInput_27( -- 481
				____sessionId_25, -- 481
				content, -- 481
				delivery, -- 481
				requestId, -- 481
				____options_26, -- 481
				____temp_24 -- 481
			) -- 481
			if wasPaused and delivery == "queue" then -- 481
				InputInbox.holdInputs(sessionId) -- 482
			end -- 482
			if input.status == "delivered" or input.status == "cancelled" then -- 482
				return true, {success = true, sessionId = sessionId, taskId = input.taskId or session.currentTaskId or 0} -- 483
			end -- 483
			if binding.llmConfig then -- 483
				followup.configs[input.id] = binding.llmConfig -- 484
			end -- 484
			local next = followup.dispatch(sessionId) -- 485
			if not next then -- 485
				followup.publish(sessionId) -- 488
			end -- 488
			return true, next or ({success = true, sessionId = sessionId, taskId = session.currentTaskId or 0}) -- 489
		end) -- 489
		if not ____try then -- 489
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 489
		end -- 489
		if ____hasReturned then -- 489
			return ____returnValue -- 442
		end -- 442
	end -- 442
end -- 434
activeLocalAgentControls = {} -- 492
finalizingSubSessionTaskIds = {} -- 493
activePromptRuns = 0 -- 494
streamUpdates = __TS__New( -- 496
	StreamUpdates, -- 496
	function(sessionId, taskId, step, value) -- 496
		local ____opt_28 = getSessionItem(sessionId) -- 496
		if (____opt_28 and ____opt_28.currentTaskId) ~= taskId then -- 496
			return -- 497
		end -- 497
		upsertStep( -- 498
			sessionId, -- 498
			taskId, -- 498
			step, -- 498
			"message", -- 498
			{status = "RUNNING", reason = value.content, reasoningContent = value.reasoningContent} -- 498
		) -- 498
		emitAgentSessionPatch( -- 501
			sessionId, -- 501
			{step = getStepItem(sessionId, taskId, step)} -- 501
		) -- 501
	end -- 496
) -- 496
streamFlushScheduled = false -- 503
--- Runtime ownership, including asynchronous completion after task status changes.
function ____exports.isRuntimeIdle() -- 516
	return followup.pendingWakes == 0 and activePromptRuns == 0 and #__TS__ObjectKeys(activeStopTokens) == 0 and #__TS__ObjectKeys(activeLocalAgentControls) == 0 and #__TS__ObjectKeys(finalizingSubSessionTaskIds) == 0 -- 517
end -- 516
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 522
now = function() return os.time() end -- 523
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1195
	if projectRoot == oldRoot then -- 1195
		return newRoot -- 1197
	end -- 1197
	for ____, separator in ipairs({"/", "\\"}) do -- 1199
		local prefix = oldRoot .. separator -- 1200
		if __TS__StringStartsWith(projectRoot, prefix) then -- 1200
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1202
		end -- 1202
	end -- 1202
	return nil -- 1205
end -- 1195
local function clearSessionAfterMessage(sessionId, message) -- 1744
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1745
	local removedStepIds = {} -- 1753
	do -- 1753
		local i = 0 -- 1754
		while i < #removedStepRows do -- 1754
			local row = removedStepRows[i + 1] -- 1755
			if type(row[1]) == "number" then -- 1755
				removedStepIds[#removedStepIds + 1] = row[1] -- 1757
			end -- 1757
			i = i + 1 -- 1754
		end -- 1754
	end -- 1754
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1760
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1768
	return removedStepIds -- 1773
end -- 1744
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1776
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1777
	local persisted = storage:readSessionState() -- 1778
	local userIndex = -1 -- 1779
	do -- 1779
		local i = #persisted.messages - 1 -- 1780
		while i >= 0 do -- 1780
			if persisted.messages[i + 1].role == "user" and persisted.messages[i + 1].inputKind ~= "steer" then -- 1780
				userIndex = i -- 1782
				break -- 1783
			end -- 1783
			i = i - 1 -- 1780
		end -- 1780
	end -- 1780
	if userIndex < 0 then -- 1780
		return -- 1786
	end -- 1786
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1787
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1788
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1789
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1794
end -- 1776
local function listCurrentTaskCheckpoints(sessionId) -- 1806
	local session = getSessionItem(sessionId) -- 1807
	local taskId = session and session.currentTaskId -- 1808
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1809
end -- 1806
local function getAgentStepCount(sessionId, taskId) -- 1916
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1917
		sessionId, -- 1922
		taskId, -- 1923
		"compress_memory", -- 1924
		"merge_memory", -- 1925
		"sub_agent_handoff", -- 1926
		"questionnaire_answer", -- 1927
		"message" -- 1928
	}) -- 1928
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1931
end -- 1916
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1934
	if status == nil then -- 1934
		status = "DONE" -- 1942
	end -- 1942
	local step = getNextStepNumber(sessionId, taskId) -- 1944
	upsertStep( -- 1945
		sessionId, -- 1945
		taskId, -- 1945
		step, -- 1945
		tool, -- 1945
		{status = status, reason = reason, params = params, result = result} -- 1945
	) -- 1945
	return getStepItem(sessionId, taskId, step) -- 1951
end -- 1934
local function sanitizeStoredSteps(sessionId) -- 2018
	DB:exec( -- 2019
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 2019
		{ -- 2037
			now(), -- 2037
			sessionId -- 2037
		} -- 2037
	) -- 2037
end -- 2018
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2498
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2498
		return {success = false, message = "invalid projectRoot"} -- 2500
	end -- 2500
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2502
	for ____, row in ipairs(rows) do -- 2503
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2504
		if sessionId > 0 then -- 2504
			deleteSessionRecords(sessionId) -- 2506
		end -- 2506
	end -- 2506
	return {success = true, deleted = #rows} -- 2509
end -- 2498
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2512
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2512
		return {success = false, message = "invalid projectRoot"} -- 2514
	end -- 2514
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2516
	local renamed = 0 -- 2517
	for ____, row in ipairs(rows) do -- 2518
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2519
		local projectRoot = toStr(row[2]) -- 2520
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2521
		if sessionId > 0 and nextProjectRoot then -- 2521
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2523
			DB:exec( -- 2524
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2524
				{ -- 2526
					nextProjectRoot, -- 2526
					Path:getFilename(nextProjectRoot), -- 2526
					now(), -- 2526
					sessionId -- 2526
				} -- 2526
			) -- 2526
			renamed = renamed + 1 -- 2528
		end -- 2528
	end -- 2528
	return {success = true, renamed = renamed} -- 2531
end -- 2512
function ____exports.getSession(sessionId, view) -- 2534
	local session = getSessionItem(sessionId) -- 2535
	if not session then -- 2535
		return {success = false, message = "session not found"} -- 2537
	end -- 2537
	if followup.activeRuns[sessionId] == nil then -- 2537
		followup.recover(session) -- 2539
	end -- 2539
	local restored = restorePendingQuestionnaireState(session) -- 2540
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2541
	local ____opt_96 = getSessionItem(sessionId) -- 2541
	normalizedSession.pendingInputs = ____opt_96 and ____opt_96.pendingInputs -- 2542
	local relatedSessions = listRelatedSessions(sessionId) -- 2543
	sanitizeStoredSteps(sessionId) -- 2544
	local firstMessageId = 0 -- 2545
	local hasEarlierMessages = false -- 2546
	if view then -- 2546
		local limit = math.max( -- 2548
			1, -- 2548
			math.min( -- 2548
				1000, -- 2548
				math.floor(view.recentRounds) -- 2548
			) -- 2548
		) -- 2548
		local requests = queryRows(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m WHERE m.session_id = ? AND m.role = 'user'\n    AND NOT EXISTS (SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n\t\t\tORDER BY m.id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2549
		if #requests > limit then -- 2549
			firstMessageId = requests[limit][1] -- 2555
			hasEarlierMessages = true -- 2556
		end -- 2556
	end -- 2556
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2559
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2566
	local ____relatedSessions_103 = relatedSessions -- 2578
	local ____temp_102 -- 2579
	if normalizedSession.kind == "sub" then -- 2579
		____temp_102 = getSessionSpawnInfo(normalizedSession) -- 2579
	else -- 2579
		____temp_102 = nil -- 2579
	end -- 2579
	return { -- 2575
		success = true, -- 2576
		session = normalizedSession, -- 2577
		relatedSessions = ____relatedSessions_103, -- 2578
		spawnInfo = ____temp_102, -- 2579
		messages = __TS__ArrayMap( -- 2580
			messages, -- 2580
			function(____, row) return rowToMessage(row) end -- 2580
		), -- 2580
		hasEarlierMessages = hasEarlierMessages, -- 2581
		steps = __TS__ArrayMap( -- 2582
			steps, -- 2582
			function(____, row) return rowToStep(row) end -- 2582
		), -- 2582
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2583
		pendingQuestionnaire = restored.questionnaire, -- 2584
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2585
	} -- 2585
end -- 2534
function ____exports.setWorkMode(sessionId, workMode) -- 2590
	local session = getSessionItem(sessionId) -- 2591
	if not session then -- 2591
		return {success = false, message = "session not found"} -- 2592
	end -- 2592
	if session.kind ~= "main" then -- 2592
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2593
	end -- 2593
	if workMode ~= "code" and workMode ~= "plan" then -- 2593
		return {success = false, message = "invalid work mode"} -- 2594
	end -- 2594
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2595
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2595
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2597
	end -- 2597
	if getPendingQuestionnaire(sessionId) then -- 2597
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2600
	end -- 2600
	if normalizedSession.workMode ~= workMode then -- 2600
		DB:exec( -- 2603
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2603
			{ -- 2603
				workMode, -- 2603
				now(), -- 2603
				sessionId -- 2603
			} -- 2603
		) -- 2603
	end -- 2603
	local updated = getSessionItem(sessionId) -- 2605
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2606
	return { -- 2607
		success = true, -- 2607
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2607
	} -- 2607
end -- 2590
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId, llmConfig) -- 2906
	local session = getSessionItem(sessionId) -- 2907
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2907
		return {success = false, message = "project task admission is closed"} -- 2908
	end -- 2908
	if not session then -- 2908
		return {success = false, message = "session not found"} -- 2910
	end -- 2910
	if getPendingQuestionnaire(sessionId) then -- 2910
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2912
	end -- 2912
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2912
		return {success = false, message = "session task is finalizing"} -- 2914
	end -- 2914
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2914
		return {success = false, message = "session task is still stopping"} -- 2917
	end -- 2917
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2917
		return {success = false, message = "session task is not continuable"} -- 2920
	end -- 2920
	if session.currentTaskId == nil then -- 2920
		return {success = false, message = "session task not found"} -- 2923
	end -- 2923
	local resolved = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 2925
	if not resolved.success then -- 2925
		return {success = false, message = resolved.message} -- 2926
	end -- 2926
	followup.recover(session) -- 2927
	local previousBinding = followup.bindings[sessionId] -- 2928
	followup.bindings[sessionId] = {llmConfig = resolved.config, llmConfigId = llmConfigId} -- 2929
	local taskId = session.currentTaskId -- 2930
	local result = startPromptTask( -- 2931
		session, -- 2932
		"", -- 2933
		nil, -- 2934
		normalizeDisabledAgentTools(disabledAgentTools), -- 2935
		{ -- 2936
			workMode = session.workMode, -- 2937
			persistUserMessage = false, -- 2938
			resumeConversation = true, -- 2939
			existingTaskId = taskId, -- 2940
			initialStep = math.max( -- 2941
				0, -- 2941
				getNextStepNumber(session.id, taskId) - 1 -- 2941
			), -- 2941
			initialAgentStepCount = 0, -- 2945
			llmConfigId = llmConfigId, -- 2946
			llmConfig = resolved.config -- 2947
		} -- 2947
	) -- 2947
	if result.success then -- 2947
		for ____, input in ipairs(InputInbox.listInputs(sessionId)) do -- 2953
			followup.configs[input.id] = resolved.config -- 2953
		end -- 2953
		InputInbox.mutateInput(sessionId, {action = "resume"}, "") -- 2954
		followup.publish(sessionId) -- 2955
	elseif previousBinding ~= nil then -- 2955
		followup.bindings[sessionId] = previousBinding -- 2956
	else -- 2956
		__TS__Delete(followup.bindings, sessionId) -- 2957
	end -- 2957
	return result -- 2958
end -- 2906
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 3131
	local session = getSessionItem(sessionId) -- 3132
	if not session then -- 3132
		return {success = false, message = "session not found"} -- 3134
	end -- 3134
	if session.kind ~= "sub" then -- 3134
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 3137
	end -- 3137
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3137
		return {success = false, message = "session task is finalizing"} -- 3140
	end -- 3140
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3142
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 3142
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 3147
	end -- 3147
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 3147
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 3150
	end -- 3150
	local disabledAgentTools = AgentToolRegistry.getAllowedToolsForRole("sub") -- 3152
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并给出最终总结。不要再调用任何工具；用纯文本如实总结已完成内容、文件变更、验证状态和剩余问题。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Use plain text only, without tools, to summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 3153
	return startPromptTask( -- 3156
		session, -- 3156
		prompt, -- 3156
		nil, -- 3156
		disabledAgentTools, -- 3156
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 3156
	) -- 3156
end -- 3131
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 3163
	local session = getSessionItem(sessionId) -- 3164
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3164
		return {success = false, message = "project task admission is closed"} -- 3165
	end -- 3165
	if not session then -- 3165
		return {success = false, message = "session not found"} -- 3167
	end -- 3167
	if #InputInbox.listInputs(sessionId) > 0 then -- 3167
		return {success = false, message = "finish or remove pending messages before editing task history"} -- 3169
	end -- 3169
	if getPendingQuestionnaire(sessionId) then -- 3169
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 3170
	end -- 3170
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3170
		return {success = false, message = "session task is finalizing"} -- 3172
	end -- 3172
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 3172
		return {success = false, message = "session task is still running"} -- 3175
	end -- 3175
	local message = getMessageItem(messageId) -- 3177
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 3177
		return {success = false, message = "message not found"} -- 3179
	end -- 3179
	local latestUserRow = queryOne(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m\n  WHERE m.session_id = ? AND m.role = ? AND NOT EXISTS (\n   SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n  ORDER BY m.id DESC LIMIT 1", {sessionId, "user"}) -- 3181
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 3188
	if latestUserMessageId ~= messageId then -- 3188
		return {success = false, message = "only the latest user prompt can be edited"} -- 3190
	end -- 3190
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 3192
	if normalizedPrompt == "" then -- 3192
		return {success = false, message = "prompt is empty"} -- 3194
	end -- 3194
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 3196
	if session.workMode ~= nextWorkMode then -- 3196
		DB:exec( -- 3198
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 3198
			{ -- 3198
				nextWorkMode, -- 3198
				now(), -- 3198
				session.id -- 3198
			} -- 3198
		) -- 3198
		session.workMode = nextWorkMode -- 3199
	end -- 3199
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 3201
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 3202
	local result = startPromptTask( -- 3203
		session, -- 3203
		normalizedPrompt, -- 3203
		messageId, -- 3203
		normalizeDisabledAgentTools(disabledAgentTools), -- 3203
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 3203
	) -- 3203
	if result.success and #removedStepIds > 0 then -- 3203
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 3205
	end -- 3205
	return result -- 3207
end -- 3163
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 3212
	if status == "dismissed" then -- 3212
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 3218
	end -- 3218
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3220
end -- 3212
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3223
	if status == "dismissed" then -- 3223
		return { -- 3229
			success = true, -- 3230
			status = "dismissed", -- 3231
			source = "user", -- 3232
			questionnaireId = questionnaire.id, -- 3233
			title = questionnaire.schema.title, -- 3234
			answers = {}, -- 3235
			responses = {}, -- 3236
			displayText = "用户关闭了调查问卷，未作答。", -- 3237
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 3238
		} -- 3238
	end -- 3238
	local responses = {} -- 3241
	do -- 3241
		local i = 0 -- 3242
		while i < #questionnaire.schema.questions do -- 3242
			do -- 3242
				local question = questionnaire.schema.questions[i + 1] -- 3243
				local answer = __TS__ArrayFind( -- 3244
					answers, -- 3244
					function(____, item) return item.questionId == question.id end -- 3244
				) -- 3244
				if not answer or answer.status == "skipped" then -- 3244
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3246
					goto __continue572 -- 3251
				end -- 3251
				local selectedOptionLabels = {} -- 3253
				do -- 3253
					local j = 0 -- 3254
					while j < #(answer.selectedOptionIds or ({})) do -- 3254
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3255
						local option = __TS__ArrayFind( -- 3256
							question.options or ({}), -- 3256
							function(____, item) return item.id == optionId end -- 3256
						) -- 3256
						if option then -- 3256
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3257
						end -- 3257
						j = j + 1 -- 3254
					end -- 3254
				end -- 3254
				responses[#responses + 1] = { -- 3259
					questionId = question.id, -- 3260
					prompt = question.prompt, -- 3261
					status = "answered", -- 3262
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3263
					selectedOptionLabels = selectedOptionLabels, -- 3264
					otherText = answer.otherText, -- 3265
					text = answer.text -- 3266
				} -- 3266
			end -- 3266
			::__continue572:: -- 3266
			i = i + 1 -- 3242
		end -- 3242
	end -- 3242
	return { -- 3269
		success = true, -- 3270
		status = "answered", -- 3271
		source = "user", -- 3272
		questionnaireId = questionnaire.id, -- 3273
		title = questionnaire.schema.title, -- 3274
		answers = answers, -- 3275
		responses = responses, -- 3276
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3277
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3278
	} -- 3278
end -- 3223
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3304
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3310
	local persisted = storage:readSessionState() -- 3311
	local messages = __TS__ArraySlice(persisted.messages) -- 3312
	local toolResultIndex = -1 -- 3313
	local existingResult -- 3314
	do -- 3314
		local i = #messages - 1 -- 3315
		while i >= 0 do -- 3315
			do -- 3315
				local message = messages[i + 1] -- 3316
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3316
					goto __continue592 -- 3317
				end -- 3317
				local decoded = safeJsonDecode(message.content) -- 3318
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3318
					goto __continue592 -- 3319
				end -- 3319
				local row = decoded -- 3320
				if row.questionnaireId ~= questionnaire.id then -- 3320
					goto __continue592 -- 3321
				end -- 3321
				toolResultIndex = i -- 3322
				existingResult = row -- 3323
				break -- 3324
			end -- 3324
			::__continue592:: -- 3324
			i = i - 1 -- 3315
		end -- 3315
	end -- 3315
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3326
	local guidance = {} -- 3327
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3327
		guidance[#guidance + 1] = existingResult.guidance -- 3329
	end -- 3329
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3329
		guidance[#guidance + 1] = result.guidance -- 3332
	end -- 3332
	result.guidance = table.concat(guidance, "\n") -- 3334
	if toolResultIndex < 0 then -- 3334
		messages[#messages + 1] = { -- 3336
			role = "user", -- 3337
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3338
		} -- 3338
		toolResultIndex = #messages - 1 -- 3340
	else -- 3340
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3342
			{}, -- 3342
			messages[toolResultIndex + 1], -- 3343
			{content = encodeJson(result)} -- 3342
		) -- 3342
	end -- 3342
	local pairStartIndex = toolResultIndex -- 3348
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3349
	if toolCallId and toolCallId ~= "" then -- 3349
		do -- 3349
			local i = toolResultIndex - 1 -- 3351
			while i >= 0 do -- 3351
				do -- 3351
					local message = messages[i + 1] -- 3352
					if message.role ~= "assistant" or not message.tool_calls then -- 3352
						goto __continue602 -- 3353
					end -- 3353
					if __TS__ArraySome( -- 3353
						message.tool_calls, -- 3354
						function(____, call) return call.id == toolCallId end -- 3354
					) then -- 3354
						pairStartIndex = i -- 3355
						break -- 3356
					end -- 3356
				end -- 3356
				::__continue602:: -- 3356
				i = i - 1 -- 3351
			end -- 3351
		end -- 3351
	end -- 3351
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3360
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3363
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3367
	upsertStep( -- 3369
		session.id, -- 3369
		questionnaire.taskId, -- 3369
		questionnaire.step, -- 3369
		"ask_user", -- 3369
		{status = "DONE", result = result} -- 3369
	) -- 3369
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3373
	upsertStep( -- 3374
		session.id, -- 3374
		questionnaire.taskId, -- 3374
		answerStep, -- 3374
		"questionnaire_answer", -- 3374
		{status = "DONE", result = result} -- 3374
	) -- 3374
	return {success = true, answerStep = answerStep, result = result} -- 3378
end -- 3304
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3381
	local session = getSessionItem(sessionId) -- 3382
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3382
		return {success = false, message = "project task admission is closed"} -- 3383
	end -- 3383
	if not session then -- 3383
		return {success = false, message = "session not found"} -- 3384
	end -- 3384
	if session.kind ~= "main" then -- 3384
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3385
	end -- 3385
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3386
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3386
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3388
	end -- 3388
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3390
	if not llmConfigRes.success then -- 3390
		return {success = false, message = llmConfigRes.message} -- 3391
	end -- 3391
	if not removePendingQuestionnaire(session) then -- 3391
		return {success = false, message = "failed to consume questionnaire file"} -- 3392
	end -- 3392
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3393
	if not replaced.success then -- 3393
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3395
		return replaced -- 3396
	end -- 3396
	local t = now() -- 3398
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3399
	session.workMode = "plan" -- 3400
	local result = startPromptTask( -- 3401
		session, -- 3401
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3401
		nil, -- 3401
		{}, -- 3401
		{ -- 3401
			workMode = "plan", -- 3402
			persistUserMessage = false, -- 3403
			resumeConversation = true, -- 3404
			existingTaskId = questionnaire.taskId, -- 3405
			initialStep = replaced.answerStep, -- 3406
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3407
			llmConfig = llmConfigRes.config -- 3408
		} -- 3408
	) -- 3408
	if not result.success then -- 3408
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3411
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3412
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3413
		emitAgentSessionPatch( -- 3414
			session.id, -- 3414
			{ -- 3414
				session = getSessionItem(session.id), -- 3415
				pendingQuestionnaire = questionnaire -- 3416
			} -- 3416
		) -- 3416
		return result -- 3418
	end -- 3418
	emitAgentSessionPatch( -- 3420
		sessionId, -- 3420
		{ -- 3420
			session = getSessionItem(sessionId), -- 3421
			pendingQuestionnaire = false -- 3422
		} -- 3422
	) -- 3422
	return result -- 3424
end -- 3381
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3427
	local session = getSessionItem(sessionId) -- 3428
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3428
		return {success = false, message = "project task admission is closed"} -- 3429
	end -- 3429
	if not session then -- 3429
		return {success = false, message = "session not found"} -- 3430
	end -- 3430
	if session.kind ~= "main" then -- 3430
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3431
	end -- 3431
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3432
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3432
		return {success = false, message = "pending questionnaire not found"} -- 3433
	end -- 3433
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3434
	if not validated.success then -- 3434
		return validated -- 3435
	end -- 3435
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3436
	if not llmConfigRes.success then -- 3436
		return {success = false, message = llmConfigRes.message} -- 3437
	end -- 3437
	local t = now() -- 3438
	if not removePendingQuestionnaire(session) then -- 3438
		return {success = false, message = "failed to consume questionnaire file"} -- 3439
	end -- 3439
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3440
	if not replaced.success then -- 3440
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3442
		return replaced -- 3443
	end -- 3443
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3445
	session.workMode = "plan" -- 3446
	local result = startPromptTask( -- 3447
		session, -- 3447
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3447
		nil, -- 3447
		{}, -- 3447
		{ -- 3447
			workMode = "plan", -- 3448
			persistUserMessage = false, -- 3449
			resumeConversation = true, -- 3450
			existingTaskId = questionnaire.taskId, -- 3451
			initialStep = replaced.answerStep, -- 3452
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3453
			llmConfig = llmConfigRes.config -- 3454
		} -- 3454
	) -- 3454
	if not result.success then -- 3454
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3457
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3458
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3459
		emitAgentSessionPatch( -- 3460
			session.id, -- 3460
			{ -- 3460
				session = getSessionItem(session.id), -- 3461
				pendingQuestionnaire = questionnaire -- 3462
			} -- 3462
		) -- 3462
		return result -- 3464
	end -- 3464
	emitAgentSessionPatch( -- 3466
		sessionId, -- 3466
		{ -- 3466
			session = getSessionItem(sessionId), -- 3467
			pendingQuestionnaire = false -- 3468
		} -- 3468
	) -- 3468
	return result -- 3470
end -- 3427
function ____exports.stopSessionTask(sessionId) -- 3473
	InputInbox.holdInputs(sessionId) -- 3474
	followup.publish(sessionId) -- 3475
	local session = getSessionItem(sessionId) -- 3476
	if not session or session.currentTaskId == nil then -- 3476
		return {success = false, message = "session task not found"} -- 3478
	end -- 3478
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3478
		return {success = false, message = "session task is finalizing"} -- 3481
	end -- 3481
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime) -- 3483
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3484
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3485
	if localControl ~= nil then -- 3485
		localControl:stop() -- 3487
		return {success = true, stopping = true} -- 3488
	end -- 3488
	local stopToken = activeStopTokens[session.currentTaskId] -- 3490
	if stopToken == nil then -- 3490
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3490
			return {success = true, recovered = true} -- 3493
		end -- 3493
		return {success = false, message = "task is not running"} -- 3495
	end -- 3495
	if stopToken.stopped then -- 3495
		return {success = true, stopping = true} -- 3498
	end -- 3498
	stopToken.stopped = true -- 3500
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3501
	return {success = true, stopping = true} -- 3505
end -- 3473
function ____exports.getCurrentTaskId(sessionId) -- 3508
	local ____opt_179 = getSessionItem(sessionId) -- 3508
	return ____opt_179 and ____opt_179.currentTaskId -- 3509
end -- 3508
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3513
	local owner = getSessionItem(sessionId) -- 3514
	if not owner then -- 3514
		return {success = false, message = "session not found"} -- 3515
	end -- 3515
	local projectRoot = owner.projectRoot -- 3516
	local release = holdProjectTaskAdmission(projectRoot) -- 3517
	local closed = false -- 3518
	return { -- 3519
		success = true, -- 3520
		projectRoot = projectRoot, -- 3521
		close = function() -- 3522
			if not closed then -- 3522
				closed = true -- 3522
				release() -- 3522
			end -- 3522
		end, -- 3522
		poll = function() -- 3523
			if closed then -- 3523
				return {success = false, message = "quiescence handle closed"} -- 3524
			end -- 3524
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3525
			if not rows then -- 3525
				return {success = false, message = "failed to inspect project tasks"} -- 3526
			end -- 3526
			local pending = {} -- 3527
			for ____, row in ipairs(rows) do -- 3528
				do -- 3528
					local session = rowToSession(row) -- 3529
					local taskId = session.currentTaskId -- 3530
					if taskId == nil then -- 3530
						goto __continue640 -- 3531
					end -- 3531
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3532
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3532
						goto __continue640 -- 3533
					end -- 3533
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3535
					local ____session_id_182 = session.id -- 3536
					local ____taskId_183 = taskId -- 3536
					local ____finalizing_184 = finalizing -- 3536
					local ____result_success_185 = result.success -- 3536
					local ____result_success_181 -- 3536
					if result.success then -- 3536
						____result_success_181 = nil -- 3536
					else -- 3536
						____result_success_181 = result.message -- 3536
					end -- 3536
					pending[#pending + 1] = { -- 3536
						sessionId = ____session_id_182, -- 3536
						taskId = ____taskId_183, -- 3536
						finalizing = ____finalizing_184, -- 3536
						stopRequested = ____result_success_185, -- 3536
						message = ____result_success_181 -- 3536
					} -- 3536
				end -- 3536
				::__continue640:: -- 3536
			end -- 3536
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3540
		end -- 3523
	} -- 3523
end -- 3513
function ____exports.validateTaskAccess(sessionId, taskId) -- 3545
	local session = getSessionItem(sessionId) -- 3546
	if not session then -- 3546
		return {success = false, message = "session not found"} -- 3547
	end -- 3547
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3547
		getSessionOperableTaskIds(sessionId), -- 3548
		taskId -- 3548
	) < 0 then -- 3548
		return {success = false, message = "task is not operable for this session"} -- 3549
	end -- 3549
	return {success = true, session = session} -- 3551
end -- 3545
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3554
	if checkpointId <= 0 then -- 3554
		return {success = false, message = "invalid checkpointId"} -- 3556
	end -- 3556
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3558
	if not checkpoint then -- 3558
		return {success = false, message = "checkpoint not found"} -- 3560
	end -- 3560
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3562
	if not taskAccess.success then -- 3562
		return taskAccess -- 3563
	end -- 3563
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3564
end -- 3554
function ____exports.listRunningSessions() -- 3567
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3568
	local sessions = {} -- 3575
	do -- 3575
		local i = 0 -- 3576
		while i < #rows do -- 3576
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3577
			if session.currentTaskStatus == "RUNNING" then -- 3577
				sessions[#sessions + 1] = session -- 3579
			end -- 3579
			i = i + 1 -- 3576
		end -- 3576
	end -- 3576
	return {success = true, sessions = sessions} -- 3582
end -- 3567
return ____exports -- 3567