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
local scheduleStreamFlush, getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getPendingSessionInputs, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startImmediatePrompt, startLocalPrompt, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, followup, activeLocalAgentControls, finalizingSubSessionTaskIds, activePromptRuns, streamUpdates, streamFlushScheduled, SESSION_SELECT_COLUMNS, now -- 1
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
		metrics = decodeJsonObject(toStr(row[13])), -- 803
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
function mergeAgentMetrics(current, next) -- 1613
	return __TS__ObjectAssign({}, current or ({}), next) -- 1614
end -- 1614
function updateSessionMetrics(sessionId, metrics) -- 1620
	local session = getSessionItem(sessionId) -- 1621
	if not session then -- 1621
		return nil -- 1622
	end -- 1622
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1623
	DB:exec( -- 1624
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1624
		{ -- 1628
			encodeJson(merged), -- 1629
			now(), -- 1630
			sessionId -- 1631
		} -- 1631
	) -- 1631
	return merged -- 1634
end -- 1634
function clearSessionTokenUsage(sessionId) -- 1637
	local session = getSessionItem(sessionId) -- 1638
	if not session then -- 1638
		return nil -- 1639
	end -- 1639
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1640
	__TS__Delete(metrics, "usage") -- 1641
	__TS__Delete(metrics, "visionUsage") -- 1642
	DB:exec( -- 1643
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1643
		{ -- 1647
			encodeJson(metrics), -- 1648
			now(), -- 1649
			sessionId -- 1650
		} -- 1650
	) -- 1650
	return metrics -- 1653
end -- 1653
function getInitialTokenUsage(session) -- 1656
	local ____opt_65 = session.metrics -- 1656
	local usage = ____opt_65 and ____opt_65.usage -- 1657
	if not usage or (usage.requestCount or 0) <= 0 then -- 1657
		return nil -- 1658
	end -- 1658
	return { -- 1659
		inputTokens = usage.inputTokens or 0, -- 1660
		outputTokens = usage.outputTokens or 0, -- 1661
		totalTokens = usage.totalTokens, -- 1662
		cachedInputTokens = usage.cachedInputTokens, -- 1663
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1664
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1665
		requestCount = usage.requestCount or 0, -- 1666
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1667
		model = usage.model or "", -- 1668
		phase = usage.phase or "", -- 1669
		step = usage.step or 0, -- 1670
		updatedAt = usage.updatedAt or now() -- 1671
	} -- 1671
end -- 1671
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1675
	if taskId == nil or taskId <= 0 then -- 1675
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1677
		return -- 1678
	end -- 1678
	local row = getSessionRow(sessionId) -- 1680
	if not row then -- 1680
		return -- 1681
	end -- 1681
	local session = rowToSession(row) -- 1682
	if session.currentTaskId ~= taskId then -- 1682
		Log( -- 1684
			"Info", -- 1684
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1684
		) -- 1684
		return -- 1685
	end -- 1685
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1687
end -- 1687
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1690
	local t = now() -- 1691
	DB:exec( -- 1692
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1692
		{ -- 1695
			sessionId, -- 1696
			taskId or 0, -- 1697
			role, -- 1698
			sanitizeUTF8(content), -- 1699
			displayContent and sanitizeUTF8(displayContent) or "", -- 1700
			t, -- 1701
			t -- 1702
		} -- 1702
	) -- 1702
	return getLastInsertRowId() -- 1705
end -- 1705
function updateMessage(messageId, content) -- 1708
	DB:exec( -- 1709
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1709
		{ -- 1711
			sanitizeUTF8(content), -- 1711
			now(), -- 1711
			messageId -- 1711
		} -- 1711
	) -- 1711
end -- 1711
function updateUserMessageForTask(messageId, content, taskId) -- 1715
	DB:exec( -- 1716
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1716
		{ -- 1720
			sanitizeUTF8(content), -- 1720
			taskId, -- 1720
			now(), -- 1720
			messageId -- 1720
		} -- 1720
	) -- 1720
end -- 1720
function removeContinuableTaskSummary(session) -- 1777
	local taskId = session.currentTaskId -- 1778
	if taskId == nil then -- 1778
		return -- 1779
	end -- 1779
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1780
end -- 1780
function upsertAssistantMessage(sessionId, taskId, content) -- 1792
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1793
	if row and type(row[1]) == "number" then -- 1793
		updateMessage(row[1], content) -- 1800
		return row[1] -- 1801
	end -- 1801
	return insertMessage(sessionId, "assistant", content, taskId) -- 1803
end -- 1803
function upsertStep(sessionId, taskId, step, tool, patch) -- 1806
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1816
	local reason = sanitizeUTF8(patch.reason or "") -- 1820
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1821
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1822
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1823
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1824
	local statusPatch = patch.status or "" -- 1825
	local status = patch.status or "PENDING" -- 1826
	if not row then -- 1826
		local t = now() -- 1828
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1829
			sessionId, -- 1833
			taskId, -- 1834
			step, -- 1835
			tool, -- 1836
			status, -- 1837
			reason, -- 1838
			reasoningContent, -- 1839
			paramsJson, -- 1840
			resultJson, -- 1841
			patch.checkpointId or 0, -- 1842
			patch.checkpointSeq or 0, -- 1843
			filesJson, -- 1844
			t, -- 1845
			t -- 1846
		}) -- 1846
		return -- 1849
	end -- 1849
	DB:exec( -- 1851
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1851
		{ -- 1863
			tool, -- 1864
			statusPatch, -- 1865
			status, -- 1866
			reason, -- 1867
			reason, -- 1868
			reasoningContent, -- 1869
			reasoningContent, -- 1870
			paramsJson, -- 1871
			paramsJson, -- 1872
			resultJson, -- 1873
			resultJson, -- 1874
			patch.checkpointId or 0, -- 1875
			patch.checkpointId or 0, -- 1876
			patch.checkpointSeq or 0, -- 1877
			patch.checkpointSeq or 0, -- 1878
			filesJson, -- 1879
			filesJson, -- 1880
			now(), -- 1881
			row[1] -- 1882
		} -- 1882
	) -- 1882
end -- 1882
function getNextStepNumber(sessionId, taskId) -- 1887
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1888
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1892
	return math.max(0, current) + 1 -- 1893
end -- 1893
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1934
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1942
	local t = now() -- 1943
	local sqls = { -- 1944
		{ -- 1945
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1945
			{{ -- 1948
				sessionId, -- 1949
				ownerTaskId, -- 1950
				step, -- 1951
				"sub_agent_handoff", -- 1952
				"DONE", -- 1953
				sanitizeUTF8(reason), -- 1954
				encodeJson(params), -- 1955
				encodeJson(result), -- 1956
				t, -- 1957
				t -- 1958
			}} -- 1958
		}, -- 1958
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1961
	} -- 1961
	if not DB:transaction(sqls) then -- 1961
		return nil -- 1967
	end -- 1967
	return getStepItem(sessionId, ownerTaskId, step) -- 1968
end -- 1968
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1971
	if taskId <= 0 then -- 1971
		return -- 1972
	end -- 1972
	if finalSteps ~= nil and finalSteps >= 0 then -- 1972
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1974
	end -- 1974
	if not finalStatus then -- 1974
		return -- 1980
	end -- 1980
	if finalSteps ~= nil and finalSteps >= 0 then -- 1980
		DB:exec( -- 1982
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1982
			{ -- 1986
				finalStatus, -- 1986
				now(), -- 1986
				sessionId, -- 1986
				taskId, -- 1986
				finalSteps -- 1986
			} -- 1986
		) -- 1986
		return -- 1988
	end -- 1988
	DB:exec( -- 1990
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1990
		{ -- 1994
			finalStatus, -- 1994
			now(), -- 1994
			sessionId, -- 1994
			taskId -- 1994
		} -- 1994
	) -- 1994
end -- 1994
function emitAgentSessionPatch(sessionId, patch) -- 2021
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 2022
	if not text then -- 2022
		return -- 2027
	end -- 2027
	local failed = publishSessionPatch(sessionId, text) -- 2028
	if failed > 0 then -- 2028
		Log( -- 2029
			"Warn", -- 2029
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 2029
		) -- 2029
	end -- 2029
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 2029
		emit("AppWS", "Send", text) -- 2030
	end -- 2030
end -- 2030
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 2033
	emitAgentSessionPatch( -- 2034
		sessionId, -- 2034
		{ -- 2034
			sessionDeleted = true, -- 2035
			relatedSessions = listRelatedSessions(rootSessionId) -- 2036
		} -- 2036
	) -- 2036
	local rootSession = getSessionItem(rootSessionId) -- 2038
	if rootSession then -- 2038
		emitAgentSessionPatch( -- 2040
			rootSessionId, -- 2040
			{ -- 2040
				session = rootSession, -- 2041
				relatedSessions = listRelatedSessions(rootSessionId) -- 2042
			} -- 2042
		) -- 2042
	end -- 2042
end -- 2042
function flushPendingSubAgentHandoffs(rootSession) -- 2047
	if rootSession.kind ~= "main" then -- 2047
		return -- 2048
	end -- 2048
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 2048
		return -- 2050
	end -- 2050
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 2052
	if #items == 0 then -- 2052
		return -- 2053
	end -- 2053
	local handoffTaskId = 0 -- 2054
	local previousTaskId = rootSession.currentTaskId -- 2055
	local ____rootSession_currentTaskId_69 -- 2056
	if rootSession.currentTaskId then -- 2056
		____rootSession_currentTaskId_69 = getTaskPrompt(rootSession.currentTaskId) -- 2056
	else -- 2056
		____rootSession_currentTaskId_69 = nil -- 2056
	end -- 2056
	local currentTaskPrompt = ____rootSession_currentTaskId_69 -- 2056
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 2056
		handoffTaskId = rootSession.currentTaskId -- 2064
	else -- 2064
		local taskRes = Tools.createTask( -- 2066
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 2066
			"code" -- 2066
		) -- 2066
		if not taskRes.success then -- 2066
			Log( -- 2068
				"Warn", -- 2068
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 2068
			) -- 2068
			return -- 2069
		end -- 2069
		handoffTaskId = taskRes.taskId -- 2071
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 2072
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 2073
		emitAgentSessionPatch( -- 2074
			rootSession.id, -- 2074
			{session = getSessionItem(rootSession.id)} -- 2074
		) -- 2074
	end -- 2074
	do -- 2074
		local i = 0 -- 2078
		while i < #items do -- 2078
			local item = items[i + 1] -- 2079
			local step = appendHandoffSystemStep( -- 2080
				rootSession.id, -- 2081
				handoffTaskId, -- 2082
				item.sourceTaskId, -- 2083
				item.message, -- 2084
				{ -- 2085
					sourceSessionId = item.sourceSessionId, -- 2086
					sourceTitle = item.sourceTitle, -- 2087
					sourceTaskId = item.sourceTaskId, -- 2088
					success = item.success == true, -- 2089
					summary = item.message, -- 2090
					resultFilePath = item.resultFilePath or "", -- 2091
					artifactDir = item.artifactDir or "", -- 2092
					finishedAt = item.finishedAt or "", -- 2093
					changeSet = item.changeSet, -- 2094
					handoffEvidence = item.handoffEvidence, -- 2095
					memoryEntry = item.memoryEntry, -- 2096
					completion = item.completion -- 2097
				}, -- 2097
				{ -- 2099
					sourceSessionId = item.sourceSessionId, -- 2100
					sourceTitle = item.sourceTitle, -- 2101
					sourceTaskId = item.sourceTaskId, -- 2102
					prompt = item.prompt, -- 2103
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 2104
					expectedOutput = item.expectedOutput or "", -- 2105
					filesHint = item.filesHint or ({}), -- 2106
					resultFilePath = item.resultFilePath or "", -- 2107
					artifactDir = item.artifactDir or "", -- 2108
					changeSet = item.changeSet, -- 2109
					handoffEvidence = item.handoffEvidence, -- 2110
					memoryEntry = item.memoryEntry, -- 2111
					completion = item.completion -- 2112
				} -- 2112
			) -- 2112
			if step then -- 2112
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 2116
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 2117
			else -- 2117
				Log( -- 2119
					"Warn", -- 2119
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 2119
				) -- 2119
			end -- 2119
			i = i + 1 -- 2078
		end -- 2078
	end -- 2078
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 2078
		cleanupTaskHeavyData(previousTaskId) -- 2123
	end -- 2123
end -- 2123
function applyEvent(sessionId, event) -- 2135
	if not getSessionItem(sessionId) then -- 2135
		streamUpdates:clear(sessionId) -- 2137
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 2137
			__TS__Delete(activeStopTokens, event.taskId) -- 2139
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 2140
		end -- 2140
		return -- 2142
	end -- 2142
	repeat -- 2142
		local ____switch397 = event.type -- 2142
		local metrics, startedSession -- 2142
		local ____cond397 = ____switch397 == "task_started" -- 2142
		if ____cond397 then -- 2142
			streamUpdates:clear(sessionId) -- 2146
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 2147
			local ____event_resumed_72 -- 2148
			if event.resumed then -- 2148
				local ____opt_70 = getSessionItem(sessionId) -- 2148
				____event_resumed_72 = ____opt_70 and ____opt_70.metrics -- 2149
			else -- 2149
				____event_resumed_72 = clearSessionTokenUsage(sessionId) -- 2150
			end -- 2150
			metrics = ____event_resumed_72 -- 2148
			startedSession = getSessionItem(sessionId) -- 2151
			emitAgentSessionPatch( -- 2152
				sessionId, -- 2152
				{ -- 2152
					session = startedSession, -- 2153
					metrics = metrics, -- 2154
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2155
				} -- 2155
			) -- 2155
			break -- 2159
		end -- 2159
		____cond397 = ____cond397 or ____switch397 == "decision_made" -- 2159
		if ____cond397 then -- 2159
			upsertStep( -- 2161
				sessionId, -- 2161
				event.taskId, -- 2161
				event.step, -- 2161
				event.tool, -- 2161
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 2161
			) -- 2161
			emitAgentSessionPatch( -- 2169
				sessionId, -- 2169
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2169
			) -- 2169
			break -- 2172
		end -- 2172
		____cond397 = ____cond397 or ____switch397 == "tool_started" -- 2172
		if ____cond397 then -- 2172
			upsertStep( -- 2174
				sessionId, -- 2174
				event.taskId, -- 2174
				event.step, -- 2174
				event.tool, -- 2174
				{status = "RUNNING"} -- 2174
			) -- 2174
			emitAgentSessionPatch( -- 2177
				sessionId, -- 2177
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2177
			) -- 2177
			break -- 2180
		end -- 2180
		____cond397 = ____cond397 or ____switch397 == "tool_finished" -- 2180
		if ____cond397 then -- 2180
			do -- 2180
				upsertStep( -- 2182
					sessionId, -- 2182
					event.taskId, -- 2182
					event.step, -- 2182
					event.tool, -- 2182
					{status = event.execution.status, reason = event.reason, result = event.result} -- 2182
				) -- 2182
				emitAgentSessionPatch( -- 2190
					sessionId, -- 2190
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2190
				) -- 2190
				break -- 2193
			end -- 2193
		end -- 2193
		____cond397 = ____cond397 or ____switch397 == "tool_progress" -- 2193
		if ____cond397 then -- 2193
			do -- 2193
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 2197
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 2197
					break -- 2199
				end -- 2199
			end -- 2199
			upsertStep( -- 2202
				sessionId, -- 2202
				event.taskId, -- 2202
				event.step, -- 2202
				event.tool, -- 2202
				{status = "RUNNING", result = event.result} -- 2202
			) -- 2202
			emitAgentSessionPatch( -- 2206
				sessionId, -- 2206
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2206
			) -- 2206
			break -- 2209
		end -- 2209
		____cond397 = ____cond397 or ____switch397 == "checkpoint_created" -- 2209
		if ____cond397 then -- 2209
			upsertStep( -- 2211
				sessionId, -- 2211
				event.taskId, -- 2211
				event.step, -- 2211
				event.tool, -- 2211
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2211
			) -- 2211
			emitAgentSessionPatch( -- 2216
				sessionId, -- 2216
				{ -- 2216
					step = getStepItem(sessionId, event.taskId, event.step), -- 2217
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2218
				} -- 2218
			) -- 2218
			break -- 2220
		end -- 2220
		____cond397 = ____cond397 or ____switch397 == "memory_compression_started" -- 2220
		if ____cond397 then -- 2220
			upsertStep( -- 2222
				sessionId, -- 2222
				event.taskId, -- 2222
				event.step, -- 2222
				event.tool, -- 2222
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2222
			) -- 2222
			emitAgentSessionPatch( -- 2227
				sessionId, -- 2227
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2227
			) -- 2227
			break -- 2230
		end -- 2230
		____cond397 = ____cond397 or ____switch397 == "memory_compression_finished" -- 2230
		if ____cond397 then -- 2230
			upsertStep( -- 2232
				sessionId, -- 2232
				event.taskId, -- 2232
				event.step, -- 2232
				event.tool, -- 2232
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2232
			) -- 2232
			emitAgentSessionPatch( -- 2237
				sessionId, -- 2237
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2237
			) -- 2237
			break -- 2240
		end -- 2240
		____cond397 = ____cond397 or ____switch397 == "metrics_updated" -- 2240
		if ____cond397 then -- 2240
			do -- 2240
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2242
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2243
				break -- 2246
			end -- 2246
		end -- 2246
		____cond397 = ____cond397 or ____switch397 == "assistant_message_updated" -- 2246
		if ____cond397 then -- 2246
			do -- 2246
				local session = getSessionItem(sessionId) -- 2249
				if (session and session.currentTaskId) ~= event.taskId then -- 2249
					streamUpdates:clear(sessionId, event.taskId) -- 2251
					break -- 2251
				end -- 2251
				streamUpdates:update( -- 2253
					sessionId, -- 2253
					event.taskId, -- 2253
					event.step, -- 2253
					event, -- 2253
					App.runningTime -- 2253
				) -- 2253
				scheduleStreamFlush() -- 2254
				break -- 2255
			end -- 2255
		end -- 2255
		____cond397 = ____cond397 or ____switch397 == "assistant_message_finished" -- 2255
		if ____cond397 then -- 2255
			do -- 2255
				local ____opt_75 = getSessionItem(sessionId) -- 2255
				if (____opt_75 and ____opt_75.currentTaskId) ~= event.taskId then -- 2255
					streamUpdates:clear(sessionId, event.taskId) -- 2259
					break -- 2259
				end -- 2259
				streamUpdates:finish(sessionId, event.taskId, event.step) -- 2261
				upsertStep( -- 2262
					sessionId, -- 2262
					event.taskId, -- 2262
					event.step, -- 2262
					"message", -- 2262
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2262
				) -- 2262
				emitAgentSessionPatch( -- 2268
					sessionId, -- 2268
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2268
				) -- 2268
				break -- 2271
			end -- 2271
		end -- 2271
		____cond397 = ____cond397 or ____switch397 == "task_waiting_for_user" -- 2271
		if ____cond397 then -- 2271
			do -- 2271
				local ____opt_77 = getSessionItem(sessionId) -- 2271
				if (____opt_77 and ____opt_77.currentTaskId) ~= event.taskId then -- 2271
					streamUpdates:clear(sessionId, event.taskId) -- 2275
					break -- 2275
				end -- 2275
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2277
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2278
				__TS__Delete(activeStopTokens, event.taskId) -- 2279
				emitAgentSessionPatch( -- 2280
					sessionId, -- 2280
					{ -- 2280
						session = getSessionItem(sessionId), -- 2281
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2282
					} -- 2282
				) -- 2282
				break -- 2284
			end -- 2284
		end -- 2284
		____cond397 = ____cond397 or ____switch397 == "task_finished" -- 2284
		if ____cond397 then -- 2284
			do -- 2284
				local session = getSessionItem(sessionId) -- 2287
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2287
					__TS__Delete(activeStopTokens, event.taskId) -- 2289
					streamUpdates:clear(sessionId, event.taskId) -- 2290
					Log( -- 2291
						"Info", -- 2291
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2291
					) -- 2291
					break -- 2292
				end -- 2292
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2294
				local ____opt_79 = activeStopTokens[event.taskId or -1] -- 2294
				local stopped = (____opt_79 and ____opt_79.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2295
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2297
				local isSubSession = (session and session.kind) == "sub" -- 2300
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2301
				if isSubSession and event.taskId ~= nil then -- 2301
					finalizingSubSessionTaskIds[event.taskId] = true -- 2303
				end -- 2303
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2305
				if event.taskId ~= nil then -- 2305
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2307
					local ____finalizeTaskSteps_85 = finalizeTaskSteps -- 2308
					local ____array_84 = __TS__SparseArrayNew( -- 2308
						sessionId, -- 2309
						event.taskId, -- 2310
						type(event.steps) == "number" and math.max( -- 2311
							0, -- 2311
							math.floor(event.steps) -- 2311
						) or nil -- 2311
					) -- 2311
					local ____event_success_83 -- 2312
					if event.success then -- 2312
						____event_success_83 = nil -- 2312
					else -- 2312
						____event_success_83 = stopped and "STOPPED" or "FAILED" -- 2312
					end -- 2312
					__TS__SparseArrayPush(____array_84, ____event_success_83) -- 2312
					____finalizeTaskSteps_85(__TS__SparseArraySpread(____array_84)) -- 2308
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2314
					if not isSubSession then -- 2314
						__TS__Delete(activeStopTokens, event.taskId) -- 2316
					end -- 2316
					emitAgentSessionPatch( -- 2318
						sessionId, -- 2318
						{ -- 2318
							session = getSessionItem(sessionId), -- 2319
							message = getMessageItem(messageId), -- 2320
							removedStepIds = removedStepIds -- 2321
						} -- 2321
					) -- 2321
				end -- 2321
				if session and session.kind == "main" then -- 2321
					flushPendingSubAgentHandoffs(session) -- 2325
				end -- 2325
				break -- 2327
			end -- 2327
		end -- 2327
	until true -- 2327
end -- 2327
function ____exports.createSession(projectRoot, title) -- 2332
	if title == nil then -- 2332
		title = "" -- 2332
	end -- 2332
	local storage = requireAgentStorage() -- 2333
	if not storage.success then -- 2333
		return storage -- 2334
	end -- 2334
	if not isValidProjectRoot(projectRoot) then -- 2334
		return {success = false, message = "invalid projectRoot"} -- 2336
	end -- 2336
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2338
	if row then -- 2338
		return { -- 2347
			success = true, -- 2347
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2347
		} -- 2347
	end -- 2347
	local t = now() -- 2349
	DB:exec( -- 2350
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2350
		{ -- 2353
			projectRoot, -- 2353
			title ~= "" and title or Path:getFilename(projectRoot), -- 2353
			t, -- 2353
			t -- 2353
		} -- 2353
	) -- 2353
	local sessionId = getLastInsertRowId() -- 2355
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2356
	local session = getSessionItem(sessionId) -- 2357
	if not session then -- 2357
		return {success = false, message = "failed to create session"} -- 2359
	end -- 2359
	return {success = true, session = session} -- 2361
end -- 2332
function ____exports.createSubSession(parentSessionId, title) -- 2364
	if title == nil then -- 2364
		title = "" -- 2364
	end -- 2364
	local storage = requireAgentStorage() -- 2365
	if not storage.success then -- 2365
		return storage -- 2366
	end -- 2366
	local parent = getSessionItem(parentSessionId) -- 2367
	if not parent then -- 2367
		return {success = false, message = "parent session not found"} -- 2369
	end -- 2369
	local rootId = getSessionRootId(parent) -- 2371
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2371
		return {success = false, message = "project task admission is closed"} -- 2372
	end -- 2372
	local t = now() -- 2373
	DB:exec( -- 2374
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2374
		{ -- 2377
			parent.projectRoot, -- 2377
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2377
			rootId, -- 2377
			parent.id, -- 2377
			t, -- 2377
			t -- 2377
		} -- 2377
	) -- 2377
	local sessionId = getLastInsertRowId() -- 2379
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2380
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2381
	local session = getSessionItem(sessionId) -- 2382
	if not session then -- 2382
		return {success = false, message = "failed to create sub session"} -- 2384
	end -- 2384
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2386
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2387
	subStorage:writeMemory(parentStorage:readMemory()) -- 2388
	return {success = true, session = session} -- 2389
end -- 2364
function spawnSubAgentSession(request) -- 2392
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2392
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2405
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2406
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2407
		if normalizedPrompt == "" then -- 2407
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2409
		end -- 2409
		if normalizedPrompt == "" then -- 2409
			local ____Log_91 = Log -- 2416
			local ____temp_88 = #normalizedTitle -- 2416
			local ____temp_89 = #rawPrompt -- 2416
			local ____temp_90 = #toStr(request.expectedOutput) -- 2416
			local ____opt_86 = request.filesHint -- 2416
			____Log_91( -- 2416
				"Warn", -- 2416
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_88)) .. " raw_prompt_len=") .. tostring(____temp_89)) .. " expected_len=") .. tostring(____temp_90)) .. " files_hint_count=") .. tostring(____opt_86 and #____opt_86 or 0) -- 2416
			) -- 2416
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2416
		end -- 2416
		Log( -- 2419
			"Info", -- 2419
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2419
		) -- 2419
		local parentSessionId = request.parentSessionId -- 2420
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2420
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2422
			if not fallbackParent then -- 2422
				local createdMain = ____exports.createSession(request.projectRoot) -- 2424
				if createdMain.success then -- 2424
					fallbackParent = createdMain.session -- 2426
				end -- 2426
			end -- 2426
			if fallbackParent then -- 2426
				Log( -- 2430
					"Warn", -- 2430
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2430
				) -- 2430
				parentSessionId = fallbackParent.id -- 2431
			end -- 2431
		end -- 2431
		local parentSession = getSessionItem(parentSessionId) -- 2434
		if not parentSession then -- 2434
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2434
		end -- 2434
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2438
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2438
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2438
		end -- 2438
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2438
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2438
		end -- 2438
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2443
		if not created.success then -- 2443
			return ____awaiter_resolve(nil, created) -- 2443
		end -- 2443
		writeSpawnInfo( -- 2447
			created.session.projectRoot, -- 2447
			created.session.memoryScope, -- 2447
			{ -- 2447
				sessionId = created.session.id, -- 2448
				rootSessionId = created.session.rootSessionId, -- 2449
				parentSessionId = created.session.parentSessionId, -- 2450
				title = created.session.title, -- 2451
				prompt = normalizedPrompt, -- 2452
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2453
				expectedOutput = request.expectedOutput or "", -- 2454
				filesHint = request.filesHint or ({}), -- 2455
				status = "RUNNING", -- 2456
				success = false, -- 2457
				resultFilePath = "", -- 2458
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2459
				sourceTaskId = 0, -- 2460
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2461
				createdAtTs = created.session.createdAt, -- 2462
				finishedAt = "", -- 2463
				finishedAtTs = 0 -- 2464
			} -- 2464
		) -- 2464
		local sent = ____exports.sendPrompt( -- 2466
			created.session.id, -- 2466
			normalizedPrompt, -- 2466
			request.disabledAgentTools, -- 2466
			nil, -- 2466
			nil, -- 2466
			request.llmConfig -- 2466
		) -- 2466
		if not sent.success then -- 2466
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2466
		end -- 2466
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2466
	end) -- 2466
end -- 2466
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2590
	local rootSession = getRootSessionItem(session.id) -- 2591
	if not rootSession then -- 2591
		return -- 2592
	end -- 2592
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2593
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2594
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2595
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2596
	local queueResult = writePendingHandoff( -- 2597
		rootSession.projectRoot, -- 2597
		rootSession.memoryScope, -- 2597
		{ -- 2597
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2598
			sourceSessionId = session.id, -- 2599
			sourceTitle = session.title, -- 2600
			sourceTaskId = taskId, -- 2601
			message = summary, -- 2602
			prompt = result.prompt, -- 2603
			goal = result.goal, -- 2604
			expectedOutput = result.expectedOutput or "", -- 2605
			filesHint = result.filesHint or ({}), -- 2606
			success = result.success, -- 2607
			resultFilePath = result.resultFilePath, -- 2608
			artifactDir = result.artifactDir, -- 2609
			finishedAt = result.finishedAt, -- 2610
			changeSet = changeSet, -- 2611
			handoffEvidence = result.handoffEvidence, -- 2612
			memoryEntry = result.memoryEntry, -- 2613
			completion = result.completion, -- 2614
			createdAt = createdAt -- 2615
		} -- 2615
	) -- 2615
	if not queueResult then -- 2615
		Log( -- 2618
			"Warn", -- 2618
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2618
		) -- 2618
		return -- 2619
	end -- 2619
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2619
		addTaskReference(rootSession.currentTaskId, taskId) -- 2622
	end -- 2622
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2622
		flushPendingSubAgentHandoffs(rootSession) -- 2625
	end -- 2625
end -- 2625
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2629
	if forceHandoff == nil then -- 2629
		forceHandoff = false -- 2635
	end -- 2635
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2635
		local rootSessionId = getSessionRootId(session) -- 2637
		local rootSession = getRootSessionItem(session.id) -- 2638
		if not rootSession then -- 2638
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2638
		end -- 2638
		local spawnInfo = getSessionSpawnInfo(session) -- 2642
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2643
		local finishedAtTs = now() -- 2644
		local resultText = sanitizeUTF8(message) -- 2645
		local changeSet = getTaskChangeSetSummary(taskId) -- 2646
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2647
		local ____completion_103 = completion -- 2649
		if ____completion_103 == nil then -- 2649
			local ____normalizeAgentCompletionReport_102 = normalizeAgentCompletionReport -- 2649
			local ____opt_100 = handoffEvidence.lastBuild -- 2649
			____completion_103 = ____normalizeAgentCompletionReport_102({outcome = (____opt_100 and ____opt_100.result) == "passed" and "completed" or "partial", knownIssues = {}}) -- 2649
		end -- 2649
		local completionReport = ____completion_103 -- 2649
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2653
		if not success and completionReport.outcome == "completed" and not forceHandoff then -- 2653
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "blocked", knownIssues = {resultText ~= "" and resultText or "The sub-agent did not complete."}})) -- 2655
		end -- 2655
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2655
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2662
		end -- 2662
		local completed = success and completionReport.outcome == "completed" -- 2670
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2671
		local record = { -- 2674
			sessionId = session.id, -- 2675
			rootSessionId = rootSessionId, -- 2676
			parentSessionId = session.parentSessionId, -- 2677
			title = session.title, -- 2678
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2679
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2680
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2681
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2682
			status = recordStatus, -- 2683
			success = completed, -- 2684
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2685
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2686
			sourceTaskId = taskId, -- 2687
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2688
			finishedAt = finishedAt, -- 2689
			createdAtTs = session.createdAt, -- 2690
			finishedAtTs = finishedAtTs, -- 2691
			changeSet = changeSet, -- 2692
			handoffEvidence = handoffEvidence, -- 2693
			completion = completionReport -- 2694
		} -- 2694
		local ____record_success_114 -- 2696
		if record.success then -- 2696
			____record_success_114 = buildStructuredSubAgentMemoryEntry(record) -- 2696
		else -- 2696
			____record_success_114 = nil -- 2696
		end -- 2696
		record.memoryEntry = ____record_success_114 -- 2696
		if not writeSubAgentResultFile(session, record, resultText) then -- 2696
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2696
		end -- 2696
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2696
			sessionId = record.sessionId, -- 2701
			rootSessionId = record.rootSessionId, -- 2702
			parentSessionId = record.parentSessionId, -- 2703
			title = record.title, -- 2704
			prompt = record.prompt, -- 2705
			goal = record.goal, -- 2706
			expectedOutput = record.expectedOutput or "", -- 2707
			filesHint = record.filesHint or ({}), -- 2708
			status = record.status, -- 2709
			success = record.success, -- 2710
			resultFilePath = record.resultFilePath, -- 2711
			artifactDir = record.artifactDir, -- 2712
			sourceTaskId = record.sourceTaskId, -- 2713
			createdAt = record.createdAt, -- 2714
			finishedAt = record.finishedAt, -- 2715
			createdAtTs = record.createdAtTs, -- 2716
			finishedAtTs = record.finishedAtTs, -- 2717
			changeSet = record.changeSet, -- 2718
			handoffEvidence = record.handoffEvidence, -- 2719
			memoryEntry = record.memoryEntry, -- 2720
			memoryEntryError = record.memoryEntryError, -- 2721
			completion = record.completion -- 2722
		}) then -- 2722
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2722
		end -- 2722
		if success or forceHandoff then -- 2722
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2727
			deleteSessionRecords(session.id, true) -- 2728
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2729
		end -- 2729
		return ____awaiter_resolve(nil, {success = true}) -- 2729
	end) -- 2729
end -- 2729
function stopClearedSubSession(session, taskId) -- 2734
	local spawnInfo = getSessionSpawnInfo(session) -- 2735
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2736
	local rootSessionId = getSessionRootId(session) -- 2737
	Tools.setTaskStatus(taskId, "STOPPED") -- 2738
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2739
	if not writeSpawnInfo( -- 2739
		session.projectRoot, -- 2740
		session.memoryScope, -- 2740
		{ -- 2740
			sessionId = session.id, -- 2741
			rootSessionId = rootSessionId, -- 2742
			parentSessionId = session.parentSessionId, -- 2743
			title = session.title, -- 2744
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2745
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2746
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2747
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2748
			status = "STOPPED", -- 2749
			success = false, -- 2750
			cleared = true, -- 2751
			resultFilePath = "", -- 2752
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2753
			sourceTaskId = taskId, -- 2754
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2755
			finishedAt = finishedAt, -- 2756
			createdAtTs = session.createdAt, -- 2757
			finishedAtTs = now() -- 2758
		} -- 2758
	) then -- 2758
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2760
	end -- 2760
	deleteSessionRecords(session.id, true) -- 2762
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2763
	return {success = true} -- 2764
end -- 2764
function startImmediatePrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, inputId) -- 2767
	local session = getSessionItem(sessionId) -- 2768
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2768
		return {success = false, message = "project task admission is closed"} -- 2769
	end -- 2769
	if not session then -- 2769
		return {success = false, message = "session not found"} -- 2771
	end -- 2771
	if getPendingQuestionnaire(sessionId) then -- 2771
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2773
	end -- 2773
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2773
		return {success = false, message = "session task is finalizing"} -- 2775
	end -- 2775
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2775
		return {success = false, message = "session task is still running"} -- 2778
	end -- 2778
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2780
	if normalizedPrompt == "" and session.kind == "sub" then -- 2780
		local spawnInfo = getSessionSpawnInfo(session) -- 2782
		if spawnInfo then -- 2782
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2784
			if normalizedPrompt == "" then -- 2784
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2786
			end -- 2786
		end -- 2786
	end -- 2786
	if normalizedPrompt == "" then -- 2786
		return {success = false, message = "prompt is empty"} -- 2795
	end -- 2795
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2797
	if session.workMode ~= nextWorkMode then -- 2797
		DB:exec( -- 2799
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2799
			{ -- 2799
				nextWorkMode, -- 2799
				now(), -- 2799
				session.id -- 2799
			} -- 2799
		) -- 2799
		session.workMode = nextWorkMode -- 2800
	end -- 2800
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2802
	return startPromptTask( -- 2803
		session, -- 2803
		normalizedPrompt, -- 2803
		nil, -- 2803
		normalizeDisabledAgentTools(disabledAgentTools), -- 2803
		{ -- 2803
			workMode = nextWorkMode, -- 2803
			llmConfigId = llmConfigId, -- 2803
			llmConfig = llmConfig, -- 2803
			maxSteps = boundedMaxSteps, -- 2803
			inputId = inputId -- 2803
		} -- 2803
	) -- 2803
end -- 2803
function startLocalPrompt(sessionId, prompt, localAgentConfigId, inputId) -- 2806
	local session = getSessionItem(sessionId) -- 2807
	if not session then -- 2807
		return {success = false, message = "session not found"} -- 2808
	end -- 2808
	if session.kind ~= "main" then -- 2808
		return {success = false, message = "local Agent only supports main sessions"} -- 2809
	end -- 2809
	if getPendingQuestionnaire(sessionId) then -- 2809
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2810
	end -- 2810
	if session.currentTaskStatus == "RUNNING" then -- 2810
		return {success = false, message = "session task is still running"} -- 2811
	end -- 2811
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2812
	if normalizedPrompt == "" then -- 2812
		return {success = false, message = "prompt is empty"} -- 2813
	end -- 2813
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2814
	if not config then -- 2814
		return {success = false, message = "local Agent config not found"} -- 2815
	end -- 2815
	if not config.verifiedAt then -- 2815
		return {success = false, message = "local Agent config is not verified"} -- 2816
	end -- 2816
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2817
	if not taskRes.success then -- 2817
		return taskRes -- 2818
	end -- 2818
	local taskId = taskRes.taskId -- 2819
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2820
	if inputId ~= nil then -- 2820
		InputInbox.markDelivering(inputId, taskId) -- 2821
		InputInbox.markDelivered(inputId, messageId) -- 2821
	end -- 2821
	followup.activeRuns[sessionId] = taskId -- 2822
	Tools.setTaskStatus(taskId, "RUNNING") -- 2823
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2824
	upsertStep( -- 2825
		session.id, -- 2825
		taskId, -- 2825
		1, -- 2825
		"local_agent_message", -- 2825
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2825
	) -- 2825
	emitAgentSessionPatch( -- 2831
		session.id, -- 2831
		{ -- 2831
			session = getSessionItem(session.id), -- 2832
			message = getMessageItem(messageId), -- 2833
			step = getStepItem(session.id, taskId, 1) -- 2834
		} -- 2834
	) -- 2834
	local events = {} -- 2836
	local transcript = "" -- 2837
	local assistant = "" -- 2838
	local lastFlush = 0 -- 2839
	local function flush(force) -- 2840
		if force == nil then -- 2840
			force = false -- 2840
		end -- 2840
		if not force and App.runningTime - lastFlush < 0.075 then -- 2840
			return -- 2841
		end -- 2841
		lastFlush = App.runningTime -- 2842
		if #events > 400 then -- 2842
			events = __TS__ArraySlice(events, #events - 400) -- 2843
		end -- 2843
		if #transcript > 1024 * 1024 then -- 2843
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2844
		end -- 2844
		upsertStep( -- 2845
			session.id, -- 2845
			taskId, -- 2845
			1, -- 2845
			"local_agent_message", -- 2845
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2845
		) -- 2845
		local message -- 2850
		if assistant ~= "" then -- 2850
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2852
			message = getMessageItem(assistantId) -- 2853
		end -- 2853
		emitAgentSessionPatch( -- 2855
			session.id, -- 2855
			__TS__ObjectAssign( -- 2855
				{step = getStepItem(session.id, taskId, 1)}, -- 2855
				message and ({message = message}) or ({}) -- 2855
			) -- 2855
		) -- 2855
	end -- 2840
	local completedSynchronously = false -- 2857
	local control = LocalAgent.run( -- 2858
		session.id, -- 2858
		config, -- 2858
		session.projectRoot, -- 2858
		normalizedPrompt, -- 2858
		function(event) -- 2858
			local text = sanitizeUTF8(event.text) -- 2859
			if text == "" then -- 2859
				return -- 2860
			end -- 2860
			local previous = #events > 0 and events[#events] or nil -- 2861
			if previous and previous.kind == event.kind and previous.text == text then -- 2861
				return -- 2862
			end -- 2862
			events[#events + 1] = {kind = event.kind, text = text} -- 2863
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2864
			if event.kind == "assistant" then -- 2864
				assistant = text -- 2865
			end -- 2865
			flush(false) -- 2866
		end, -- 2858
		function(result) -- 2867
			completedSynchronously = true -- 2868
			flush(true) -- 2869
			__TS__Delete(activeLocalAgentControls, taskId) -- 2870
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2871
			Tools.setTaskStatus(taskId, status) -- 2872
			setSessionState(session.id, status, taskId, status) -- 2873
			upsertStep( -- 2874
				session.id, -- 2874
				taskId, -- 2874
				1, -- 2874
				"local_agent_message", -- 2874
				{status = status, reason = config.name .. " · full permissions", result = { -- 2874
					provider = config.provider, -- 2877
					events = events, -- 2877
					transcript = transcript, -- 2877
					exitCode = result.exitCode, -- 2877
					resumeId = result.resumeId, -- 2877
					message = result.message -- 2877
				}} -- 2877
			) -- 2877
			emitAgentSessionPatch( -- 2879
				session.id, -- 2879
				{ -- 2879
					session = getSessionItem(session.id), -- 2879
					step = getStepItem(session.id, taskId, 1) -- 2879
				} -- 2879
			) -- 2879
			followup.settle(sessionId, taskId, result.success and not result.stopped) -- 2880
		end -- 2867
	) -- 2867
	if not completedSynchronously then -- 2867
		activeLocalAgentControls[taskId] = control -- 2882
	end -- 2882
	return {success = true, sessionId = session.id, taskId = taskId} -- 2883
end -- 2883
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2956
	if disabledAgentTools == nil then -- 2956
		disabledAgentTools = {} -- 2960
	end -- 2960
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2963
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2963
		return {success = false, message = "project task admission is closed"} -- 2964
	end -- 2964
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2965
	if not llmConfigRes.success then -- 2965
		return {success = false, message = llmConfigRes.message} -- 2969
	end -- 2969
	local llmConfig = llmConfigRes.config -- 2971
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2972
	if not llmConfigValidation.success then -- 2972
		return llmConfigValidation -- 2974
	end -- 2974
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2976
	if not taskRes.success then -- 2976
		return {success = false, message = taskRes.message} -- 2979
	end -- 2979
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2979
		removeContinuableTaskSummary(session) -- 2981
	end -- 2981
	local taskId = taskRes.taskId -- 2983
	if (options and options.inputId) ~= nil then -- 2983
		InputInbox.markDelivering(options.inputId, taskId) -- 2984
	end -- 2984
	followup.activeRuns[session.id] = taskId -- 2985
	local ____temp_137 -- 2986
	if (options and options.existingTaskId) == nil then -- 2986
		____temp_137 = session.currentTaskId -- 2986
	else -- 2986
		____temp_137 = nil -- 2986
	end -- 2986
	local previousTaskId = ____temp_137 -- 2986
	local useChineseResponse = getDefaultUseChineseResponse() -- 2987
	local promptMessageId -- 2988
	if existingUserMessageId ~= nil then -- 2988
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2990
		promptMessageId = existingUserMessageId -- 2991
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2991
		promptMessageId = insertMessage( -- 2993
			session.id, -- 2993
			"user", -- 2993
			normalizedPrompt, -- 2993
			taskId, -- 2993
			options and options.displayContent -- 2993
		) -- 2993
	end -- 2993
	if (options and options.inputId) ~= nil and promptMessageId ~= nil then -- 2993
		if DB:exec("UPDATE agent.AgentSessionInput SET message_id=? WHERE id=?", {promptMessageId, options.inputId}) < 0 then -- 2993
			error( -- 2996
				__TS__New(Error, "failed to link input display"), -- 2996
				0 -- 2996
			) -- 2996
		end -- 2996
		if normalizedPrompt == "/clear" or normalizedPrompt == "/compact" then -- 2996
			InputInbox.markDelivered(options.inputId, promptMessageId) -- 2997
		end -- 2997
	end -- 2997
	local stopToken = {stopped = false} -- 2999
	activeStopTokens[taskId] = stopToken -- 3000
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3001
	emitAgentSessionPatch( -- 3005
		session.id, -- 3005
		__TS__ObjectAssign( -- 3005
			{session = getSessionItem(session.id)}, -- 3005
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 3007
		) -- 3007
	) -- 3007
	if previousTaskId and previousTaskId ~= taskId then -- 3007
		cleanupTaskHeavyData(previousTaskId) -- 3010
	end -- 3010
	activePromptRuns = activePromptRuns + 1 -- 3012
	local ____runCodingAgent_172 = runCodingAgent -- 3013
	local ____normalizedPrompt_163 = normalizedPrompt -- 3014
	local ____temp_164 = options and options.inputId -- 3015
	local ____temp_165 = { -- 3016
		pending = function() return __TS__ArrayMap( -- 3017
			__TS__ArrayFilter( -- 3017
				InputInbox.listInputs(session.id), -- 3017
				function(____, item) return item.delivery == "steer" and not item.held and item.status == "pending" end -- 3017
			), -- 3017
			function(____, item) return {id = item.id, content = item.content} end -- 3017
		) end, -- 3017
		delivered = function(id, step) return followup.delivered(session.id, taskId, id, step) end -- 3018
	} -- 3018
	local ____temp_166 = options and options.resumeConversation -- 3020
	local ____temp_167 = (options and options.existingTaskId) ~= nil -- 3021
	local ____temp_168 = options and options.initialStep -- 3022
	local ____temp_169 = options and options.initialAgentStepCount -- 3023
	local ____temp_158 -- 3024
	if (options and options.existingTaskId) ~= nil then -- 3024
		____temp_158 = getInitialTokenUsage(session) -- 3024
	else -- 3024
		____temp_158 = nil -- 3024
	end -- 3024
	____runCodingAgent_172( -- 3013
		{ -- 3013
			prompt = ____normalizedPrompt_163, -- 3014
			inputId = ____temp_164, -- 3015
			inputSource = ____temp_165, -- 3016
			resumeConversation = ____temp_166, -- 3020
			resumeTask = ____temp_167, -- 3021
			initialStep = ____temp_168, -- 3022
			initialAgentStepCount = ____temp_169, -- 3023
			initialTokenUsage = ____temp_158, -- 3024
			workDir = session.projectRoot, -- 3025
			useChineseResponse = useChineseResponse, -- 3026
			taskId = taskId, -- 3027
			sessionId = session.id, -- 3028
			memoryScope = session.memoryScope, -- 3029
			role = session.kind, -- 3030
			maxSteps = options and options.maxSteps, -- 3031
			disabledAgentTools = disabledAgentTools, -- 3032
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 3033
			llmConfig = llmConfig, -- 3034
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 3035
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 3038
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 3041
			stopToken = stopToken, -- 3042
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 3043
		}, -- 3043
		function(result) -- 3044
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3044
				local ____hasReturned, ____returnValue -- 3044
				local ____try = __TS__AsyncAwaiter(function() -- 3044
					local nextSession = getSessionItem(session.id) -- 3046
					if nextSession and nextSession.kind == "sub" then -- 3046
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 3046
							local stopped = stopClearedSubSession(nextSession, taskId) -- 3049
							if not stopped.success then -- 3049
								Log( -- 3051
									"Warn", -- 3051
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 3051
								) -- 3051
								emitAgentSessionPatch( -- 3052
									session.id, -- 3052
									{session = getSessionItem(session.id)} -- 3052
								) -- 3052
							end -- 3052
							__TS__Delete(activeStopTokens, taskId) -- 3056
							____hasReturned = true -- 3057
							return -- 3057
						end -- 3057
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3059
						emitAgentSessionPatch( -- 3060
							session.id, -- 3060
							{session = getSessionItem(session.id)} -- 3060
						) -- 3060
						local finalized = __TS__Await(finalizeSubSession( -- 3063
							nextSession, -- 3064
							taskId, -- 3065
							result.success, -- 3066
							result.message, -- 3067
							result.completion, -- 3068
							(options and options.forceSubAgentHandoff) == true -- 3069
						)) -- 3069
						if not finalized.success then -- 3069
							Log( -- 3072
								"Warn", -- 3072
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 3072
							) -- 3072
						end -- 3072
						local finalizedSession = getSessionItem(session.id) -- 3074
						if finalizedSession then -- 3074
							local stopped = stopToken.stopped == true -- 3076
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 3077
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 3080
							emitAgentSessionPatch( -- 3081
								session.id, -- 3081
								{session = getSessionItem(session.id)} -- 3081
							) -- 3081
						end -- 3081
						__TS__Delete(activeStopTokens, taskId) -- 3085
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 3086
					end -- 3086
					local fallbackSession = getSessionItem(session.id) -- 3088
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 3088
						applyEvent(session.id, { -- 3094
							type = "task_finished", -- 3095
							sessionId = session.id, -- 3096
							taskId = result.taskId, -- 3097
							success = false, -- 3098
							message = result.message, -- 3099
							steps = result.steps -- 3100
						}) -- 3100
					end -- 3100
				end) -- 3100
				____try = ____try.finally( -- 3100
					____try, -- 3100
					function() -- 3100
						return __TS__AsyncAwaiter(function() -- 3100
							activePromptRuns = activePromptRuns - 1 -- 3104
							followup.settle(session.id, taskId, result.success and not result.waitingForUser and not stopToken.stopped) -- 3105
						end) -- 3105
					end -- 3105
				) -- 3105
				__TS__Await(____try) -- 3045
				if ____hasReturned then -- 3045
					return ____awaiter_resolve(nil, ____returnValue) -- 3045
				end -- 3045
			end) -- 3045
		end -- 3044
	) -- 3044
	return {success = true, sessionId = session.id, taskId = taskId} -- 3108
end -- 3108
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3262
	local lines = {} -- 3263
	do -- 3263
		local i = 0 -- 3264
		while i < #questionnaire.schema.questions do -- 3264
			local question = questionnaire.schema.questions[i + 1] -- 3265
			local answer = __TS__ArrayFind( -- 3266
				answers, -- 3266
				function(____, item) return item.questionId == question.id end -- 3266
			) -- 3266
			local answerText = "已跳过" -- 3267
			if answer and answer.status == "answered" then -- 3267
				local parts = {} -- 3269
				do -- 3269
					local j = 0 -- 3270
					while j < #(answer.selectedOptionIds or ({})) do -- 3270
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3271
						local option = __TS__ArrayFind( -- 3272
							question.options or ({}), -- 3272
							function(____, item) return item.id == optionId end -- 3272
						) -- 3272
						if option then -- 3272
							parts[#parts + 1] = option.label -- 3273
						end -- 3273
						j = j + 1 -- 3270
					end -- 3270
				end -- 3270
				if answer.otherText then -- 3270
					parts[#parts + 1] = answer.otherText -- 3275
				end -- 3275
				if answer.text then -- 3275
					parts[#parts + 1] = answer.text -- 3276
				end -- 3276
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3277
			end -- 3277
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3279
			i = i + 1 -- 3264
		end -- 3264
	end -- 3264
	return table.concat(lines, "\n\n") -- 3281
end -- 3281
function ____exports.listRunningSubAgents(request) -- 3568
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3568
		local session = getSessionItem(request.sessionId) -- 3576
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3576
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3578
		end -- 3578
		if not session then -- 3578
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3578
		end -- 3578
		local rootSession = getRootSessionItem(session.id) -- 3583
		if not rootSession then -- 3583
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3583
		end -- 3583
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3587
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3588
		local limit = math.max( -- 3589
			1, -- 3589
			math.floor(tonumber(request.limit) or 5) -- 3589
		) -- 3589
		local offset = math.max( -- 3590
			0, -- 3590
			math.floor(tonumber(request.offset) or 0) -- 3590
		) -- 3590
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3591
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3592
		local runningSessions = {} -- 3599
		do -- 3599
			local i = 0 -- 3600
			while i < #rows do -- 3600
				do -- 3600
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3601
					if current.currentTaskStatus ~= "RUNNING" then -- 3601
						goto __continue658 -- 3603
					end -- 3603
					local spawnInfo = getSessionSpawnInfo(current) -- 3605
					runningSessions[#runningSessions + 1] = { -- 3606
						sessionId = current.id, -- 3607
						title = current.title, -- 3608
						parentSessionId = current.parentSessionId, -- 3609
						rootSessionId = current.rootSessionId, -- 3610
						status = "RUNNING", -- 3611
						currentTaskId = current.currentTaskId, -- 3612
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3613
						goal = spawnInfo and spawnInfo.goal, -- 3614
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3615
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3616
						createdAt = current.createdAt, -- 3617
						updatedAt = current.updatedAt -- 3618
					} -- 3618
				end -- 3618
				::__continue658:: -- 3618
				i = i + 1 -- 3600
			end -- 3600
		end -- 3600
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3621
		local completedSessions = __TS__ArrayMap( -- 3622
			completedRecords, -- 3622
			function(____, record) return { -- 3622
				sessionId = record.sessionId, -- 3623
				title = record.title, -- 3624
				parentSessionId = record.parentSessionId, -- 3625
				rootSessionId = record.rootSessionId, -- 3626
				status = record.status, -- 3627
				goal = record.goal, -- 3628
				expectedOutput = record.expectedOutput, -- 3629
				filesHint = record.filesHint, -- 3630
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3631
				success = record.success, -- 3632
				cleared = record.cleared, -- 3633
				resultFilePath = record.resultFilePath, -- 3634
				artifactDir = record.artifactDir, -- 3635
				finishedAt = record.finishedAt, -- 3636
				createdAt = record.createdAtTs, -- 3637
				updatedAt = record.finishedAtTs -- 3638
			} end -- 3638
		) -- 3638
		local merged = {} -- 3640
		if status == "running" then -- 3640
			merged = runningSessions -- 3642
		elseif status == "done" then -- 3642
			merged = __TS__ArrayFilter( -- 3644
				completedSessions, -- 3644
				function(____, item) return item.status == "DONE" end -- 3644
			) -- 3644
		elseif status == "failed" then -- 3644
			merged = __TS__ArrayFilter( -- 3646
				completedSessions, -- 3646
				function(____, item) return item.status == "FAILED" end -- 3646
			) -- 3646
		elseif status == "stopped" then -- 3646
			merged = __TS__ArrayFilter( -- 3648
				completedSessions, -- 3648
				function(____, item) return item.status == "STOPPED" end -- 3648
			) -- 3648
		elseif status == "all" then -- 3648
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3650
		else -- 3650
			local runningKeys = {} -- 3652
			do -- 3652
				local i = 0 -- 3653
				while i < #runningSessions do -- 3653
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3654
					i = i + 1 -- 3653
				end -- 3653
			end -- 3653
			local latestCompletedByKey = {} -- 3656
			do -- 3656
				local i = 0 -- 3657
				while i < #completedSessions do -- 3657
					do -- 3657
						local item = completedSessions[i + 1] -- 3658
						local key = getSubAgentDisplayKey(item) -- 3659
						if runningKeys[key] then -- 3659
							goto __continue673 -- 3661
						end -- 3661
						local current = latestCompletedByKey[key] -- 3663
						if current == nil or item.updatedAt > current.updatedAt then -- 3663
							latestCompletedByKey[key] = item -- 3665
						end -- 3665
					end -- 3665
					::__continue673:: -- 3665
					i = i + 1 -- 3657
				end -- 3657
			end -- 3657
			local latestCompleted = {} -- 3668
			for ____, item in pairs(latestCompletedByKey) do -- 3669
				latestCompleted[#latestCompleted + 1] = item -- 3670
			end -- 3670
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3672
		end -- 3672
		if query ~= "" then -- 3672
			merged = __TS__ArrayFilter( -- 3675
				merged, -- 3675
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3675
			) -- 3675
		end -- 3675
		__TS__ArraySort( -- 3681
			merged, -- 3681
			function(____, a, b) -- 3681
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3681
					return -1 -- 3682
				end -- 3682
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3682
					return 1 -- 3683
				end -- 3683
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3683
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3685
				end -- 3685
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3687
			end -- 3681
		) -- 3681
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3689
		return ____awaiter_resolve(nil, { -- 3689
			success = true, -- 3691
			rootSessionId = rootSession.id, -- 3692
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3693
			status = status, -- 3694
			limit = limit, -- 3695
			offset = offset, -- 3696
			hasMore = offset + limit < #merged, -- 3697
			sessions = paged -- 3698
		}) -- 3698
	end) -- 3698
end -- 3568
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
local function clearSessionAfterMessage(sessionId, message) -- 1724
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1725
	local removedStepIds = {} -- 1733
	do -- 1733
		local i = 0 -- 1734
		while i < #removedStepRows do -- 1734
			local row = removedStepRows[i + 1] -- 1735
			if type(row[1]) == "number" then -- 1735
				removedStepIds[#removedStepIds + 1] = row[1] -- 1737
			end -- 1737
			i = i + 1 -- 1734
		end -- 1734
	end -- 1734
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1740
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1748
	return removedStepIds -- 1753
end -- 1724
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1756
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1757
	local persisted = storage:readSessionState() -- 1758
	local userIndex = -1 -- 1759
	do -- 1759
		local i = #persisted.messages - 1 -- 1760
		while i >= 0 do -- 1760
			if persisted.messages[i + 1].role == "user" and persisted.messages[i + 1].inputKind ~= "steer" then -- 1760
				userIndex = i -- 1762
				break -- 1763
			end -- 1763
			i = i - 1 -- 1760
		end -- 1760
	end -- 1760
	if userIndex < 0 then -- 1760
		return -- 1766
	end -- 1766
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1767
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1768
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1769
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1774
end -- 1756
local function listCurrentTaskCheckpoints(sessionId) -- 1786
	local session = getSessionItem(sessionId) -- 1787
	local taskId = session and session.currentTaskId -- 1788
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1789
end -- 1786
local function getAgentStepCount(sessionId, taskId) -- 1896
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1897
		sessionId, -- 1902
		taskId, -- 1903
		"compress_memory", -- 1904
		"merge_memory", -- 1905
		"sub_agent_handoff", -- 1906
		"questionnaire_answer", -- 1907
		"message" -- 1908
	}) -- 1908
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1911
end -- 1896
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1914
	if status == nil then -- 1914
		status = "DONE" -- 1922
	end -- 1922
	local step = getNextStepNumber(sessionId, taskId) -- 1924
	upsertStep( -- 1925
		sessionId, -- 1925
		taskId, -- 1925
		step, -- 1925
		tool, -- 1925
		{status = status, reason = reason, params = params, result = result} -- 1925
	) -- 1925
	return getStepItem(sessionId, taskId, step) -- 1931
end -- 1914
local function sanitizeStoredSteps(sessionId) -- 1998
	DB:exec( -- 1999
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1999
		{ -- 2017
			now(), -- 2017
			sessionId -- 2017
		} -- 2017
	) -- 2017
end -- 1998
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2478
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2478
		return {success = false, message = "invalid projectRoot"} -- 2480
	end -- 2480
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2482
	for ____, row in ipairs(rows) do -- 2483
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2484
		if sessionId > 0 then -- 2484
			deleteSessionRecords(sessionId) -- 2486
		end -- 2486
	end -- 2486
	return {success = true, deleted = #rows} -- 2489
end -- 2478
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2492
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2492
		return {success = false, message = "invalid projectRoot"} -- 2494
	end -- 2494
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2496
	local renamed = 0 -- 2497
	for ____, row in ipairs(rows) do -- 2498
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2499
		local projectRoot = toStr(row[2]) -- 2500
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2501
		if sessionId > 0 and nextProjectRoot then -- 2501
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2503
			DB:exec( -- 2504
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2504
				{ -- 2506
					nextProjectRoot, -- 2506
					Path:getFilename(nextProjectRoot), -- 2506
					now(), -- 2506
					sessionId -- 2506
				} -- 2506
			) -- 2506
			renamed = renamed + 1 -- 2508
		end -- 2508
	end -- 2508
	return {success = true, renamed = renamed} -- 2511
end -- 2492
function ____exports.getSession(sessionId, view) -- 2514
	local session = getSessionItem(sessionId) -- 2515
	if not session then -- 2515
		return {success = false, message = "session not found"} -- 2517
	end -- 2517
	if not followup.activeRuns[sessionId] then -- 2517
		followup.recover(session) -- 2519
	end -- 2519
	local restored = restorePendingQuestionnaireState(session) -- 2520
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2521
	local ____opt_92 = getSessionItem(sessionId) -- 2521
	normalizedSession.pendingInputs = ____opt_92 and ____opt_92.pendingInputs -- 2522
	local relatedSessions = listRelatedSessions(sessionId) -- 2523
	sanitizeStoredSteps(sessionId) -- 2524
	local firstMessageId = 0 -- 2525
	local hasEarlierMessages = false -- 2526
	if view then -- 2526
		local limit = math.max( -- 2528
			1, -- 2528
			math.min( -- 2528
				1000, -- 2528
				math.floor(view.recentRounds) -- 2528
			) -- 2528
		) -- 2528
		local requests = queryRows(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m WHERE m.session_id = ? AND m.role = 'user'\n    AND NOT EXISTS (SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n\t\t\tORDER BY m.id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2529
		if #requests > limit then -- 2529
			firstMessageId = requests[limit][1] -- 2535
			hasEarlierMessages = true -- 2536
		end -- 2536
	end -- 2536
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2539
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2546
	local ____relatedSessions_99 = relatedSessions -- 2558
	local ____temp_98 -- 2559
	if normalizedSession.kind == "sub" then -- 2559
		____temp_98 = getSessionSpawnInfo(normalizedSession) -- 2559
	else -- 2559
		____temp_98 = nil -- 2559
	end -- 2559
	return { -- 2555
		success = true, -- 2556
		session = normalizedSession, -- 2557
		relatedSessions = ____relatedSessions_99, -- 2558
		spawnInfo = ____temp_98, -- 2559
		messages = __TS__ArrayMap( -- 2560
			messages, -- 2560
			function(____, row) return rowToMessage(row) end -- 2560
		), -- 2560
		hasEarlierMessages = hasEarlierMessages, -- 2561
		steps = __TS__ArrayMap( -- 2562
			steps, -- 2562
			function(____, row) return rowToStep(row) end -- 2562
		), -- 2562
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2563
		pendingQuestionnaire = restored.questionnaire, -- 2564
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2565
	} -- 2565
end -- 2514
function ____exports.setWorkMode(sessionId, workMode) -- 2570
	local session = getSessionItem(sessionId) -- 2571
	if not session then -- 2571
		return {success = false, message = "session not found"} -- 2572
	end -- 2572
	if session.kind ~= "main" then -- 2572
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2573
	end -- 2573
	if workMode ~= "code" and workMode ~= "plan" then -- 2573
		return {success = false, message = "invalid work mode"} -- 2574
	end -- 2574
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2575
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2575
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2577
	end -- 2577
	if getPendingQuestionnaire(sessionId) then -- 2577
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2580
	end -- 2580
	if normalizedSession.workMode ~= workMode then -- 2580
		DB:exec( -- 2583
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2583
			{ -- 2583
				workMode, -- 2583
				now(), -- 2583
				sessionId -- 2583
			} -- 2583
		) -- 2583
	end -- 2583
	local updated = getSessionItem(sessionId) -- 2585
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2586
	return { -- 2587
		success = true, -- 2587
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2587
	} -- 2587
end -- 2570
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId, llmConfig) -- 2886
	local session = getSessionItem(sessionId) -- 2887
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2887
		return {success = false, message = "project task admission is closed"} -- 2888
	end -- 2888
	if not session then -- 2888
		return {success = false, message = "session not found"} -- 2890
	end -- 2890
	if getPendingQuestionnaire(sessionId) then -- 2890
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2892
	end -- 2892
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2892
		return {success = false, message = "session task is finalizing"} -- 2894
	end -- 2894
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2894
		return {success = false, message = "session task is still stopping"} -- 2897
	end -- 2897
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2897
		return {success = false, message = "session task is not continuable"} -- 2900
	end -- 2900
	if session.currentTaskId == nil then -- 2900
		return {success = false, message = "session task not found"} -- 2903
	end -- 2903
	local resolved = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 2905
	if not resolved.success then -- 2905
		return {success = false, message = resolved.message} -- 2906
	end -- 2906
	followup.recover(session) -- 2907
	local previousBinding = followup.bindings[sessionId] -- 2908
	followup.bindings[sessionId] = {llmConfig = resolved.config, llmConfigId = llmConfigId} -- 2909
	local taskId = session.currentTaskId -- 2910
	local result = startPromptTask( -- 2911
		session, -- 2912
		"", -- 2913
		nil, -- 2914
		normalizeDisabledAgentTools(disabledAgentTools), -- 2915
		{ -- 2916
			workMode = session.workMode, -- 2917
			persistUserMessage = false, -- 2918
			resumeConversation = true, -- 2919
			existingTaskId = taskId, -- 2920
			initialStep = math.max( -- 2921
				0, -- 2921
				getNextStepNumber(session.id, taskId) - 1 -- 2921
			), -- 2921
			initialAgentStepCount = 0, -- 2925
			llmConfigId = llmConfigId, -- 2926
			llmConfig = resolved.config -- 2927
		} -- 2927
	) -- 2927
	if result.success then -- 2927
		for ____, input in ipairs(InputInbox.listInputs(sessionId)) do -- 2933
			followup.configs[input.id] = resolved.config -- 2933
		end -- 2933
		InputInbox.mutateInput(sessionId, {action = "resume"}, "") -- 2934
		followup.publish(sessionId) -- 2935
	elseif previousBinding then -- 2935
		followup.bindings[sessionId] = previousBinding -- 2936
	else -- 2936
		__TS__Delete(followup.bindings, sessionId) -- 2937
	end -- 2937
	return result -- 2938
end -- 2886
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 3111
	local session = getSessionItem(sessionId) -- 3112
	if not session then -- 3112
		return {success = false, message = "session not found"} -- 3114
	end -- 3114
	if session.kind ~= "sub" then -- 3114
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 3117
	end -- 3117
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3117
		return {success = false, message = "session task is finalizing"} -- 3120
	end -- 3120
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3122
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 3122
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 3127
	end -- 3127
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 3127
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 3130
	end -- 3130
	local disabledAgentTools = AgentToolRegistry.getAllowedToolsForRole("sub") -- 3132
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并给出最终总结。不要再调用任何工具；用纯文本如实总结已完成内容、文件变更、验证状态和剩余问题。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Use plain text only, without tools, to summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 3133
	return startPromptTask( -- 3136
		session, -- 3136
		prompt, -- 3136
		nil, -- 3136
		disabledAgentTools, -- 3136
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 3136
	) -- 3136
end -- 3111
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 3143
	local session = getSessionItem(sessionId) -- 3144
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3144
		return {success = false, message = "project task admission is closed"} -- 3145
	end -- 3145
	if not session then -- 3145
		return {success = false, message = "session not found"} -- 3147
	end -- 3147
	if #InputInbox.listInputs(sessionId) > 0 then -- 3147
		return {success = false, message = "finish or remove pending messages before editing task history"} -- 3149
	end -- 3149
	if getPendingQuestionnaire(sessionId) then -- 3149
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 3150
	end -- 3150
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3150
		return {success = false, message = "session task is finalizing"} -- 3152
	end -- 3152
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 3152
		return {success = false, message = "session task is still running"} -- 3155
	end -- 3155
	local message = getMessageItem(messageId) -- 3157
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 3157
		return {success = false, message = "message not found"} -- 3159
	end -- 3159
	local latestUserRow = queryOne(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m\n  WHERE m.session_id = ? AND m.role = ? AND NOT EXISTS (\n   SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n  ORDER BY m.id DESC LIMIT 1", {sessionId, "user"}) -- 3161
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 3168
	if latestUserMessageId ~= messageId then -- 3168
		return {success = false, message = "only the latest user prompt can be edited"} -- 3170
	end -- 3170
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 3172
	if normalizedPrompt == "" then -- 3172
		return {success = false, message = "prompt is empty"} -- 3174
	end -- 3174
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 3176
	if session.workMode ~= nextWorkMode then -- 3176
		DB:exec( -- 3178
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 3178
			{ -- 3178
				nextWorkMode, -- 3178
				now(), -- 3178
				session.id -- 3178
			} -- 3178
		) -- 3178
		session.workMode = nextWorkMode -- 3179
	end -- 3179
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 3181
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 3182
	local result = startPromptTask( -- 3183
		session, -- 3183
		normalizedPrompt, -- 3183
		messageId, -- 3183
		normalizeDisabledAgentTools(disabledAgentTools), -- 3183
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 3183
	) -- 3183
	if result.success and #removedStepIds > 0 then -- 3183
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 3185
	end -- 3185
	return result -- 3187
end -- 3143
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 3192
	if status == "dismissed" then -- 3192
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 3198
	end -- 3198
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3200
end -- 3192
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3203
	if status == "dismissed" then -- 3203
		return { -- 3209
			success = true, -- 3210
			status = "dismissed", -- 3211
			source = "user", -- 3212
			questionnaireId = questionnaire.id, -- 3213
			title = questionnaire.schema.title, -- 3214
			answers = {}, -- 3215
			responses = {}, -- 3216
			displayText = "用户关闭了调查问卷，未作答。", -- 3217
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 3218
		} -- 3218
	end -- 3218
	local responses = {} -- 3221
	do -- 3221
		local i = 0 -- 3222
		while i < #questionnaire.schema.questions do -- 3222
			do -- 3222
				local question = questionnaire.schema.questions[i + 1] -- 3223
				local answer = __TS__ArrayFind( -- 3224
					answers, -- 3224
					function(____, item) return item.questionId == question.id end -- 3224
				) -- 3224
				if not answer or answer.status == "skipped" then -- 3224
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3226
					goto __continue570 -- 3231
				end -- 3231
				local selectedOptionLabels = {} -- 3233
				do -- 3233
					local j = 0 -- 3234
					while j < #(answer.selectedOptionIds or ({})) do -- 3234
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3235
						local option = __TS__ArrayFind( -- 3236
							question.options or ({}), -- 3236
							function(____, item) return item.id == optionId end -- 3236
						) -- 3236
						if option then -- 3236
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3237
						end -- 3237
						j = j + 1 -- 3234
					end -- 3234
				end -- 3234
				responses[#responses + 1] = { -- 3239
					questionId = question.id, -- 3240
					prompt = question.prompt, -- 3241
					status = "answered", -- 3242
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3243
					selectedOptionLabels = selectedOptionLabels, -- 3244
					otherText = answer.otherText, -- 3245
					text = answer.text -- 3246
				} -- 3246
			end -- 3246
			::__continue570:: -- 3246
			i = i + 1 -- 3222
		end -- 3222
	end -- 3222
	return { -- 3249
		success = true, -- 3250
		status = "answered", -- 3251
		source = "user", -- 3252
		questionnaireId = questionnaire.id, -- 3253
		title = questionnaire.schema.title, -- 3254
		answers = answers, -- 3255
		responses = responses, -- 3256
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3257
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3258
	} -- 3258
end -- 3203
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3284
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3290
	local persisted = storage:readSessionState() -- 3291
	local messages = __TS__ArraySlice(persisted.messages) -- 3292
	local toolResultIndex = -1 -- 3293
	local existingResult -- 3294
	do -- 3294
		local i = #messages - 1 -- 3295
		while i >= 0 do -- 3295
			do -- 3295
				local message = messages[i + 1] -- 3296
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3296
					goto __continue590 -- 3297
				end -- 3297
				local decoded = safeJsonDecode(message.content) -- 3298
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3298
					goto __continue590 -- 3299
				end -- 3299
				local row = decoded -- 3300
				if row.questionnaireId ~= questionnaire.id then -- 3300
					goto __continue590 -- 3301
				end -- 3301
				toolResultIndex = i -- 3302
				existingResult = row -- 3303
				break -- 3304
			end -- 3304
			::__continue590:: -- 3304
			i = i - 1 -- 3295
		end -- 3295
	end -- 3295
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3306
	local guidance = {} -- 3307
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3307
		guidance[#guidance + 1] = existingResult.guidance -- 3309
	end -- 3309
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3309
		guidance[#guidance + 1] = result.guidance -- 3312
	end -- 3312
	result.guidance = table.concat(guidance, "\n") -- 3314
	if toolResultIndex < 0 then -- 3314
		messages[#messages + 1] = { -- 3316
			role = "user", -- 3317
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3318
		} -- 3318
		toolResultIndex = #messages - 1 -- 3320
	else -- 3320
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3322
			{}, -- 3322
			messages[toolResultIndex + 1], -- 3323
			{content = encodeJson(result)} -- 3322
		) -- 3322
	end -- 3322
	local pairStartIndex = toolResultIndex -- 3328
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3329
	if toolCallId and toolCallId ~= "" then -- 3329
		do -- 3329
			local i = toolResultIndex - 1 -- 3331
			while i >= 0 do -- 3331
				do -- 3331
					local message = messages[i + 1] -- 3332
					if message.role ~= "assistant" or not message.tool_calls then -- 3332
						goto __continue600 -- 3333
					end -- 3333
					if __TS__ArraySome( -- 3333
						message.tool_calls, -- 3334
						function(____, call) return call.id == toolCallId end -- 3334
					) then -- 3334
						pairStartIndex = i -- 3335
						break -- 3336
					end -- 3336
				end -- 3336
				::__continue600:: -- 3336
				i = i - 1 -- 3331
			end -- 3331
		end -- 3331
	end -- 3331
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3340
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3343
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3347
	upsertStep( -- 3349
		session.id, -- 3349
		questionnaire.taskId, -- 3349
		questionnaire.step, -- 3349
		"ask_user", -- 3349
		{status = "DONE", result = result} -- 3349
	) -- 3349
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3353
	upsertStep( -- 3354
		session.id, -- 3354
		questionnaire.taskId, -- 3354
		answerStep, -- 3354
		"questionnaire_answer", -- 3354
		{status = "DONE", result = result} -- 3354
	) -- 3354
	return {success = true, answerStep = answerStep, result = result} -- 3358
end -- 3284
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3361
	local session = getSessionItem(sessionId) -- 3362
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3362
		return {success = false, message = "project task admission is closed"} -- 3363
	end -- 3363
	if not session then -- 3363
		return {success = false, message = "session not found"} -- 3364
	end -- 3364
	if session.kind ~= "main" then -- 3364
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3365
	end -- 3365
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3366
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3366
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3368
	end -- 3368
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3370
	if not llmConfigRes.success then -- 3370
		return {success = false, message = llmConfigRes.message} -- 3371
	end -- 3371
	if not removePendingQuestionnaire(session) then -- 3371
		return {success = false, message = "failed to consume questionnaire file"} -- 3372
	end -- 3372
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3373
	if not replaced.success then -- 3373
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3375
		return replaced -- 3376
	end -- 3376
	local t = now() -- 3378
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3379
	session.workMode = "plan" -- 3380
	local result = startPromptTask( -- 3381
		session, -- 3381
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3381
		nil, -- 3381
		{}, -- 3381
		{ -- 3381
			workMode = "plan", -- 3382
			persistUserMessage = false, -- 3383
			resumeConversation = true, -- 3384
			existingTaskId = questionnaire.taskId, -- 3385
			initialStep = replaced.answerStep, -- 3386
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3387
			llmConfig = llmConfigRes.config -- 3388
		} -- 3388
	) -- 3388
	if not result.success then -- 3388
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3391
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3392
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3393
		emitAgentSessionPatch( -- 3394
			session.id, -- 3394
			{ -- 3394
				session = getSessionItem(session.id), -- 3395
				pendingQuestionnaire = questionnaire -- 3396
			} -- 3396
		) -- 3396
		return result -- 3398
	end -- 3398
	emitAgentSessionPatch( -- 3400
		sessionId, -- 3400
		{ -- 3400
			session = getSessionItem(sessionId), -- 3401
			pendingQuestionnaire = false -- 3402
		} -- 3402
	) -- 3402
	return result -- 3404
end -- 3361
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3407
	local session = getSessionItem(sessionId) -- 3408
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3408
		return {success = false, message = "project task admission is closed"} -- 3409
	end -- 3409
	if not session then -- 3409
		return {success = false, message = "session not found"} -- 3410
	end -- 3410
	if session.kind ~= "main" then -- 3410
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3411
	end -- 3411
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3412
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3412
		return {success = false, message = "pending questionnaire not found"} -- 3413
	end -- 3413
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3414
	if not validated.success then -- 3414
		return validated -- 3415
	end -- 3415
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3416
	if not llmConfigRes.success then -- 3416
		return {success = false, message = llmConfigRes.message} -- 3417
	end -- 3417
	local t = now() -- 3418
	if not removePendingQuestionnaire(session) then -- 3418
		return {success = false, message = "failed to consume questionnaire file"} -- 3419
	end -- 3419
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3420
	if not replaced.success then -- 3420
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3422
		return replaced -- 3423
	end -- 3423
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3425
	session.workMode = "plan" -- 3426
	local result = startPromptTask( -- 3427
		session, -- 3427
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3427
		nil, -- 3427
		{}, -- 3427
		{ -- 3427
			workMode = "plan", -- 3428
			persistUserMessage = false, -- 3429
			resumeConversation = true, -- 3430
			existingTaskId = questionnaire.taskId, -- 3431
			initialStep = replaced.answerStep, -- 3432
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3433
			llmConfig = llmConfigRes.config -- 3434
		} -- 3434
	) -- 3434
	if not result.success then -- 3434
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3437
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3438
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3439
		emitAgentSessionPatch( -- 3440
			session.id, -- 3440
			{ -- 3440
				session = getSessionItem(session.id), -- 3441
				pendingQuestionnaire = questionnaire -- 3442
			} -- 3442
		) -- 3442
		return result -- 3444
	end -- 3444
	emitAgentSessionPatch( -- 3446
		sessionId, -- 3446
		{ -- 3446
			session = getSessionItem(sessionId), -- 3447
			pendingQuestionnaire = false -- 3448
		} -- 3448
	) -- 3448
	return result -- 3450
end -- 3407
function ____exports.stopSessionTask(sessionId) -- 3453
	InputInbox.holdInputs(sessionId) -- 3454
	followup.publish(sessionId) -- 3455
	local session = getSessionItem(sessionId) -- 3456
	if not session or session.currentTaskId == nil then -- 3456
		return {success = false, message = "session task not found"} -- 3458
	end -- 3458
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3458
		return {success = false, message = "session task is finalizing"} -- 3461
	end -- 3461
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime) -- 3463
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3464
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3465
	if localControl ~= nil then -- 3465
		localControl:stop() -- 3467
		return {success = true, stopping = true} -- 3468
	end -- 3468
	local stopToken = activeStopTokens[session.currentTaskId] -- 3470
	if stopToken == nil then -- 3470
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3470
			return {success = true, recovered = true} -- 3473
		end -- 3473
		return {success = false, message = "task is not running"} -- 3475
	end -- 3475
	if stopToken.stopped then -- 3475
		return {success = true, stopping = true} -- 3478
	end -- 3478
	stopToken.stopped = true -- 3480
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3481
	return {success = true, stopping = true} -- 3485
end -- 3453
function ____exports.getCurrentTaskId(sessionId) -- 3488
	local ____opt_175 = getSessionItem(sessionId) -- 3488
	return ____opt_175 and ____opt_175.currentTaskId -- 3489
end -- 3488
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3493
	local owner = getSessionItem(sessionId) -- 3494
	if not owner then -- 3494
		return {success = false, message = "session not found"} -- 3495
	end -- 3495
	local projectRoot = owner.projectRoot -- 3496
	local release = holdProjectTaskAdmission(projectRoot) -- 3497
	local closed = false -- 3498
	return { -- 3499
		success = true, -- 3500
		projectRoot = projectRoot, -- 3501
		close = function() -- 3502
			if not closed then -- 3502
				closed = true -- 3502
				release() -- 3502
			end -- 3502
		end, -- 3502
		poll = function() -- 3503
			if closed then -- 3503
				return {success = false, message = "quiescence handle closed"} -- 3504
			end -- 3504
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3505
			if not rows then -- 3505
				return {success = false, message = "failed to inspect project tasks"} -- 3506
			end -- 3506
			local pending = {} -- 3507
			for ____, row in ipairs(rows) do -- 3508
				do -- 3508
					local session = rowToSession(row) -- 3509
					local taskId = session.currentTaskId -- 3510
					if taskId == nil then -- 3510
						goto __continue638 -- 3511
					end -- 3511
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3512
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3512
						goto __continue638 -- 3513
					end -- 3513
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3515
					local ____session_id_178 = session.id -- 3516
					local ____taskId_179 = taskId -- 3516
					local ____finalizing_180 = finalizing -- 3516
					local ____result_success_181 = result.success -- 3516
					local ____result_success_177 -- 3516
					if result.success then -- 3516
						____result_success_177 = nil -- 3516
					else -- 3516
						____result_success_177 = result.message -- 3516
					end -- 3516
					pending[#pending + 1] = { -- 3516
						sessionId = ____session_id_178, -- 3516
						taskId = ____taskId_179, -- 3516
						finalizing = ____finalizing_180, -- 3516
						stopRequested = ____result_success_181, -- 3516
						message = ____result_success_177 -- 3516
					} -- 3516
				end -- 3516
				::__continue638:: -- 3516
			end -- 3516
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3520
		end -- 3503
	} -- 3503
end -- 3493
function ____exports.validateTaskAccess(sessionId, taskId) -- 3525
	local session = getSessionItem(sessionId) -- 3526
	if not session then -- 3526
		return {success = false, message = "session not found"} -- 3527
	end -- 3527
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3527
		getSessionOperableTaskIds(sessionId), -- 3528
		taskId -- 3528
	) < 0 then -- 3528
		return {success = false, message = "task is not operable for this session"} -- 3529
	end -- 3529
	return {success = true, session = session} -- 3531
end -- 3525
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3534
	if checkpointId <= 0 then -- 3534
		return {success = false, message = "invalid checkpointId"} -- 3536
	end -- 3536
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3538
	if not checkpoint then -- 3538
		return {success = false, message = "checkpoint not found"} -- 3540
	end -- 3540
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3542
	if not taskAccess.success then -- 3542
		return taskAccess -- 3543
	end -- 3543
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3544
end -- 3534
function ____exports.listRunningSessions() -- 3547
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3548
	local sessions = {} -- 3555
	do -- 3555
		local i = 0 -- 3556
		while i < #rows do -- 3556
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3557
			if session.currentTaskStatus == "RUNNING" then -- 3557
				sessions[#sessions + 1] = session -- 3559
			end -- 3559
			i = i + 1 -- 3556
		end -- 3556
	end -- 3556
	return {success = true, sessions = sessions} -- 3562
end -- 3547
return ____exports -- 3547