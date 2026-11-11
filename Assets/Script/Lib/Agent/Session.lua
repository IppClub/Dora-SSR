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
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 1004
					goto __continue184 -- 1005
				end -- 1005
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 1005
					tools[#tools + 1] = name -- 1006
				end -- 1006
			end -- 1006
			::__continue184:: -- 1006
			i = i + 1 -- 1003
		end -- 1003
	end -- 1003
	return tools -- 1008
end -- 1008
function normalizeWorkMode(value, fallback) -- 1011
	if fallback == nil then -- 1011
		fallback = "code" -- 1011
	end -- 1011
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 1012
end -- 1012
function getSessionRow(sessionId) -- 1015
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 1016
end -- 1016
function getPendingSessionInputs(sessionId) -- 1024
	return __TS__ArrayMap( -- 1027
		__TS__ArrayFilter( -- 1027
			InputInbox.listInputs(sessionId), -- 1027
			function(____, item) return item.status ~= "delivering" end -- 1027
		), -- 1027
		function(____, item) return { -- 1028
			id = item.id, -- 1028
			content = item.content, -- 1028
			delivery = item.delivery, -- 1028
			held = item.held, -- 1028
			status = item.status -- 1028
		} end -- 1028
	) -- 1028
end -- 1028
function getSessionItem(sessionId) -- 1031
	local row = getSessionRow(sessionId) -- 1032
	if not row then -- 1032
		return nil -- 1033
	end -- 1033
	local session = rowToSession(row) -- 1034
	session.pendingInputs = getPendingSessionInputs(session.id) -- 1035
	return session -- 1036
end -- 1036
function getTaskPrompt(taskId) -- 1039
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1040
	if not row or type(row[1]) ~= "string" then -- 1040
		return nil -- 1041
	end -- 1041
	return toStr(row[1]) -- 1042
end -- 1042
function getLatestMainSessionByProjectRoot(projectRoot) -- 1045
	if not isValidProjectRoot(projectRoot) then -- 1045
		return nil -- 1046
	end -- 1046
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1047
	if not row then -- 1047
		return nil -- 1055
	end -- 1055
	local session = rowToSession(row) -- 1056
	session.pendingInputs = getPendingSessionInputs(session.id) -- 1057
	return session -- 1058
end -- 1058
function countRunningSubSessions(rootSessionId) -- 1061
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 1062
	local count = 0 -- 1069
	do -- 1069
		local i = 0 -- 1070
		while i < #rows do -- 1070
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1071
			if session.currentTaskStatus == "RUNNING" then -- 1071
				count = count + 1 -- 1073
			end -- 1073
			i = i + 1 -- 1070
		end -- 1070
	end -- 1070
	return count -- 1076
end -- 1076
function deleteSessionRecords(sessionId, preserveArtifacts) -- 1079
	if preserveArtifacts == nil then -- 1079
		preserveArtifacts = false -- 1079
	end -- 1079
	for ____, input in ipairs(InputInbox.listInputs(sessionId, true)) do -- 1080
		__TS__Delete(followup.configs, input.id) -- 1080
	end -- 1080
	DB:exec("DELETE FROM agent.AgentSessionInput WHERE session_id=?", {sessionId}) -- 1081
	__TS__Delete(followup.bindings, sessionId) -- 1082
	__TS__Delete(followup.recovered, sessionId) -- 1083
	streamUpdates:clear(sessionId) -- 1084
	local session = getSessionItem(sessionId) -- 1085
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 1086
	local taskIds = {} -- 1094
	do -- 1094
		local i = 0 -- 1095
		while i < #taskRows do -- 1095
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 1096
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 1096
				taskIds[#taskIds + 1] = taskId -- 1098
				local stopToken = activeStopTokens[taskId] -- 1099
				if stopToken ~= nil then -- 1099
					stopToken.stopped = true -- 1101
					stopToken.reason = "session deleted" -- 1102
				end -- 1102
			end -- 1102
			i = i + 1 -- 1095
		end -- 1095
	end -- 1095
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 1106
	do -- 1106
		local i = 0 -- 1107
		while i < #children do -- 1107
			local row = children[i + 1] -- 1108
			if type(row[1]) == "number" and row[1] > 0 then -- 1108
				deleteSessionRecords(row[1], preserveArtifacts) -- 1110
			end -- 1110
			i = i + 1 -- 1107
		end -- 1107
	end -- 1107
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 1113
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 1114
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 1115
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 1116
	if session and session.kind == "main" then -- 1116
		removePendingQuestionnaire(session) -- 1118
	end -- 1118
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 1118
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 1118
			Tools.sendWebIDERefreshTree() -- 1122
		end -- 1122
	end -- 1122
	do -- 1122
		local i = 0 -- 1125
		while i < #taskIds do -- 1125
			cleanupTaskHeavyData(taskIds[i + 1]) -- 1126
			i = i + 1 -- 1125
		end -- 1125
	end -- 1125
end -- 1125
function getSessionRootId(session) -- 1130
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 1131
end -- 1131
function getRootSessionItem(sessionId) -- 1134
	local session = getSessionItem(sessionId) -- 1135
	if not session then -- 1135
		return nil -- 1136
	end -- 1136
	return getSessionItem(getSessionRootId(session)) or session -- 1137
end -- 1137
function listRelatedSessions(sessionId) -- 1140
	local root = getRootSessionItem(sessionId) -- 1141
	if not root then -- 1141
		return {} -- 1142
	end -- 1142
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 1143
	return __TS__ArrayMap( -- 1152
		rows, -- 1152
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 1152
	) -- 1152
end -- 1152
function getSessionSpawnInfo(session) -- 1155
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1156
	if not info then -- 1156
		return nil -- 1157
	end -- 1157
	local ____temp_47 = type(info.sessionId) == "number" and info.sessionId or nil -- 1159
	local ____temp_48 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 1160
	local ____temp_49 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 1161
	local ____temp_50 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 1162
	local ____temp_51 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 1163
	local ____temp_52 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 1164
	local ____temp_53 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 1165
	local ____temp_54 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1166
		__TS__ArrayFilter( -- 1167
			info.filesHint, -- 1167
			function(____, item) return type(item) == "string" end -- 1167
		), -- 1167
		function(____, item) return sanitizeUTF8(item) end -- 1167
	) or nil -- 1167
	local ____temp_55 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 1169
	local ____temp_45 -- 1172
	if info.success == true then -- 1172
		____temp_45 = true -- 1172
	else -- 1172
		local ____temp_44 -- 1172
		if info.success == false then -- 1172
			____temp_44 = false -- 1172
		else -- 1172
			____temp_44 = nil -- 1172
		end -- 1172
		____temp_45 = ____temp_44 -- 1172
	end -- 1172
	local ____temp_46 -- 1173
	if info.cleared == true then -- 1173
		____temp_46 = true -- 1173
	else -- 1173
		____temp_46 = nil -- 1173
	end -- 1173
	return { -- 1158
		sessionId = ____temp_47, -- 1159
		rootSessionId = ____temp_48, -- 1160
		parentSessionId = ____temp_49, -- 1161
		title = ____temp_50, -- 1162
		prompt = ____temp_51, -- 1163
		goal = ____temp_52, -- 1164
		expectedOutput = ____temp_53, -- 1165
		filesHint = ____temp_54, -- 1166
		status = ____temp_55, -- 1169
		success = ____temp_45, -- 1172
		cleared = ____temp_46, -- 1173
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 1174
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 1175
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 1176
		changeSet = decodeChangeSetSummary(info.changeSet), -- 1177
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1178
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1179
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 1180
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 1181
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 1184
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 1185
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 1186
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 1187
	} -- 1187
end -- 1187
function ensureDirRecursive(dir) -- 1204
	if dir == "" then -- 1204
		return false -- 1205
	end -- 1205
	if Content:exist(dir) then -- 1205
		return Content:isdir(dir) -- 1206
	end -- 1206
	local parent = Path:getPath(dir) -- 1207
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1207
		if not ensureDirRecursive(parent) then -- 1207
			return false -- 1210
		end -- 1210
	end -- 1210
	return Content:mkdir(dir) -- 1213
end -- 1213
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1216
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1217
	if not Content:exist(dir) then -- 1217
		ensureDirRecursive(dir) -- 1219
	end -- 1219
	local path = Path(dir, SPAWN_INFO_FILE) -- 1221
	local text = safeJsonEncode(value) -- 1222
	if not text then -- 1222
		return false -- 1223
	end -- 1223
	local content = text .. "\n" -- 1224
	if not Content:save(path, content) then -- 1224
		return false -- 1226
	end -- 1226
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1228
	return true -- 1229
end -- 1229
function readSpawnInfo(projectRoot, memoryScope) -- 1232
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1233
	if not Content:exist(path) then -- 1233
		return nil -- 1234
	end -- 1234
	local text = Content:load(path) -- 1235
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1235
		return nil -- 1236
	end -- 1236
	local value = safeJsonDecode(text) -- 1237
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1237
		return value -- 1239
	end -- 1239
	return nil -- 1241
end -- 1241
function getArtifactRelativeDir(memoryScope) -- 1244
	return Path(".agent", memoryScope) -- 1245
end -- 1245
function getArtifactDir(projectRoot, memoryScope) -- 1248
	return Path( -- 1249
		projectRoot, -- 1249
		getArtifactRelativeDir(memoryScope) -- 1249
	) -- 1249
end -- 1249
function getResultRelativePath(memoryScope) -- 1252
	return Path( -- 1253
		getArtifactRelativeDir(memoryScope), -- 1253
		RESULT_FILE -- 1253
	) -- 1253
end -- 1253
function getResultPath(projectRoot, memoryScope) -- 1256
	return Path( -- 1257
		projectRoot, -- 1257
		getResultRelativePath(memoryScope) -- 1257
	) -- 1257
end -- 1257
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1260
	if resultFilePath == "" then -- 1260
		return "" -- 1261
	end -- 1261
	local path = Path(projectRoot, resultFilePath) -- 1262
	if not Content:exist(path) then -- 1262
		return "" -- 1263
	end -- 1263
	local text = sanitizeUTF8(Content:load(path)) -- 1264
	if __TS__StringTrim(text) == "" then -- 1264
		return "" -- 1265
	end -- 1265
	local marker = "\n## Summary\n" -- 1266
	local start = string.find(text, marker, 1, true) -- 1267
	if start ~= nil then -- 1267
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1269
	end -- 1269
	return __TS__StringTrim(text) -- 1271
end -- 1271
function buildStructuredSubAgentMemoryEntry(record) -- 1274
	local hasPassedValidation = false -- 1275
	do -- 1275
		local i = 0 -- 1276
		while i < #record.completion.validation do -- 1276
			local result = record.completion.validation[i + 1].result -- 1277
			if result == "failed" then -- 1277
				return nil -- 1282
			end -- 1282
			if result == "passed" then -- 1282
				hasPassedValidation = true -- 1284
			end -- 1284
			i = i + 1 -- 1276
		end -- 1276
	end -- 1276
	if not hasPassedValidation then -- 1276
		return nil -- 1287
	end -- 1287
	local candidates = record.completion.learningCandidates -- 1288
	local claims = {} -- 1289
	local evidence = {} -- 1290
	do -- 1290
		local i = 0 -- 1291
		while i < #candidates do -- 1291
			do -- 1291
				local candidate = candidates[i + 1] -- 1292
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1292
					goto __continue262 -- 1293
				end -- 1293
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1294
				do -- 1294
					local j = 0 -- 1295
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1295
						local item = candidate.evidence[j + 1] -- 1296
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1296
							evidence[#evidence + 1] = item -- 1297
						end -- 1297
						j = j + 1 -- 1295
					end -- 1295
				end -- 1295
			end -- 1295
			::__continue262:: -- 1295
			i = i + 1 -- 1291
		end -- 1291
	end -- 1291
	local content = takeUtf8Head( -- 1300
		table.concat(claims, "\n"), -- 1300
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1300
	) -- 1300
	if content == "" then -- 1300
		return nil -- 1301
	end -- 1301
	return { -- 1302
		sourceSessionId = record.sessionId, -- 1303
		sourceTaskId = record.sourceTaskId, -- 1304
		content = content, -- 1305
		evidence = evidence, -- 1306
		createdAt = record.finishedAt -- 1307
	} -- 1307
end -- 1307
function containsNormalizedText(text, query) -- 1311
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1312
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1313
	if normalizedQuery == "" then -- 1313
		return true -- 1314
	end -- 1314
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1315
end -- 1315
function getSubAgentDisplayKey(item) -- 1318
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1324
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1325
	local label = goal ~= "" and goal or title -- 1326
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1327
end -- 1327
function writeSubAgentResultFile(session, record, resultText) -- 1330
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1331
	if not Content:exist(dir) then -- 1331
		ensureDirRecursive(dir) -- 1333
	end -- 1333
	local ____array_64 = __TS__SparseArrayNew( -- 1333
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1336
		"- Status: " .. record.status, -- 1337
		"- Success: " .. (record.success and "true" or "false"), -- 1338
		"- Outcome: " .. record.completion.outcome, -- 1339
		"- Session ID: " .. tostring(record.sessionId), -- 1340
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1341
		"- Goal: " .. record.goal, -- 1342
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1343
	) -- 1343
	__TS__SparseArrayPush( -- 1343
		____array_64, -- 1343
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1344
	) -- 1344
	__TS__SparseArrayPush( -- 1344
		____array_64, -- 1344
		"- Finished At: " .. record.finishedAt, -- 1345
		"", -- 1346
		"## Validation", -- 1347
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1348
			record.completion.validation, -- 1349
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1349
		) or ({"- Not reported"})) -- 1349
	) -- 1349
	__TS__SparseArrayPush(____array_64, "", "## Recorded Evidence") -- 1349
	local ____opt_56 = record.handoffEvidence -- 1349
	__TS__SparseArrayPush( -- 1349
		____array_64, -- 1349
		table.unpack(____opt_56 and #____opt_56.modifiedFiles and __TS__ArrayMap( -- 1353
			record.handoffEvidence.modifiedFiles, -- 1354
			function(____, item) return "- modified: " .. item end -- 1354
		) or ({"- modified: none recorded"})) -- 1354
	) -- 1354
	local ____opt_58 = record.handoffEvidence -- 1354
	__TS__SparseArrayPush( -- 1354
		____array_64, -- 1354
		table.unpack(____opt_58 and ____opt_58.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1356
	) -- 1356
	local ____opt_60 = record.handoffEvidence -- 1356
	__TS__SparseArrayPush( -- 1356
		____array_64, -- 1356
		table.unpack(__TS__ArrayMap( -- 1359
			____opt_60 and ____opt_60.commands or ({}), -- 1359
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1359
		)) -- 1359
	) -- 1359
	local ____opt_62 = record.handoffEvidence -- 1359
	__TS__SparseArrayPush( -- 1359
		____array_64, -- 1359
		table.unpack(__TS__ArrayMap( -- 1360
			____opt_62 and ____opt_62.authoritativeSources or ({}), -- 1360
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1360
		)) -- 1360
	) -- 1360
	__TS__SparseArrayPush( -- 1360
		____array_64, -- 1360
		"", -- 1361
		"## Known Issues", -- 1362
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1363
			record.completion.knownIssues, -- 1363
			function(____, item) return "- " .. item end -- 1363
		) or ({"- None reported"})) -- 1363
	) -- 1363
	__TS__SparseArrayPush( -- 1363
		____array_64, -- 1363
		"", -- 1364
		"## Assumptions", -- 1365
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1366
			record.completion.assumptions, -- 1366
			function(____, item) return "- " .. item end -- 1366
		) or ({"- None reported"})) -- 1366
	) -- 1366
	__TS__SparseArrayPush(____array_64, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1366
	local lines = {__TS__SparseArraySpread(____array_64)} -- 1335
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1371
	local content = table.concat(lines, "\n") .. "\n" -- 1372
	if not Content:save(path, content) then -- 1372
		return false -- 1374
	end -- 1374
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1376
	return true -- 1377
end -- 1377
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1380
	local dir = Path(projectRoot, ".agent", "subagents") -- 1381
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1381
		return {} -- 1382
	end -- 1382
	local items = {} -- 1383
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1384
		do -- 1384
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1385
			if not Content:exist(path) or not Content:isdir(path) then -- 1385
				goto __continue282 -- 1386
			end -- 1386
			local info = readSpawnInfo( -- 1387
				projectRoot, -- 1387
				Path( -- 1387
					"subagents", -- 1387
					Path:getFilename(path) -- 1387
				) -- 1387
			) -- 1387
			if not info then -- 1387
				goto __continue282 -- 1388
			end -- 1388
			local sessionId = tonumber(info.sessionId) -- 1389
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1390
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1391
			local status = sanitizeUTF8(toStr(info.status)) -- 1392
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1392
				goto __continue282 -- 1393
			end -- 1393
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1393
				goto __continue282 -- 1394
			end -- 1394
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1395
			items[#items + 1] = { -- 1396
				sessionId = sessionId, -- 1397
				rootSessionId = infoRootSessionId, -- 1398
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1399
				title = sanitizeUTF8(toStr(info.title)), -- 1400
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1401
				goal = sanitizeUTF8(toStr(info.goal)), -- 1402
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1403
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1404
					__TS__ArrayFilter( -- 1405
						info.filesHint, -- 1405
						function(____, item) return type(item) == "string" end -- 1405
					), -- 1405
					function(____, item) return sanitizeUTF8(item) end -- 1405
				) or ({}), -- 1405
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1407
				success = info.success == true, -- 1408
				cleared = info.cleared == true, -- 1409
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1410
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1411
					"subagents", -- 1411
					Path:getFilename(path) -- 1411
				)), -- 1411
				sourceTaskId = sourceTaskId or 0, -- 1412
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1413
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1414
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1415
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1416
				completion = normalizeAgentCompletionReport(info.completion), -- 1417
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1418
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1419
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1420
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1421
			} -- 1421
		end -- 1421
		::__continue282:: -- 1421
	end -- 1421
	__TS__ArraySort( -- 1424
		items, -- 1424
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1424
	) -- 1424
	return items -- 1425
end -- 1425
function getPendingHandoffDir(projectRoot, memoryScope) -- 1428
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1429
end -- 1429
function writePendingHandoff(projectRoot, memoryScope, value) -- 1432
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1433
	if not Content:exist(dir) then -- 1433
		ensureDirRecursive(dir) -- 1435
	end -- 1435
	local path = Path(dir, value.id .. ".json") -- 1437
	local text = safeJsonEncode(value) -- 1438
	if not text then -- 1438
		return false -- 1439
	end -- 1439
	local content = text .. "\n" -- 1440
	if not Content:save(path, content) then -- 1440
		return false -- 1441
	end -- 1441
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1442
	return true -- 1443
end -- 1443
function listPendingHandoffs(projectRoot, memoryScope) -- 1446
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1447
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1447
		return {} -- 1448
	end -- 1448
	local items = {} -- 1449
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1450
		do -- 1450
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1451
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1451
				goto __continue298 -- 1452
			end -- 1452
			local text = Content:load(path) -- 1453
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1453
				goto __continue298 -- 1454
			end -- 1454
			local obj = safeJsonDecode(text) -- 1455
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1455
				goto __continue298 -- 1456
			end -- 1456
			local value = obj -- 1457
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1458
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1459
			local id = sanitizeUTF8(toStr(value.id)) -- 1460
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1461
			local message = sanitizeUTF8(toStr(value.message)) -- 1462
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1463
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1464
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1465
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1465
				goto __continue298 -- 1467
			end -- 1467
			items[#items + 1] = { -- 1469
				id = id, -- 1470
				sourceSessionId = sourceSessionId, -- 1471
				sourceTitle = sourceTitle, -- 1472
				sourceTaskId = sourceTaskId, -- 1473
				message = message, -- 1474
				prompt = prompt, -- 1475
				goal = goal, -- 1476
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1477
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1478
					__TS__ArrayFilter( -- 1479
						value.filesHint, -- 1479
						function(____, item) return type(item) == "string" end -- 1479
					), -- 1479
					function(____, item) return sanitizeUTF8(item) end -- 1479
				) or ({}), -- 1479
				success = value.success == true, -- 1481
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1482
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1483
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1484
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1485
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1486
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1487
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1488
				createdAt = createdAt -- 1491
			} -- 1491
		end -- 1491
		::__continue298:: -- 1491
	end -- 1491
	__TS__ArraySort( -- 1494
		items, -- 1494
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1494
	) -- 1494
	return items -- 1495
end -- 1495
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1498
	local path = Path( -- 1499
		getPendingHandoffDir(projectRoot, memoryScope), -- 1499
		id .. ".json" -- 1499
	) -- 1499
	if Content:exist(path) then -- 1499
		if Content:remove(path) then -- 1499
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1502
		end -- 1502
	end -- 1502
end -- 1502
function normalizePromptText(prompt) -- 1507
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1508
end -- 1508
function normalizePromptTextSafe(prompt) -- 1511
	if type(prompt) == "string" then -- 1511
		local normalized = normalizePromptText(prompt) -- 1513
		if normalized ~= "" then -- 1513
			return normalized -- 1514
		end -- 1514
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1515
		if sanitized ~= "" then -- 1515
			return truncateAgentUserPrompt(sanitized) -- 1517
		end -- 1517
		return "" -- 1519
	end -- 1519
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1521
	if text == "" then -- 1521
		return "" -- 1522
	end -- 1522
	return truncateAgentUserPrompt(text) -- 1523
end -- 1523
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1526
	local sections = {} -- 1527
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1528
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1529
	local normalizedFiles = __TS__ArrayFilter( -- 1530
		__TS__ArrayMap( -- 1530
			__TS__ArrayFilter( -- 1530
				filesHint or ({}), -- 1530
				function(____, item) return type(item) == "string" end -- 1531
			), -- 1531
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1532
		), -- 1532
		function(____, item) return item ~= "" end -- 1533
	) -- 1533
	if normalizedTitle ~= "" then -- 1533
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1535
	end -- 1535
	if normalizedExpected ~= "" then -- 1535
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1538
	end -- 1538
	if #normalizedFiles > 0 then -- 1538
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1541
	end -- 1541
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1543
end -- 1543
function normalizeSessionRuntimeState(session) -- 1546
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1546
		return session -- 1548
	end -- 1548
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1548
		return session -- 1551
	end -- 1551
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1551
		return session -- 1554
	end -- 1554
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1556
		session.id, -- 1559
		session.currentTaskId, -- 1559
		"fetch_url", -- 1559
		"execute_command", -- 1559
		"analyze_image" -- 1559
	}) or ({}) -- 1559
	if #pendingToolRows > 0 then -- 1559
		local t = now() -- 1562
		do -- 1562
			local i = 0 -- 1563
			while i < #pendingToolRows do -- 1563
				local row = pendingToolRows[i + 1] -- 1564
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1565
				result.success = false -- 1566
				result.state = "failed" -- 1567
				result.interrupted = true -- 1568
				result.message = "tool call was interrupted because the program exited before it completed." -- 1569
				DB:exec( -- 1570
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1570
					{ -- 1572
						encodeJson(result), -- 1572
						t, -- 1572
						row[1] -- 1572
					} -- 1572
				) -- 1572
				i = i + 1 -- 1563
			end -- 1563
		end -- 1563
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1575
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1576
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1577
	end -- 1577
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1584
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1585
	return __TS__ObjectAssign( -- 1586
		{}, -- 1586
		session, -- 1587
		{ -- 1586
			status = "STOPPED", -- 1588
			currentTaskStatus = "STOPPED", -- 1589
			updatedAt = now() -- 1590
		} -- 1590
	) -- 1590
end -- 1590
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1594
	DB:exec( -- 1595
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1595
		{ -- 1599
			status, -- 1600
			currentTaskId or 0, -- 1601
			currentTaskStatus or status, -- 1602
			now(), -- 1603
			sessionId -- 1604
		} -- 1604
	) -- 1604
end -- 1604
function mergeAgentMetrics(current, next) -- 1609
	return __TS__ObjectAssign({}, current or ({}), next) -- 1610
end -- 1610
function updateSessionMetrics(sessionId, metrics) -- 1616
	local session = getSessionItem(sessionId) -- 1617
	if not session then -- 1617
		return nil -- 1618
	end -- 1618
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1619
	DB:exec( -- 1620
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1620
		{ -- 1624
			encodeJson(merged), -- 1625
			now(), -- 1626
			sessionId -- 1627
		} -- 1627
	) -- 1627
	return merged -- 1630
end -- 1630
function clearSessionTokenUsage(sessionId) -- 1633
	local session = getSessionItem(sessionId) -- 1634
	if not session then -- 1634
		return nil -- 1635
	end -- 1635
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1636
	__TS__Delete(metrics, "usage") -- 1637
	__TS__Delete(metrics, "visionUsage") -- 1638
	DB:exec( -- 1639
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1639
		{ -- 1643
			encodeJson(metrics), -- 1644
			now(), -- 1645
			sessionId -- 1646
		} -- 1646
	) -- 1646
	return metrics -- 1649
end -- 1649
function getInitialTokenUsage(session) -- 1652
	local ____opt_65 = session.metrics -- 1652
	local usage = ____opt_65 and ____opt_65.usage -- 1653
	if not usage or (usage.requestCount or 0) <= 0 then -- 1653
		return nil -- 1654
	end -- 1654
	return { -- 1655
		inputTokens = usage.inputTokens or 0, -- 1656
		outputTokens = usage.outputTokens or 0, -- 1657
		totalTokens = usage.totalTokens, -- 1658
		cachedInputTokens = usage.cachedInputTokens, -- 1659
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1660
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1661
		requestCount = usage.requestCount or 0, -- 1662
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1663
		model = usage.model or "", -- 1664
		phase = usage.phase or "", -- 1665
		step = usage.step or 0, -- 1666
		updatedAt = usage.updatedAt or now() -- 1667
	} -- 1667
end -- 1667
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1671
	if taskId == nil or taskId <= 0 then -- 1671
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1673
		return -- 1674
	end -- 1674
	local row = getSessionRow(sessionId) -- 1676
	if not row then -- 1676
		return -- 1677
	end -- 1677
	local session = rowToSession(row) -- 1678
	if session.currentTaskId ~= taskId then -- 1678
		Log( -- 1680
			"Info", -- 1680
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1680
		) -- 1680
		return -- 1681
	end -- 1681
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1683
end -- 1683
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1686
	local t = now() -- 1687
	DB:exec( -- 1688
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1688
		{ -- 1691
			sessionId, -- 1692
			taskId or 0, -- 1693
			role, -- 1694
			sanitizeUTF8(content), -- 1695
			displayContent and sanitizeUTF8(displayContent) or "", -- 1696
			t, -- 1697
			t -- 1698
		} -- 1698
	) -- 1698
	return getLastInsertRowId() -- 1701
end -- 1701
function updateMessage(messageId, content) -- 1704
	DB:exec( -- 1705
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1705
		{ -- 1707
			sanitizeUTF8(content), -- 1707
			now(), -- 1707
			messageId -- 1707
		} -- 1707
	) -- 1707
end -- 1707
function updateUserMessageForTask(messageId, content, taskId) -- 1711
	DB:exec( -- 1712
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1712
		{ -- 1716
			sanitizeUTF8(content), -- 1716
			taskId, -- 1716
			now(), -- 1716
			messageId -- 1716
		} -- 1716
	) -- 1716
end -- 1716
function removeContinuableTaskSummary(session) -- 1773
	local taskId = session.currentTaskId -- 1774
	if taskId == nil then -- 1774
		return -- 1775
	end -- 1775
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1776
end -- 1776
function upsertAssistantMessage(sessionId, taskId, content) -- 1788
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1789
	if row and type(row[1]) == "number" then -- 1789
		updateMessage(row[1], content) -- 1796
		return row[1] -- 1797
	end -- 1797
	return insertMessage(sessionId, "assistant", content, taskId) -- 1799
end -- 1799
function upsertStep(sessionId, taskId, step, tool, patch) -- 1802
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1812
	local reason = sanitizeUTF8(patch.reason or "") -- 1816
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1817
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1818
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1819
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1820
	local statusPatch = patch.status or "" -- 1821
	local status = patch.status or "PENDING" -- 1822
	if not row then -- 1822
		local t = now() -- 1824
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1825
			sessionId, -- 1829
			taskId, -- 1830
			step, -- 1831
			tool, -- 1832
			status, -- 1833
			reason, -- 1834
			reasoningContent, -- 1835
			paramsJson, -- 1836
			resultJson, -- 1837
			patch.checkpointId or 0, -- 1838
			patch.checkpointSeq or 0, -- 1839
			filesJson, -- 1840
			t, -- 1841
			t -- 1842
		}) -- 1842
		return -- 1845
	end -- 1845
	DB:exec( -- 1847
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1847
		{ -- 1859
			tool, -- 1860
			statusPatch, -- 1861
			status, -- 1862
			reason, -- 1863
			reason, -- 1864
			reasoningContent, -- 1865
			reasoningContent, -- 1866
			paramsJson, -- 1867
			paramsJson, -- 1868
			resultJson, -- 1869
			resultJson, -- 1870
			patch.checkpointId or 0, -- 1871
			patch.checkpointId or 0, -- 1872
			patch.checkpointSeq or 0, -- 1873
			patch.checkpointSeq or 0, -- 1874
			filesJson, -- 1875
			filesJson, -- 1876
			now(), -- 1877
			row[1] -- 1878
		} -- 1878
	) -- 1878
end -- 1878
function getNextStepNumber(sessionId, taskId) -- 1883
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1884
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1888
	return math.max(0, current) + 1 -- 1889
end -- 1889
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1930
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1938
	local t = now() -- 1939
	local sqls = { -- 1940
		{ -- 1941
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1941
			{{ -- 1944
				sessionId, -- 1945
				ownerTaskId, -- 1946
				step, -- 1947
				"sub_agent_handoff", -- 1948
				"DONE", -- 1949
				sanitizeUTF8(reason), -- 1950
				encodeJson(params), -- 1951
				encodeJson(result), -- 1952
				t, -- 1953
				t -- 1954
			}} -- 1954
		}, -- 1954
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1957
	} -- 1957
	if not DB:transaction(sqls) then -- 1957
		return nil -- 1963
	end -- 1963
	return getStepItem(sessionId, ownerTaskId, step) -- 1964
end -- 1964
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1967
	if taskId <= 0 then -- 1967
		return -- 1968
	end -- 1968
	if finalSteps ~= nil and finalSteps >= 0 then -- 1968
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1970
	end -- 1970
	if not finalStatus then -- 1970
		return -- 1976
	end -- 1976
	if finalSteps ~= nil and finalSteps >= 0 then -- 1976
		DB:exec( -- 1978
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 1978
			{ -- 1982
				finalStatus, -- 1982
				now(), -- 1982
				sessionId, -- 1982
				taskId, -- 1982
				finalSteps -- 1982
			} -- 1982
		) -- 1982
		return -- 1984
	end -- 1984
	DB:exec( -- 1986
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 1986
		{ -- 1990
			finalStatus, -- 1990
			now(), -- 1990
			sessionId, -- 1990
			taskId -- 1990
		} -- 1990
	) -- 1990
end -- 1990
function emitAgentSessionPatch(sessionId, patch) -- 2017
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 2018
	if not text then -- 2018
		return -- 2023
	end -- 2023
	local failed = publishSessionPatch(sessionId, text) -- 2024
	if failed > 0 then -- 2024
		Log( -- 2025
			"Warn", -- 2025
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 2025
		) -- 2025
	end -- 2025
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 2025
		emit("AppWS", "Send", text) -- 2026
	end -- 2026
end -- 2026
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 2029
	emitAgentSessionPatch( -- 2030
		sessionId, -- 2030
		{ -- 2030
			sessionDeleted = true, -- 2031
			relatedSessions = listRelatedSessions(rootSessionId) -- 2032
		} -- 2032
	) -- 2032
	local rootSession = getSessionItem(rootSessionId) -- 2034
	if rootSession then -- 2034
		emitAgentSessionPatch( -- 2036
			rootSessionId, -- 2036
			{ -- 2036
				session = rootSession, -- 2037
				relatedSessions = listRelatedSessions(rootSessionId) -- 2038
			} -- 2038
		) -- 2038
	end -- 2038
end -- 2038
function flushPendingSubAgentHandoffs(rootSession) -- 2043
	if rootSession.kind ~= "main" then -- 2043
		return -- 2044
	end -- 2044
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 2044
		return -- 2046
	end -- 2046
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 2048
	if #items == 0 then -- 2048
		return -- 2049
	end -- 2049
	local handoffTaskId = 0 -- 2050
	local previousTaskId = rootSession.currentTaskId -- 2051
	local ____rootSession_currentTaskId_69 -- 2052
	if rootSession.currentTaskId then -- 2052
		____rootSession_currentTaskId_69 = getTaskPrompt(rootSession.currentTaskId) -- 2052
	else -- 2052
		____rootSession_currentTaskId_69 = nil -- 2052
	end -- 2052
	local currentTaskPrompt = ____rootSession_currentTaskId_69 -- 2052
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 2052
		handoffTaskId = rootSession.currentTaskId -- 2060
	else -- 2060
		local taskRes = Tools.createTask( -- 2062
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 2062
			"code" -- 2062
		) -- 2062
		if not taskRes.success then -- 2062
			Log( -- 2064
				"Warn", -- 2064
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 2064
			) -- 2064
			return -- 2065
		end -- 2065
		handoffTaskId = taskRes.taskId -- 2067
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 2068
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 2069
		emitAgentSessionPatch( -- 2070
			rootSession.id, -- 2070
			{session = getSessionItem(rootSession.id)} -- 2070
		) -- 2070
	end -- 2070
	do -- 2070
		local i = 0 -- 2074
		while i < #items do -- 2074
			local item = items[i + 1] -- 2075
			local step = appendHandoffSystemStep( -- 2076
				rootSession.id, -- 2077
				handoffTaskId, -- 2078
				item.sourceTaskId, -- 2079
				item.message, -- 2080
				{ -- 2081
					sourceSessionId = item.sourceSessionId, -- 2082
					sourceTitle = item.sourceTitle, -- 2083
					sourceTaskId = item.sourceTaskId, -- 2084
					success = item.success == true, -- 2085
					summary = item.message, -- 2086
					resultFilePath = item.resultFilePath or "", -- 2087
					artifactDir = item.artifactDir or "", -- 2088
					finishedAt = item.finishedAt or "", -- 2089
					changeSet = item.changeSet, -- 2090
					handoffEvidence = item.handoffEvidence, -- 2091
					memoryEntry = item.memoryEntry, -- 2092
					completion = item.completion -- 2093
				}, -- 2093
				{ -- 2095
					sourceSessionId = item.sourceSessionId, -- 2096
					sourceTitle = item.sourceTitle, -- 2097
					sourceTaskId = item.sourceTaskId, -- 2098
					prompt = item.prompt, -- 2099
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 2100
					expectedOutput = item.expectedOutput or "", -- 2101
					filesHint = item.filesHint or ({}), -- 2102
					resultFilePath = item.resultFilePath or "", -- 2103
					artifactDir = item.artifactDir or "", -- 2104
					changeSet = item.changeSet, -- 2105
					handoffEvidence = item.handoffEvidence, -- 2106
					memoryEntry = item.memoryEntry, -- 2107
					completion = item.completion -- 2108
				} -- 2108
			) -- 2108
			if step then -- 2108
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 2112
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 2113
			else -- 2113
				Log( -- 2115
					"Warn", -- 2115
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 2115
				) -- 2115
			end -- 2115
			i = i + 1 -- 2074
		end -- 2074
	end -- 2074
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 2074
		cleanupTaskHeavyData(previousTaskId) -- 2119
	end -- 2119
end -- 2119
function applyEvent(sessionId, event) -- 2131
	if not getSessionItem(sessionId) then -- 2131
		streamUpdates:clear(sessionId) -- 2133
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 2133
			__TS__Delete(activeStopTokens, event.taskId) -- 2135
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 2136
		end -- 2136
		return -- 2138
	end -- 2138
	repeat -- 2138
		local ____switch393 = event.type -- 2138
		local metrics, startedSession -- 2138
		local ____cond393 = ____switch393 == "task_started" -- 2138
		if ____cond393 then -- 2138
			streamUpdates:clear(sessionId) -- 2142
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 2143
			local ____event_resumed_72 -- 2144
			if event.resumed then -- 2144
				local ____opt_70 = getSessionItem(sessionId) -- 2144
				____event_resumed_72 = ____opt_70 and ____opt_70.metrics -- 2145
			else -- 2145
				____event_resumed_72 = clearSessionTokenUsage(sessionId) -- 2146
			end -- 2146
			metrics = ____event_resumed_72 -- 2144
			startedSession = getSessionItem(sessionId) -- 2147
			emitAgentSessionPatch( -- 2148
				sessionId, -- 2148
				{ -- 2148
					session = startedSession, -- 2149
					metrics = metrics, -- 2150
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2151
				} -- 2151
			) -- 2151
			break -- 2155
		end -- 2155
		____cond393 = ____cond393 or ____switch393 == "decision_made" -- 2155
		if ____cond393 then -- 2155
			upsertStep( -- 2157
				sessionId, -- 2157
				event.taskId, -- 2157
				event.step, -- 2157
				event.tool, -- 2157
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 2157
			) -- 2157
			emitAgentSessionPatch( -- 2165
				sessionId, -- 2165
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2165
			) -- 2165
			break -- 2168
		end -- 2168
		____cond393 = ____cond393 or ____switch393 == "tool_started" -- 2168
		if ____cond393 then -- 2168
			upsertStep( -- 2170
				sessionId, -- 2170
				event.taskId, -- 2170
				event.step, -- 2170
				event.tool, -- 2170
				{status = "RUNNING"} -- 2170
			) -- 2170
			emitAgentSessionPatch( -- 2173
				sessionId, -- 2173
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2173
			) -- 2173
			break -- 2176
		end -- 2176
		____cond393 = ____cond393 or ____switch393 == "tool_finished" -- 2176
		if ____cond393 then -- 2176
			do -- 2176
				upsertStep( -- 2178
					sessionId, -- 2178
					event.taskId, -- 2178
					event.step, -- 2178
					event.tool, -- 2178
					{status = event.execution.status, reason = event.reason, result = event.result} -- 2178
				) -- 2178
				emitAgentSessionPatch( -- 2186
					sessionId, -- 2186
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2186
				) -- 2186
				break -- 2189
			end -- 2189
		end -- 2189
		____cond393 = ____cond393 or ____switch393 == "tool_progress" -- 2189
		if ____cond393 then -- 2189
			do -- 2189
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 2193
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 2193
					break -- 2195
				end -- 2195
			end -- 2195
			upsertStep( -- 2198
				sessionId, -- 2198
				event.taskId, -- 2198
				event.step, -- 2198
				event.tool, -- 2198
				{status = "RUNNING", result = event.result} -- 2198
			) -- 2198
			emitAgentSessionPatch( -- 2202
				sessionId, -- 2202
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2202
			) -- 2202
			break -- 2205
		end -- 2205
		____cond393 = ____cond393 or ____switch393 == "checkpoint_created" -- 2205
		if ____cond393 then -- 2205
			upsertStep( -- 2207
				sessionId, -- 2207
				event.taskId, -- 2207
				event.step, -- 2207
				event.tool, -- 2207
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2207
			) -- 2207
			emitAgentSessionPatch( -- 2212
				sessionId, -- 2212
				{ -- 2212
					step = getStepItem(sessionId, event.taskId, event.step), -- 2213
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2214
				} -- 2214
			) -- 2214
			break -- 2216
		end -- 2216
		____cond393 = ____cond393 or ____switch393 == "memory_compression_started" -- 2216
		if ____cond393 then -- 2216
			upsertStep( -- 2218
				sessionId, -- 2218
				event.taskId, -- 2218
				event.step, -- 2218
				event.tool, -- 2218
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2218
			) -- 2218
			emitAgentSessionPatch( -- 2223
				sessionId, -- 2223
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2223
			) -- 2223
			break -- 2226
		end -- 2226
		____cond393 = ____cond393 or ____switch393 == "memory_compression_finished" -- 2226
		if ____cond393 then -- 2226
			upsertStep( -- 2228
				sessionId, -- 2228
				event.taskId, -- 2228
				event.step, -- 2228
				event.tool, -- 2228
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2228
			) -- 2228
			emitAgentSessionPatch( -- 2233
				sessionId, -- 2233
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2233
			) -- 2233
			break -- 2236
		end -- 2236
		____cond393 = ____cond393 or ____switch393 == "metrics_updated" -- 2236
		if ____cond393 then -- 2236
			do -- 2236
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2238
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2239
				break -- 2242
			end -- 2242
		end -- 2242
		____cond393 = ____cond393 or ____switch393 == "assistant_message_updated" -- 2242
		if ____cond393 then -- 2242
			do -- 2242
				local session = getSessionItem(sessionId) -- 2245
				if (session and session.currentTaskId) ~= event.taskId then -- 2245
					streamUpdates:clear(sessionId, event.taskId) -- 2247
					break -- 2247
				end -- 2247
				streamUpdates:update( -- 2249
					sessionId, -- 2249
					event.taskId, -- 2249
					event.step, -- 2249
					event, -- 2249
					App.runningTime -- 2249
				) -- 2249
				scheduleStreamFlush() -- 2250
				break -- 2251
			end -- 2251
		end -- 2251
		____cond393 = ____cond393 or ____switch393 == "assistant_message_finished" -- 2251
		if ____cond393 then -- 2251
			do -- 2251
				local ____opt_75 = getSessionItem(sessionId) -- 2251
				if (____opt_75 and ____opt_75.currentTaskId) ~= event.taskId then -- 2251
					streamUpdates:clear(sessionId, event.taskId) -- 2255
					break -- 2255
				end -- 2255
				streamUpdates:finish(sessionId, event.taskId, event.step) -- 2257
				upsertStep( -- 2258
					sessionId, -- 2258
					event.taskId, -- 2258
					event.step, -- 2258
					"message", -- 2258
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2258
				) -- 2258
				emitAgentSessionPatch( -- 2264
					sessionId, -- 2264
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2264
				) -- 2264
				break -- 2267
			end -- 2267
		end -- 2267
		____cond393 = ____cond393 or ____switch393 == "task_waiting_for_user" -- 2267
		if ____cond393 then -- 2267
			do -- 2267
				local ____opt_77 = getSessionItem(sessionId) -- 2267
				if (____opt_77 and ____opt_77.currentTaskId) ~= event.taskId then -- 2267
					streamUpdates:clear(sessionId, event.taskId) -- 2271
					break -- 2271
				end -- 2271
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2273
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2274
				__TS__Delete(activeStopTokens, event.taskId) -- 2275
				emitAgentSessionPatch( -- 2276
					sessionId, -- 2276
					{ -- 2276
						session = getSessionItem(sessionId), -- 2277
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2278
					} -- 2278
				) -- 2278
				break -- 2280
			end -- 2280
		end -- 2280
		____cond393 = ____cond393 or ____switch393 == "task_finished" -- 2280
		if ____cond393 then -- 2280
			do -- 2280
				local session = getSessionItem(sessionId) -- 2283
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2283
					__TS__Delete(activeStopTokens, event.taskId) -- 2285
					streamUpdates:clear(sessionId, event.taskId) -- 2286
					Log( -- 2287
						"Info", -- 2287
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2287
					) -- 2287
					break -- 2288
				end -- 2288
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2290
				local ____opt_79 = activeStopTokens[event.taskId or -1] -- 2290
				local stopped = (____opt_79 and ____opt_79.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2291
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2293
				local isSubSession = (session and session.kind) == "sub" -- 2296
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2297
				if isSubSession and event.taskId ~= nil then -- 2297
					finalizingSubSessionTaskIds[event.taskId] = true -- 2299
				end -- 2299
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2301
				if event.taskId ~= nil then -- 2301
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2303
					local ____finalizeTaskSteps_85 = finalizeTaskSteps -- 2304
					local ____array_84 = __TS__SparseArrayNew( -- 2304
						sessionId, -- 2305
						event.taskId, -- 2306
						type(event.steps) == "number" and math.max( -- 2307
							0, -- 2307
							math.floor(event.steps) -- 2307
						) or nil -- 2307
					) -- 2307
					local ____event_success_83 -- 2308
					if event.success then -- 2308
						____event_success_83 = nil -- 2308
					else -- 2308
						____event_success_83 = stopped and "STOPPED" or "FAILED" -- 2308
					end -- 2308
					__TS__SparseArrayPush(____array_84, ____event_success_83) -- 2308
					____finalizeTaskSteps_85(__TS__SparseArraySpread(____array_84)) -- 2304
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2310
					if not isSubSession then -- 2310
						__TS__Delete(activeStopTokens, event.taskId) -- 2312
					end -- 2312
					emitAgentSessionPatch( -- 2314
						sessionId, -- 2314
						{ -- 2314
							session = getSessionItem(sessionId), -- 2315
							message = getMessageItem(messageId), -- 2316
							removedStepIds = removedStepIds -- 2317
						} -- 2317
					) -- 2317
				end -- 2317
				if session and session.kind == "main" then -- 2317
					flushPendingSubAgentHandoffs(session) -- 2321
				end -- 2321
				break -- 2323
			end -- 2323
		end -- 2323
	until true -- 2323
end -- 2323
function ____exports.createSession(projectRoot, title) -- 2328
	if title == nil then -- 2328
		title = "" -- 2328
	end -- 2328
	local storage = requireAgentStorage() -- 2329
	if not storage.success then -- 2329
		return storage -- 2330
	end -- 2330
	if not isValidProjectRoot(projectRoot) then -- 2330
		return {success = false, message = "invalid projectRoot"} -- 2332
	end -- 2332
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2334
	if row then -- 2334
		return { -- 2343
			success = true, -- 2343
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2343
		} -- 2343
	end -- 2343
	local t = now() -- 2345
	DB:exec( -- 2346
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2346
		{ -- 2349
			projectRoot, -- 2349
			title ~= "" and title or Path:getFilename(projectRoot), -- 2349
			t, -- 2349
			t -- 2349
		} -- 2349
	) -- 2349
	local sessionId = getLastInsertRowId() -- 2351
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2352
	local session = getSessionItem(sessionId) -- 2353
	if not session then -- 2353
		return {success = false, message = "failed to create session"} -- 2355
	end -- 2355
	return {success = true, session = session} -- 2357
end -- 2328
function ____exports.createSubSession(parentSessionId, title) -- 2360
	if title == nil then -- 2360
		title = "" -- 2360
	end -- 2360
	local storage = requireAgentStorage() -- 2361
	if not storage.success then -- 2361
		return storage -- 2362
	end -- 2362
	local parent = getSessionItem(parentSessionId) -- 2363
	if not parent then -- 2363
		return {success = false, message = "parent session not found"} -- 2365
	end -- 2365
	local rootId = getSessionRootId(parent) -- 2367
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2367
		return {success = false, message = "project task admission is closed"} -- 2368
	end -- 2368
	local t = now() -- 2369
	DB:exec( -- 2370
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2370
		{ -- 2373
			parent.projectRoot, -- 2373
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2373
			rootId, -- 2373
			parent.id, -- 2373
			t, -- 2373
			t -- 2373
		} -- 2373
	) -- 2373
	local sessionId = getLastInsertRowId() -- 2375
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2376
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2377
	local session = getSessionItem(sessionId) -- 2378
	if not session then -- 2378
		return {success = false, message = "failed to create sub session"} -- 2380
	end -- 2380
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2382
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2383
	subStorage:writeMemory(parentStorage:readMemory()) -- 2384
	return {success = true, session = session} -- 2385
end -- 2360
function spawnSubAgentSession(request) -- 2388
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2388
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2401
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2402
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2403
		if normalizedPrompt == "" then -- 2403
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2405
		end -- 2405
		if normalizedPrompt == "" then -- 2405
			local ____Log_91 = Log -- 2412
			local ____temp_88 = #normalizedTitle -- 2412
			local ____temp_89 = #rawPrompt -- 2412
			local ____temp_90 = #toStr(request.expectedOutput) -- 2412
			local ____opt_86 = request.filesHint -- 2412
			____Log_91( -- 2412
				"Warn", -- 2412
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_88)) .. " raw_prompt_len=") .. tostring(____temp_89)) .. " expected_len=") .. tostring(____temp_90)) .. " files_hint_count=") .. tostring(____opt_86 and #____opt_86 or 0) -- 2412
			) -- 2412
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2412
		end -- 2412
		Log( -- 2415
			"Info", -- 2415
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2415
		) -- 2415
		local parentSessionId = request.parentSessionId -- 2416
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2416
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2418
			if not fallbackParent then -- 2418
				local createdMain = ____exports.createSession(request.projectRoot) -- 2420
				if createdMain.success then -- 2420
					fallbackParent = createdMain.session -- 2422
				end -- 2422
			end -- 2422
			if fallbackParent then -- 2422
				Log( -- 2426
					"Warn", -- 2426
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2426
				) -- 2426
				parentSessionId = fallbackParent.id -- 2427
			end -- 2427
		end -- 2427
		local parentSession = getSessionItem(parentSessionId) -- 2430
		if not parentSession then -- 2430
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2430
		end -- 2430
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2434
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2434
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2434
		end -- 2434
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2434
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2434
		end -- 2434
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2439
		if not created.success then -- 2439
			return ____awaiter_resolve(nil, created) -- 2439
		end -- 2439
		writeSpawnInfo( -- 2443
			created.session.projectRoot, -- 2443
			created.session.memoryScope, -- 2443
			{ -- 2443
				sessionId = created.session.id, -- 2444
				rootSessionId = created.session.rootSessionId, -- 2445
				parentSessionId = created.session.parentSessionId, -- 2446
				title = created.session.title, -- 2447
				prompt = normalizedPrompt, -- 2448
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2449
				expectedOutput = request.expectedOutput or "", -- 2450
				filesHint = request.filesHint or ({}), -- 2451
				status = "RUNNING", -- 2452
				success = false, -- 2453
				resultFilePath = "", -- 2454
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2455
				sourceTaskId = 0, -- 2456
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2457
				createdAtTs = created.session.createdAt, -- 2458
				finishedAt = "", -- 2459
				finishedAtTs = 0 -- 2460
			} -- 2460
		) -- 2460
		local sent = ____exports.sendPrompt( -- 2462
			created.session.id, -- 2462
			normalizedPrompt, -- 2462
			request.disabledAgentTools, -- 2462
			nil, -- 2462
			nil, -- 2462
			request.llmConfig -- 2462
		) -- 2462
		if not sent.success then -- 2462
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2462
		end -- 2462
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2462
	end) -- 2462
end -- 2462
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2586
	local rootSession = getRootSessionItem(session.id) -- 2587
	if not rootSession then -- 2587
		return -- 2588
	end -- 2588
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2589
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2590
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2591
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2592
	local queueResult = writePendingHandoff( -- 2593
		rootSession.projectRoot, -- 2593
		rootSession.memoryScope, -- 2593
		{ -- 2593
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2594
			sourceSessionId = session.id, -- 2595
			sourceTitle = session.title, -- 2596
			sourceTaskId = taskId, -- 2597
			message = summary, -- 2598
			prompt = result.prompt, -- 2599
			goal = result.goal, -- 2600
			expectedOutput = result.expectedOutput or "", -- 2601
			filesHint = result.filesHint or ({}), -- 2602
			success = result.success, -- 2603
			resultFilePath = result.resultFilePath, -- 2604
			artifactDir = result.artifactDir, -- 2605
			finishedAt = result.finishedAt, -- 2606
			changeSet = changeSet, -- 2607
			handoffEvidence = result.handoffEvidence, -- 2608
			memoryEntry = result.memoryEntry, -- 2609
			completion = result.completion, -- 2610
			createdAt = createdAt -- 2611
		} -- 2611
	) -- 2611
	if not queueResult then -- 2611
		Log( -- 2614
			"Warn", -- 2614
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2614
		) -- 2614
		return -- 2615
	end -- 2615
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2615
		addTaskReference(rootSession.currentTaskId, taskId) -- 2618
	end -- 2618
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2618
		flushPendingSubAgentHandoffs(rootSession) -- 2621
	end -- 2621
end -- 2621
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2625
	if forceHandoff == nil then -- 2625
		forceHandoff = false -- 2631
	end -- 2631
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2631
		local rootSessionId = getSessionRootId(session) -- 2633
		local rootSession = getRootSessionItem(session.id) -- 2634
		if not rootSession then -- 2634
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2634
		end -- 2634
		local spawnInfo = getSessionSpawnInfo(session) -- 2638
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2639
		local finishedAtTs = now() -- 2640
		local resultText = sanitizeUTF8(message) -- 2641
		local changeSet = getTaskChangeSetSummary(taskId) -- 2642
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2643
		local completionReport = completion or normalizeAgentCompletionReport({outcome = success and "completed" or (forceHandoff and "partial" or "blocked"), knownIssues = success and ({}) or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}) -- 2644
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2648
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2648
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2650
		end -- 2650
		local completed = success and completionReport.outcome == "completed" -- 2658
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2659
		local record = { -- 2662
			sessionId = session.id, -- 2663
			rootSessionId = rootSessionId, -- 2664
			parentSessionId = session.parentSessionId, -- 2665
			title = session.title, -- 2666
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2667
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2668
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2669
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2670
			status = recordStatus, -- 2671
			success = completed, -- 2672
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2673
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2674
			sourceTaskId = taskId, -- 2675
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2676
			finishedAt = finishedAt, -- 2677
			createdAtTs = session.createdAt, -- 2678
			finishedAtTs = finishedAtTs, -- 2679
			changeSet = changeSet, -- 2680
			handoffEvidence = handoffEvidence, -- 2681
			completion = completionReport -- 2682
		} -- 2682
		local ____record_success_110 -- 2684
		if record.success then -- 2684
			____record_success_110 = buildStructuredSubAgentMemoryEntry(record) -- 2684
		else -- 2684
			____record_success_110 = nil -- 2684
		end -- 2684
		record.memoryEntry = ____record_success_110 -- 2684
		if not writeSubAgentResultFile(session, record, resultText) then -- 2684
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2684
		end -- 2684
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2684
			sessionId = record.sessionId, -- 2689
			rootSessionId = record.rootSessionId, -- 2690
			parentSessionId = record.parentSessionId, -- 2691
			title = record.title, -- 2692
			prompt = record.prompt, -- 2693
			goal = record.goal, -- 2694
			expectedOutput = record.expectedOutput or "", -- 2695
			filesHint = record.filesHint or ({}), -- 2696
			status = record.status, -- 2697
			success = record.success, -- 2698
			resultFilePath = record.resultFilePath, -- 2699
			artifactDir = record.artifactDir, -- 2700
			sourceTaskId = record.sourceTaskId, -- 2701
			createdAt = record.createdAt, -- 2702
			finishedAt = record.finishedAt, -- 2703
			createdAtTs = record.createdAtTs, -- 2704
			finishedAtTs = record.finishedAtTs, -- 2705
			changeSet = record.changeSet, -- 2706
			handoffEvidence = record.handoffEvidence, -- 2707
			memoryEntry = record.memoryEntry, -- 2708
			memoryEntryError = record.memoryEntryError, -- 2709
			completion = record.completion -- 2710
		}) then -- 2710
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2710
		end -- 2710
		if success or forceHandoff then -- 2710
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2715
			deleteSessionRecords(session.id, true) -- 2716
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2717
		end -- 2717
		return ____awaiter_resolve(nil, {success = true}) -- 2717
	end) -- 2717
end -- 2717
function stopClearedSubSession(session, taskId) -- 2722
	local spawnInfo = getSessionSpawnInfo(session) -- 2723
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2724
	local rootSessionId = getSessionRootId(session) -- 2725
	Tools.setTaskStatus(taskId, "STOPPED") -- 2726
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2727
	if not writeSpawnInfo( -- 2727
		session.projectRoot, -- 2728
		session.memoryScope, -- 2728
		{ -- 2728
			sessionId = session.id, -- 2729
			rootSessionId = rootSessionId, -- 2730
			parentSessionId = session.parentSessionId, -- 2731
			title = session.title, -- 2732
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2733
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2734
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2735
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2736
			status = "STOPPED", -- 2737
			success = false, -- 2738
			cleared = true, -- 2739
			resultFilePath = "", -- 2740
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2741
			sourceTaskId = taskId, -- 2742
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2743
			finishedAt = finishedAt, -- 2744
			createdAtTs = session.createdAt, -- 2745
			finishedAtTs = now() -- 2746
		} -- 2746
	) then -- 2746
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2748
	end -- 2748
	deleteSessionRecords(session.id, true) -- 2750
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2751
	return {success = true} -- 2752
end -- 2752
function startImmediatePrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, inputId) -- 2755
	local session = getSessionItem(sessionId) -- 2756
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2756
		return {success = false, message = "project task admission is closed"} -- 2757
	end -- 2757
	if not session then -- 2757
		return {success = false, message = "session not found"} -- 2759
	end -- 2759
	if getPendingQuestionnaire(sessionId) then -- 2759
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2761
	end -- 2761
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2761
		return {success = false, message = "session task is finalizing"} -- 2763
	end -- 2763
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2763
		return {success = false, message = "session task is still running"} -- 2766
	end -- 2766
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2768
	if normalizedPrompt == "" and session.kind == "sub" then -- 2768
		local spawnInfo = getSessionSpawnInfo(session) -- 2770
		if spawnInfo then -- 2770
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2772
			if normalizedPrompt == "" then -- 2772
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2774
			end -- 2774
		end -- 2774
	end -- 2774
	if normalizedPrompt == "" then -- 2774
		return {success = false, message = "prompt is empty"} -- 2783
	end -- 2783
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2785
	if session.workMode ~= nextWorkMode then -- 2785
		DB:exec( -- 2787
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2787
			{ -- 2787
				nextWorkMode, -- 2787
				now(), -- 2787
				session.id -- 2787
			} -- 2787
		) -- 2787
		session.workMode = nextWorkMode -- 2788
	end -- 2788
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2790
	return startPromptTask( -- 2791
		session, -- 2791
		normalizedPrompt, -- 2791
		nil, -- 2791
		normalizeDisabledAgentTools(disabledAgentTools), -- 2791
		{ -- 2791
			workMode = nextWorkMode, -- 2791
			llmConfigId = llmConfigId, -- 2791
			llmConfig = llmConfig, -- 2791
			maxSteps = boundedMaxSteps, -- 2791
			inputId = inputId -- 2791
		} -- 2791
	) -- 2791
end -- 2791
function startLocalPrompt(sessionId, prompt, localAgentConfigId, inputId) -- 2794
	local session = getSessionItem(sessionId) -- 2795
	if not session then -- 2795
		return {success = false, message = "session not found"} -- 2796
	end -- 2796
	if session.kind ~= "main" then -- 2796
		return {success = false, message = "local Agent only supports main sessions"} -- 2797
	end -- 2797
	if getPendingQuestionnaire(sessionId) then -- 2797
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2798
	end -- 2798
	if session.currentTaskStatus == "RUNNING" then -- 2798
		return {success = false, message = "session task is still running"} -- 2799
	end -- 2799
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2800
	if normalizedPrompt == "" then -- 2800
		return {success = false, message = "prompt is empty"} -- 2801
	end -- 2801
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2802
	if not config then -- 2802
		return {success = false, message = "local Agent config not found"} -- 2803
	end -- 2803
	if not config.verifiedAt then -- 2803
		return {success = false, message = "local Agent config is not verified"} -- 2804
	end -- 2804
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2805
	if not taskRes.success then -- 2805
		return taskRes -- 2806
	end -- 2806
	local taskId = taskRes.taskId -- 2807
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2808
	if inputId ~= nil then -- 2808
		InputInbox.markDelivering(inputId, taskId) -- 2809
		InputInbox.markDelivered(inputId, messageId) -- 2809
	end -- 2809
	followup.activeRuns[sessionId] = taskId -- 2810
	Tools.setTaskStatus(taskId, "RUNNING") -- 2811
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2812
	upsertStep( -- 2813
		session.id, -- 2813
		taskId, -- 2813
		1, -- 2813
		"local_agent_message", -- 2813
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2813
	) -- 2813
	emitAgentSessionPatch( -- 2819
		session.id, -- 2819
		{ -- 2819
			session = getSessionItem(session.id), -- 2820
			message = getMessageItem(messageId), -- 2821
			step = getStepItem(session.id, taskId, 1) -- 2822
		} -- 2822
	) -- 2822
	local events = {} -- 2824
	local transcript = "" -- 2825
	local assistant = "" -- 2826
	local lastFlush = 0 -- 2827
	local function flush(force) -- 2828
		if force == nil then -- 2828
			force = false -- 2828
		end -- 2828
		if not force and App.runningTime - lastFlush < 0.075 then -- 2828
			return -- 2829
		end -- 2829
		lastFlush = App.runningTime -- 2830
		if #events > 400 then -- 2830
			events = __TS__ArraySlice(events, #events - 400) -- 2831
		end -- 2831
		if #transcript > 1024 * 1024 then -- 2831
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2832
		end -- 2832
		upsertStep( -- 2833
			session.id, -- 2833
			taskId, -- 2833
			1, -- 2833
			"local_agent_message", -- 2833
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2833
		) -- 2833
		local message -- 2838
		if assistant ~= "" then -- 2838
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2840
			message = getMessageItem(assistantId) -- 2841
		end -- 2841
		emitAgentSessionPatch( -- 2843
			session.id, -- 2843
			__TS__ObjectAssign( -- 2843
				{step = getStepItem(session.id, taskId, 1)}, -- 2843
				message and ({message = message}) or ({}) -- 2843
			) -- 2843
		) -- 2843
	end -- 2828
	local completedSynchronously = false -- 2845
	local control = LocalAgent.run( -- 2846
		session.id, -- 2846
		config, -- 2846
		session.projectRoot, -- 2846
		normalizedPrompt, -- 2846
		function(event) -- 2846
			local text = sanitizeUTF8(event.text) -- 2847
			if text == "" then -- 2847
				return -- 2848
			end -- 2848
			local previous = #events > 0 and events[#events] or nil -- 2849
			if previous and previous.kind == event.kind and previous.text == text then -- 2849
				return -- 2850
			end -- 2850
			events[#events + 1] = {kind = event.kind, text = text} -- 2851
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2852
			if event.kind == "assistant" then -- 2852
				assistant = text -- 2853
			end -- 2853
			flush(false) -- 2854
		end, -- 2846
		function(result) -- 2855
			completedSynchronously = true -- 2856
			flush(true) -- 2857
			__TS__Delete(activeLocalAgentControls, taskId) -- 2858
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2859
			Tools.setTaskStatus(taskId, status) -- 2860
			setSessionState(session.id, status, taskId, status) -- 2861
			upsertStep( -- 2862
				session.id, -- 2862
				taskId, -- 2862
				1, -- 2862
				"local_agent_message", -- 2862
				{status = status, reason = config.name .. " · full permissions", result = { -- 2862
					provider = config.provider, -- 2865
					events = events, -- 2865
					transcript = transcript, -- 2865
					exitCode = result.exitCode, -- 2865
					resumeId = result.resumeId, -- 2865
					message = result.message -- 2865
				}} -- 2865
			) -- 2865
			emitAgentSessionPatch( -- 2867
				session.id, -- 2867
				{ -- 2867
					session = getSessionItem(session.id), -- 2867
					step = getStepItem(session.id, taskId, 1) -- 2867
				} -- 2867
			) -- 2867
			followup.settle(sessionId, taskId, result.success and not result.stopped) -- 2868
		end -- 2855
	) -- 2855
	if not completedSynchronously then -- 2855
		activeLocalAgentControls[taskId] = control -- 2870
	end -- 2870
	return {success = true, sessionId = session.id, taskId = taskId} -- 2871
end -- 2871
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2944
	if disabledAgentTools == nil then -- 2944
		disabledAgentTools = {} -- 2948
	end -- 2948
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2951
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2951
		return {success = false, message = "project task admission is closed"} -- 2952
	end -- 2952
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2953
	if not llmConfigRes.success then -- 2953
		return {success = false, message = llmConfigRes.message} -- 2957
	end -- 2957
	local llmConfig = llmConfigRes.config -- 2959
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 2960
	if not llmConfigValidation.success then -- 2960
		return llmConfigValidation -- 2962
	end -- 2962
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 2964
	if not taskRes.success then -- 2964
		return {success = false, message = taskRes.message} -- 2967
	end -- 2967
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 2967
		removeContinuableTaskSummary(session) -- 2969
	end -- 2969
	local taskId = taskRes.taskId -- 2971
	if (options and options.inputId) ~= nil then -- 2971
		InputInbox.markDelivering(options.inputId, taskId) -- 2972
	end -- 2972
	followup.activeRuns[session.id] = taskId -- 2973
	local ____temp_133 -- 2974
	if (options and options.existingTaskId) == nil then -- 2974
		____temp_133 = session.currentTaskId -- 2974
	else -- 2974
		____temp_133 = nil -- 2974
	end -- 2974
	local previousTaskId = ____temp_133 -- 2974
	local useChineseResponse = getDefaultUseChineseResponse() -- 2975
	local promptMessageId -- 2976
	if existingUserMessageId ~= nil then -- 2976
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 2978
		promptMessageId = existingUserMessageId -- 2979
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 2979
		promptMessageId = insertMessage( -- 2981
			session.id, -- 2981
			"user", -- 2981
			normalizedPrompt, -- 2981
			taskId, -- 2981
			options and options.displayContent -- 2981
		) -- 2981
	end -- 2981
	if (options and options.inputId) ~= nil and promptMessageId ~= nil then -- 2981
		if DB:exec("UPDATE agent.AgentSessionInput SET message_id=? WHERE id=?", {promptMessageId, options.inputId}) < 0 then -- 2981
			error( -- 2984
				__TS__New(Error, "failed to link input display"), -- 2984
				0 -- 2984
			) -- 2984
		end -- 2984
		if normalizedPrompt == "/clear" or normalizedPrompt == "/compact" then -- 2984
			InputInbox.markDelivered(options.inputId, promptMessageId) -- 2985
		end -- 2985
	end -- 2985
	local stopToken = {stopped = false} -- 2987
	activeStopTokens[taskId] = stopToken -- 2988
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2989
	emitAgentSessionPatch( -- 2993
		session.id, -- 2993
		__TS__ObjectAssign( -- 2993
			{session = getSessionItem(session.id)}, -- 2993
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 2995
		) -- 2995
	) -- 2995
	if previousTaskId and previousTaskId ~= taskId then -- 2995
		cleanupTaskHeavyData(previousTaskId) -- 2998
	end -- 2998
	activePromptRuns = activePromptRuns + 1 -- 3000
	local ____runCodingAgent_168 = runCodingAgent -- 3001
	local ____normalizedPrompt_159 = normalizedPrompt -- 3002
	local ____temp_160 = options and options.inputId -- 3003
	local ____temp_161 = { -- 3004
		pending = function() return __TS__ArrayMap( -- 3005
			__TS__ArrayFilter( -- 3005
				InputInbox.listInputs(session.id), -- 3005
				function(____, item) return item.delivery == "steer" and not item.held and item.status == "pending" end -- 3005
			), -- 3005
			function(____, item) return {id = item.id, content = item.content} end -- 3005
		) end, -- 3005
		delivered = function(id, step) return followup.delivered(session.id, taskId, id, step) end -- 3006
	} -- 3006
	local ____temp_162 = options and options.resumeConversation -- 3008
	local ____temp_163 = (options and options.existingTaskId) ~= nil -- 3009
	local ____temp_164 = options and options.initialStep -- 3010
	local ____temp_165 = options and options.initialAgentStepCount -- 3011
	local ____temp_154 -- 3012
	if (options and options.existingTaskId) ~= nil then -- 3012
		____temp_154 = getInitialTokenUsage(session) -- 3012
	else -- 3012
		____temp_154 = nil -- 3012
	end -- 3012
	____runCodingAgent_168( -- 3001
		{ -- 3001
			prompt = ____normalizedPrompt_159, -- 3002
			inputId = ____temp_160, -- 3003
			inputSource = ____temp_161, -- 3004
			resumeConversation = ____temp_162, -- 3008
			resumeTask = ____temp_163, -- 3009
			initialStep = ____temp_164, -- 3010
			initialAgentStepCount = ____temp_165, -- 3011
			initialTokenUsage = ____temp_154, -- 3012
			workDir = session.projectRoot, -- 3013
			useChineseResponse = useChineseResponse, -- 3014
			taskId = taskId, -- 3015
			sessionId = session.id, -- 3016
			memoryScope = session.memoryScope, -- 3017
			role = session.kind, -- 3018
			maxSteps = options and options.maxSteps, -- 3019
			disabledAgentTools = disabledAgentTools, -- 3020
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 3021
			llmConfig = llmConfig, -- 3022
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 3023
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 3026
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 3029
			stopToken = stopToken, -- 3030
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 3031
		}, -- 3031
		function(result) -- 3032
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3032
				local ____hasReturned, ____returnValue -- 3032
				local ____try = __TS__AsyncAwaiter(function() -- 3032
					local nextSession = getSessionItem(session.id) -- 3034
					if nextSession and nextSession.kind == "sub" then -- 3034
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 3034
							local stopped = stopClearedSubSession(nextSession, taskId) -- 3037
							if not stopped.success then -- 3037
								Log( -- 3039
									"Warn", -- 3039
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 3039
								) -- 3039
								emitAgentSessionPatch( -- 3040
									session.id, -- 3040
									{session = getSessionItem(session.id)} -- 3040
								) -- 3040
							end -- 3040
							__TS__Delete(activeStopTokens, taskId) -- 3044
							____hasReturned = true -- 3045
							return -- 3045
						end -- 3045
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3047
						emitAgentSessionPatch( -- 3048
							session.id, -- 3048
							{session = getSessionItem(session.id)} -- 3048
						) -- 3048
						local finalized = __TS__Await(finalizeSubSession( -- 3051
							nextSession, -- 3052
							taskId, -- 3053
							result.success, -- 3054
							result.message, -- 3055
							result.completion, -- 3056
							(options and options.forceSubAgentHandoff) == true -- 3057
						)) -- 3057
						if not finalized.success then -- 3057
							Log( -- 3060
								"Warn", -- 3060
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 3060
							) -- 3060
						end -- 3060
						local finalizedSession = getSessionItem(session.id) -- 3062
						if finalizedSession then -- 3062
							local stopped = stopToken.stopped == true -- 3064
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 3065
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 3068
							emitAgentSessionPatch( -- 3069
								session.id, -- 3069
								{session = getSessionItem(session.id)} -- 3069
							) -- 3069
						end -- 3069
						__TS__Delete(activeStopTokens, taskId) -- 3073
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 3074
					end -- 3074
					local fallbackSession = getSessionItem(session.id) -- 3076
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 3076
						applyEvent(session.id, { -- 3082
							type = "task_finished", -- 3083
							sessionId = session.id, -- 3084
							taskId = result.taskId, -- 3085
							success = false, -- 3086
							message = result.message, -- 3087
							steps = result.steps -- 3088
						}) -- 3088
					end -- 3088
				end) -- 3088
				____try = ____try.finally( -- 3088
					____try, -- 3088
					function() -- 3088
						return __TS__AsyncAwaiter(function() -- 3088
							activePromptRuns = activePromptRuns - 1 -- 3092
							followup.settle(session.id, taskId, result.success and not result.waitingForUser and not stopToken.stopped) -- 3093
						end) -- 3093
					end -- 3093
				) -- 3093
				__TS__Await(____try) -- 3033
				if ____hasReturned then -- 3033
					return ____awaiter_resolve(nil, ____returnValue) -- 3033
				end -- 3033
			end) -- 3033
		end -- 3032
	) -- 3032
	return {success = true, sessionId = session.id, taskId = taskId} -- 3096
end -- 3096
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3251
	local lines = {} -- 3252
	do -- 3252
		local i = 0 -- 3253
		while i < #questionnaire.schema.questions do -- 3253
			local question = questionnaire.schema.questions[i + 1] -- 3254
			local answer = __TS__ArrayFind( -- 3255
				answers, -- 3255
				function(____, item) return item.questionId == question.id end -- 3255
			) -- 3255
			local answerText = "已跳过" -- 3256
			if answer and answer.status == "answered" then -- 3256
				local parts = {} -- 3258
				do -- 3258
					local j = 0 -- 3259
					while j < #(answer.selectedOptionIds or ({})) do -- 3259
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3260
						local option = __TS__ArrayFind( -- 3261
							question.options or ({}), -- 3261
							function(____, item) return item.id == optionId end -- 3261
						) -- 3261
						if option then -- 3261
							parts[#parts + 1] = option.label -- 3262
						end -- 3262
						j = j + 1 -- 3259
					end -- 3259
				end -- 3259
				if answer.otherText then -- 3259
					parts[#parts + 1] = answer.otherText -- 3264
				end -- 3264
				if answer.text then -- 3264
					parts[#parts + 1] = answer.text -- 3265
				end -- 3265
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3266
			end -- 3266
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3268
			i = i + 1 -- 3253
		end -- 3253
	end -- 3253
	return table.concat(lines, "\n\n") -- 3270
end -- 3270
function ____exports.listRunningSubAgents(request) -- 3557
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3557
		local session = getSessionItem(request.sessionId) -- 3565
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3565
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3567
		end -- 3567
		if not session then -- 3567
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3567
		end -- 3567
		local rootSession = getRootSessionItem(session.id) -- 3572
		if not rootSession then -- 3572
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3572
		end -- 3572
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3576
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3577
		local limit = math.max( -- 3578
			1, -- 3578
			math.floor(tonumber(request.limit) or 5) -- 3578
		) -- 3578
		local offset = math.max( -- 3579
			0, -- 3579
			math.floor(tonumber(request.offset) or 0) -- 3579
		) -- 3579
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3580
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3581
		local runningSessions = {} -- 3588
		do -- 3588
			local i = 0 -- 3589
			while i < #rows do -- 3589
				do -- 3589
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3590
					if current.currentTaskStatus ~= "RUNNING" then -- 3590
						goto __continue654 -- 3592
					end -- 3592
					local spawnInfo = getSessionSpawnInfo(current) -- 3594
					runningSessions[#runningSessions + 1] = { -- 3595
						sessionId = current.id, -- 3596
						title = current.title, -- 3597
						parentSessionId = current.parentSessionId, -- 3598
						rootSessionId = current.rootSessionId, -- 3599
						status = "RUNNING", -- 3600
						currentTaskId = current.currentTaskId, -- 3601
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3602
						goal = spawnInfo and spawnInfo.goal, -- 3603
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3604
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3605
						createdAt = current.createdAt, -- 3606
						updatedAt = current.updatedAt -- 3607
					} -- 3607
				end -- 3607
				::__continue654:: -- 3607
				i = i + 1 -- 3589
			end -- 3589
		end -- 3589
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3610
		local completedSessions = __TS__ArrayMap( -- 3611
			completedRecords, -- 3611
			function(____, record) return { -- 3611
				sessionId = record.sessionId, -- 3612
				title = record.title, -- 3613
				parentSessionId = record.parentSessionId, -- 3614
				rootSessionId = record.rootSessionId, -- 3615
				status = record.status, -- 3616
				goal = record.goal, -- 3617
				expectedOutput = record.expectedOutput, -- 3618
				filesHint = record.filesHint, -- 3619
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3620
				success = record.success, -- 3621
				cleared = record.cleared, -- 3622
				resultFilePath = record.resultFilePath, -- 3623
				artifactDir = record.artifactDir, -- 3624
				finishedAt = record.finishedAt, -- 3625
				createdAt = record.createdAtTs, -- 3626
				updatedAt = record.finishedAtTs -- 3627
			} end -- 3627
		) -- 3627
		local merged = {} -- 3629
		if status == "running" then -- 3629
			merged = runningSessions -- 3631
		elseif status == "done" then -- 3631
			merged = __TS__ArrayFilter( -- 3633
				completedSessions, -- 3633
				function(____, item) return item.status == "DONE" end -- 3633
			) -- 3633
		elseif status == "failed" then -- 3633
			merged = __TS__ArrayFilter( -- 3635
				completedSessions, -- 3635
				function(____, item) return item.status == "FAILED" end -- 3635
			) -- 3635
		elseif status == "stopped" then -- 3635
			merged = __TS__ArrayFilter( -- 3637
				completedSessions, -- 3637
				function(____, item) return item.status == "STOPPED" end -- 3637
			) -- 3637
		elseif status == "all" then -- 3637
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3639
		else -- 3639
			local runningKeys = {} -- 3641
			do -- 3641
				local i = 0 -- 3642
				while i < #runningSessions do -- 3642
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3643
					i = i + 1 -- 3642
				end -- 3642
			end -- 3642
			local latestCompletedByKey = {} -- 3645
			do -- 3645
				local i = 0 -- 3646
				while i < #completedSessions do -- 3646
					do -- 3646
						local item = completedSessions[i + 1] -- 3647
						local key = getSubAgentDisplayKey(item) -- 3648
						if runningKeys[key] then -- 3648
							goto __continue669 -- 3650
						end -- 3650
						local current = latestCompletedByKey[key] -- 3652
						if current == nil or item.updatedAt > current.updatedAt then -- 3652
							latestCompletedByKey[key] = item -- 3654
						end -- 3654
					end -- 3654
					::__continue669:: -- 3654
					i = i + 1 -- 3646
				end -- 3646
			end -- 3646
			local latestCompleted = {} -- 3657
			for ____, item in pairs(latestCompletedByKey) do -- 3658
				latestCompleted[#latestCompleted + 1] = item -- 3659
			end -- 3659
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3661
		end -- 3661
		if query ~= "" then -- 3661
			merged = __TS__ArrayFilter( -- 3664
				merged, -- 3664
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3664
			) -- 3664
		end -- 3664
		__TS__ArraySort( -- 3670
			merged, -- 3670
			function(____, a, b) -- 3670
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3670
					return -1 -- 3671
				end -- 3671
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3671
					return 1 -- 3672
				end -- 3672
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3672
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3674
				end -- 3674
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3676
			end -- 3670
		) -- 3670
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3678
		return ____awaiter_resolve(nil, { -- 3678
			success = true, -- 3680
			rootSessionId = rootSession.id, -- 3681
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3682
			status = status, -- 3683
			limit = limit, -- 3684
			offset = offset, -- 3685
			hasMore = offset + limit < #merged, -- 3686
			sessions = paged -- 3687
		}) -- 3687
	end) -- 3687
end -- 3557
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
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1191
	if projectRoot == oldRoot then -- 1191
		return newRoot -- 1193
	end -- 1193
	for ____, separator in ipairs({"/", "\\"}) do -- 1195
		local prefix = oldRoot .. separator -- 1196
		if __TS__StringStartsWith(projectRoot, prefix) then -- 1196
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1198
		end -- 1198
	end -- 1198
	return nil -- 1201
end -- 1191
local function clearSessionAfterMessage(sessionId, message) -- 1720
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1721
	local removedStepIds = {} -- 1729
	do -- 1729
		local i = 0 -- 1730
		while i < #removedStepRows do -- 1730
			local row = removedStepRows[i + 1] -- 1731
			if type(row[1]) == "number" then -- 1731
				removedStepIds[#removedStepIds + 1] = row[1] -- 1733
			end -- 1733
			i = i + 1 -- 1730
		end -- 1730
	end -- 1730
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1736
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1744
	return removedStepIds -- 1749
end -- 1720
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1752
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1753
	local persisted = storage:readSessionState() -- 1754
	local userIndex = -1 -- 1755
	do -- 1755
		local i = #persisted.messages - 1 -- 1756
		while i >= 0 do -- 1756
			if persisted.messages[i + 1].role == "user" and persisted.messages[i + 1].inputKind ~= "steer" then -- 1756
				userIndex = i -- 1758
				break -- 1759
			end -- 1759
			i = i - 1 -- 1756
		end -- 1756
	end -- 1756
	if userIndex < 0 then -- 1756
		return -- 1762
	end -- 1762
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1763
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1764
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1765
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1770
end -- 1752
local function listCurrentTaskCheckpoints(sessionId) -- 1782
	local session = getSessionItem(sessionId) -- 1783
	local taskId = session and session.currentTaskId -- 1784
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1785
end -- 1782
local function getAgentStepCount(sessionId, taskId) -- 1892
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1893
		sessionId, -- 1898
		taskId, -- 1899
		"compress_memory", -- 1900
		"merge_memory", -- 1901
		"sub_agent_handoff", -- 1902
		"questionnaire_answer", -- 1903
		"message" -- 1904
	}) -- 1904
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1907
end -- 1892
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1910
	if status == nil then -- 1910
		status = "DONE" -- 1918
	end -- 1918
	local step = getNextStepNumber(sessionId, taskId) -- 1920
	upsertStep( -- 1921
		sessionId, -- 1921
		taskId, -- 1921
		step, -- 1921
		tool, -- 1921
		{status = status, reason = reason, params = params, result = result} -- 1921
	) -- 1921
	return getStepItem(sessionId, taskId, step) -- 1927
end -- 1910
local function sanitizeStoredSteps(sessionId) -- 1994
	DB:exec( -- 1995
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 1995
		{ -- 2013
			now(), -- 2013
			sessionId -- 2013
		} -- 2013
	) -- 2013
end -- 1994
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2474
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2474
		return {success = false, message = "invalid projectRoot"} -- 2476
	end -- 2476
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2478
	for ____, row in ipairs(rows) do -- 2479
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2480
		if sessionId > 0 then -- 2480
			deleteSessionRecords(sessionId) -- 2482
		end -- 2482
	end -- 2482
	return {success = true, deleted = #rows} -- 2485
end -- 2474
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2488
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2488
		return {success = false, message = "invalid projectRoot"} -- 2490
	end -- 2490
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2492
	local renamed = 0 -- 2493
	for ____, row in ipairs(rows) do -- 2494
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2495
		local projectRoot = toStr(row[2]) -- 2496
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2497
		if sessionId > 0 and nextProjectRoot then -- 2497
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2499
			DB:exec( -- 2500
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2500
				{ -- 2502
					nextProjectRoot, -- 2502
					Path:getFilename(nextProjectRoot), -- 2502
					now(), -- 2502
					sessionId -- 2502
				} -- 2502
			) -- 2502
			renamed = renamed + 1 -- 2504
		end -- 2504
	end -- 2504
	return {success = true, renamed = renamed} -- 2507
end -- 2488
function ____exports.getSession(sessionId, view) -- 2510
	local session = getSessionItem(sessionId) -- 2511
	if not session then -- 2511
		return {success = false, message = "session not found"} -- 2513
	end -- 2513
	if not followup.activeRuns[sessionId] then -- 2513
		followup.recover(session) -- 2515
	end -- 2515
	local restored = restorePendingQuestionnaireState(session) -- 2516
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2517
	local ____opt_92 = getSessionItem(sessionId) -- 2517
	normalizedSession.pendingInputs = ____opt_92 and ____opt_92.pendingInputs -- 2518
	local relatedSessions = listRelatedSessions(sessionId) -- 2519
	sanitizeStoredSteps(sessionId) -- 2520
	local firstMessageId = 0 -- 2521
	local hasEarlierMessages = false -- 2522
	if view then -- 2522
		local limit = math.max( -- 2524
			1, -- 2524
			math.min( -- 2524
				1000, -- 2524
				math.floor(view.recentRounds) -- 2524
			) -- 2524
		) -- 2524
		local requests = queryRows(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m WHERE m.session_id = ? AND m.role = 'user'\n    AND NOT EXISTS (SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n\t\t\tORDER BY m.id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2525
		if #requests > limit then -- 2525
			firstMessageId = requests[limit][1] -- 2531
			hasEarlierMessages = true -- 2532
		end -- 2532
	end -- 2532
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2535
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2542
	local ____relatedSessions_99 = relatedSessions -- 2554
	local ____temp_98 -- 2555
	if normalizedSession.kind == "sub" then -- 2555
		____temp_98 = getSessionSpawnInfo(normalizedSession) -- 2555
	else -- 2555
		____temp_98 = nil -- 2555
	end -- 2555
	return { -- 2551
		success = true, -- 2552
		session = normalizedSession, -- 2553
		relatedSessions = ____relatedSessions_99, -- 2554
		spawnInfo = ____temp_98, -- 2555
		messages = __TS__ArrayMap( -- 2556
			messages, -- 2556
			function(____, row) return rowToMessage(row) end -- 2556
		), -- 2556
		hasEarlierMessages = hasEarlierMessages, -- 2557
		steps = __TS__ArrayMap( -- 2558
			steps, -- 2558
			function(____, row) return rowToStep(row) end -- 2558
		), -- 2558
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2559
		pendingQuestionnaire = restored.questionnaire, -- 2560
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2561
	} -- 2561
end -- 2510
function ____exports.setWorkMode(sessionId, workMode) -- 2566
	local session = getSessionItem(sessionId) -- 2567
	if not session then -- 2567
		return {success = false, message = "session not found"} -- 2568
	end -- 2568
	if session.kind ~= "main" then -- 2568
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2569
	end -- 2569
	if workMode ~= "code" and workMode ~= "plan" then -- 2569
		return {success = false, message = "invalid work mode"} -- 2570
	end -- 2570
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2571
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2571
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2573
	end -- 2573
	if getPendingQuestionnaire(sessionId) then -- 2573
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2576
	end -- 2576
	if normalizedSession.workMode ~= workMode then -- 2576
		DB:exec( -- 2579
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2579
			{ -- 2579
				workMode, -- 2579
				now(), -- 2579
				sessionId -- 2579
			} -- 2579
		) -- 2579
	end -- 2579
	local updated = getSessionItem(sessionId) -- 2581
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2582
	return { -- 2583
		success = true, -- 2583
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2583
	} -- 2583
end -- 2566
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId, llmConfig) -- 2874
	local session = getSessionItem(sessionId) -- 2875
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2875
		return {success = false, message = "project task admission is closed"} -- 2876
	end -- 2876
	if not session then -- 2876
		return {success = false, message = "session not found"} -- 2878
	end -- 2878
	if getPendingQuestionnaire(sessionId) then -- 2878
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2880
	end -- 2880
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2880
		return {success = false, message = "session task is finalizing"} -- 2882
	end -- 2882
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2882
		return {success = false, message = "session task is still stopping"} -- 2885
	end -- 2885
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2885
		return {success = false, message = "session task is not continuable"} -- 2888
	end -- 2888
	if session.currentTaskId == nil then -- 2888
		return {success = false, message = "session task not found"} -- 2891
	end -- 2891
	local resolved = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 2893
	if not resolved.success then -- 2893
		return {success = false, message = resolved.message} -- 2894
	end -- 2894
	followup.recover(session) -- 2895
	local previousBinding = followup.bindings[sessionId] -- 2896
	followup.bindings[sessionId] = {llmConfig = resolved.config, llmConfigId = llmConfigId} -- 2897
	local taskId = session.currentTaskId -- 2898
	local result = startPromptTask( -- 2899
		session, -- 2900
		"", -- 2901
		nil, -- 2902
		normalizeDisabledAgentTools(disabledAgentTools), -- 2903
		{ -- 2904
			workMode = session.workMode, -- 2905
			persistUserMessage = false, -- 2906
			resumeConversation = true, -- 2907
			existingTaskId = taskId, -- 2908
			initialStep = math.max( -- 2909
				0, -- 2909
				getNextStepNumber(session.id, taskId) - 1 -- 2909
			), -- 2909
			initialAgentStepCount = 0, -- 2913
			llmConfigId = llmConfigId, -- 2914
			llmConfig = resolved.config -- 2915
		} -- 2915
	) -- 2915
	if result.success then -- 2915
		for ____, input in ipairs(InputInbox.listInputs(sessionId)) do -- 2921
			followup.configs[input.id] = resolved.config -- 2921
		end -- 2921
		InputInbox.mutateInput(sessionId, {action = "resume"}, "") -- 2922
		followup.publish(sessionId) -- 2923
	elseif previousBinding then -- 2923
		followup.bindings[sessionId] = previousBinding -- 2924
	else -- 2924
		__TS__Delete(followup.bindings, sessionId) -- 2925
	end -- 2925
	return result -- 2926
end -- 2874
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 3099
	local session = getSessionItem(sessionId) -- 3100
	if not session then -- 3100
		return {success = false, message = "session not found"} -- 3102
	end -- 3102
	if session.kind ~= "sub" then -- 3102
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 3105
	end -- 3105
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3105
		return {success = false, message = "session task is finalizing"} -- 3108
	end -- 3108
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3110
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 3110
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 3115
	end -- 3115
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 3115
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 3118
	end -- 3118
	local disabledAgentTools = __TS__ArrayFilter( -- 3120
		AgentToolRegistry.getAllowedToolsForRole("sub"), -- 3120
		function(____, tool) return tool ~= "finish" end -- 3121
	) -- 3121
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并立即交接已有工作。不要继续实现、读取、搜索、构建或验证。请只调用 finish：根据当前会话中已有的真实证据，总结已完成内容、文件变更、验证状态和剩余问题；未完成时将 outcome 设为 partial，不要把未验证内容写成已完成。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 3122
	return startPromptTask( -- 3125
		session, -- 3125
		prompt, -- 3125
		nil, -- 3125
		disabledAgentTools, -- 3125
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 3125
	) -- 3125
end -- 3099
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 3132
	local session = getSessionItem(sessionId) -- 3133
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3133
		return {success = false, message = "project task admission is closed"} -- 3134
	end -- 3134
	if not session then -- 3134
		return {success = false, message = "session not found"} -- 3136
	end -- 3136
	if #InputInbox.listInputs(sessionId) > 0 then -- 3136
		return {success = false, message = "finish or remove pending messages before editing task history"} -- 3138
	end -- 3138
	if getPendingQuestionnaire(sessionId) then -- 3138
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 3139
	end -- 3139
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3139
		return {success = false, message = "session task is finalizing"} -- 3141
	end -- 3141
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 3141
		return {success = false, message = "session task is still running"} -- 3144
	end -- 3144
	local message = getMessageItem(messageId) -- 3146
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 3146
		return {success = false, message = "message not found"} -- 3148
	end -- 3148
	local latestUserRow = queryOne(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m\n  WHERE m.session_id = ? AND m.role = ? AND NOT EXISTS (\n   SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n  ORDER BY m.id DESC LIMIT 1", {sessionId, "user"}) -- 3150
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 3157
	if latestUserMessageId ~= messageId then -- 3157
		return {success = false, message = "only the latest user prompt can be edited"} -- 3159
	end -- 3159
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 3161
	if normalizedPrompt == "" then -- 3161
		return {success = false, message = "prompt is empty"} -- 3163
	end -- 3163
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 3165
	if session.workMode ~= nextWorkMode then -- 3165
		DB:exec( -- 3167
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 3167
			{ -- 3167
				nextWorkMode, -- 3167
				now(), -- 3167
				session.id -- 3167
			} -- 3167
		) -- 3167
		session.workMode = nextWorkMode -- 3168
	end -- 3168
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 3170
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 3171
	local result = startPromptTask( -- 3172
		session, -- 3172
		normalizedPrompt, -- 3172
		messageId, -- 3172
		normalizeDisabledAgentTools(disabledAgentTools), -- 3172
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 3172
	) -- 3172
	if result.success and #removedStepIds > 0 then -- 3172
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 3174
	end -- 3174
	return result -- 3176
end -- 3132
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 3181
	if status == "dismissed" then -- 3181
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 3187
	end -- 3187
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3189
end -- 3181
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3192
	if status == "dismissed" then -- 3192
		return { -- 3198
			success = true, -- 3199
			status = "dismissed", -- 3200
			source = "user", -- 3201
			questionnaireId = questionnaire.id, -- 3202
			title = questionnaire.schema.title, -- 3203
			answers = {}, -- 3204
			responses = {}, -- 3205
			displayText = "用户关闭了调查问卷，未作答。", -- 3206
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 3207
		} -- 3207
	end -- 3207
	local responses = {} -- 3210
	do -- 3210
		local i = 0 -- 3211
		while i < #questionnaire.schema.questions do -- 3211
			do -- 3211
				local question = questionnaire.schema.questions[i + 1] -- 3212
				local answer = __TS__ArrayFind( -- 3213
					answers, -- 3213
					function(____, item) return item.questionId == question.id end -- 3213
				) -- 3213
				if not answer or answer.status == "skipped" then -- 3213
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3215
					goto __continue566 -- 3220
				end -- 3220
				local selectedOptionLabels = {} -- 3222
				do -- 3222
					local j = 0 -- 3223
					while j < #(answer.selectedOptionIds or ({})) do -- 3223
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3224
						local option = __TS__ArrayFind( -- 3225
							question.options or ({}), -- 3225
							function(____, item) return item.id == optionId end -- 3225
						) -- 3225
						if option then -- 3225
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3226
						end -- 3226
						j = j + 1 -- 3223
					end -- 3223
				end -- 3223
				responses[#responses + 1] = { -- 3228
					questionId = question.id, -- 3229
					prompt = question.prompt, -- 3230
					status = "answered", -- 3231
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3232
					selectedOptionLabels = selectedOptionLabels, -- 3233
					otherText = answer.otherText, -- 3234
					text = answer.text -- 3235
				} -- 3235
			end -- 3235
			::__continue566:: -- 3235
			i = i + 1 -- 3211
		end -- 3211
	end -- 3211
	return { -- 3238
		success = true, -- 3239
		status = "answered", -- 3240
		source = "user", -- 3241
		questionnaireId = questionnaire.id, -- 3242
		title = questionnaire.schema.title, -- 3243
		answers = answers, -- 3244
		responses = responses, -- 3245
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3246
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3247
	} -- 3247
end -- 3192
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3273
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3279
	local persisted = storage:readSessionState() -- 3280
	local messages = __TS__ArraySlice(persisted.messages) -- 3281
	local toolResultIndex = -1 -- 3282
	local existingResult -- 3283
	do -- 3283
		local i = #messages - 1 -- 3284
		while i >= 0 do -- 3284
			do -- 3284
				local message = messages[i + 1] -- 3285
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3285
					goto __continue586 -- 3286
				end -- 3286
				local decoded = safeJsonDecode(message.content) -- 3287
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3287
					goto __continue586 -- 3288
				end -- 3288
				local row = decoded -- 3289
				if row.questionnaireId ~= questionnaire.id then -- 3289
					goto __continue586 -- 3290
				end -- 3290
				toolResultIndex = i -- 3291
				existingResult = row -- 3292
				break -- 3293
			end -- 3293
			::__continue586:: -- 3293
			i = i - 1 -- 3284
		end -- 3284
	end -- 3284
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3295
	local guidance = {} -- 3296
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3296
		guidance[#guidance + 1] = existingResult.guidance -- 3298
	end -- 3298
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3298
		guidance[#guidance + 1] = result.guidance -- 3301
	end -- 3301
	result.guidance = table.concat(guidance, "\n") -- 3303
	if toolResultIndex < 0 then -- 3303
		messages[#messages + 1] = { -- 3305
			role = "user", -- 3306
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3307
		} -- 3307
		toolResultIndex = #messages - 1 -- 3309
	else -- 3309
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3311
			{}, -- 3311
			messages[toolResultIndex + 1], -- 3312
			{content = encodeJson(result)} -- 3311
		) -- 3311
	end -- 3311
	local pairStartIndex = toolResultIndex -- 3317
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3318
	if toolCallId and toolCallId ~= "" then -- 3318
		do -- 3318
			local i = toolResultIndex - 1 -- 3320
			while i >= 0 do -- 3320
				do -- 3320
					local message = messages[i + 1] -- 3321
					if message.role ~= "assistant" or not message.tool_calls then -- 3321
						goto __continue596 -- 3322
					end -- 3322
					if __TS__ArraySome( -- 3322
						message.tool_calls, -- 3323
						function(____, call) return call.id == toolCallId end -- 3323
					) then -- 3323
						pairStartIndex = i -- 3324
						break -- 3325
					end -- 3325
				end -- 3325
				::__continue596:: -- 3325
				i = i - 1 -- 3320
			end -- 3320
		end -- 3320
	end -- 3320
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3329
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3332
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3336
	upsertStep( -- 3338
		session.id, -- 3338
		questionnaire.taskId, -- 3338
		questionnaire.step, -- 3338
		"ask_user", -- 3338
		{status = "DONE", result = result} -- 3338
	) -- 3338
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3342
	upsertStep( -- 3343
		session.id, -- 3343
		questionnaire.taskId, -- 3343
		answerStep, -- 3343
		"questionnaire_answer", -- 3343
		{status = "DONE", result = result} -- 3343
	) -- 3343
	return {success = true, answerStep = answerStep, result = result} -- 3347
end -- 3273
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3350
	local session = getSessionItem(sessionId) -- 3351
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3351
		return {success = false, message = "project task admission is closed"} -- 3352
	end -- 3352
	if not session then -- 3352
		return {success = false, message = "session not found"} -- 3353
	end -- 3353
	if session.kind ~= "main" then -- 3353
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3354
	end -- 3354
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3355
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3355
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3357
	end -- 3357
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3359
	if not llmConfigRes.success then -- 3359
		return {success = false, message = llmConfigRes.message} -- 3360
	end -- 3360
	if not removePendingQuestionnaire(session) then -- 3360
		return {success = false, message = "failed to consume questionnaire file"} -- 3361
	end -- 3361
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3362
	if not replaced.success then -- 3362
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3364
		return replaced -- 3365
	end -- 3365
	local t = now() -- 3367
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3368
	session.workMode = "plan" -- 3369
	local result = startPromptTask( -- 3370
		session, -- 3370
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3370
		nil, -- 3370
		{}, -- 3370
		{ -- 3370
			workMode = "plan", -- 3371
			persistUserMessage = false, -- 3372
			resumeConversation = true, -- 3373
			existingTaskId = questionnaire.taskId, -- 3374
			initialStep = replaced.answerStep, -- 3375
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3376
			llmConfig = llmConfigRes.config -- 3377
		} -- 3377
	) -- 3377
	if not result.success then -- 3377
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3380
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3381
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3382
		emitAgentSessionPatch( -- 3383
			session.id, -- 3383
			{ -- 3383
				session = getSessionItem(session.id), -- 3384
				pendingQuestionnaire = questionnaire -- 3385
			} -- 3385
		) -- 3385
		return result -- 3387
	end -- 3387
	emitAgentSessionPatch( -- 3389
		sessionId, -- 3389
		{ -- 3389
			session = getSessionItem(sessionId), -- 3390
			pendingQuestionnaire = false -- 3391
		} -- 3391
	) -- 3391
	return result -- 3393
end -- 3350
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3396
	local session = getSessionItem(sessionId) -- 3397
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3397
		return {success = false, message = "project task admission is closed"} -- 3398
	end -- 3398
	if not session then -- 3398
		return {success = false, message = "session not found"} -- 3399
	end -- 3399
	if session.kind ~= "main" then -- 3399
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3400
	end -- 3400
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3401
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3401
		return {success = false, message = "pending questionnaire not found"} -- 3402
	end -- 3402
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3403
	if not validated.success then -- 3403
		return validated -- 3404
	end -- 3404
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3405
	if not llmConfigRes.success then -- 3405
		return {success = false, message = llmConfigRes.message} -- 3406
	end -- 3406
	local t = now() -- 3407
	if not removePendingQuestionnaire(session) then -- 3407
		return {success = false, message = "failed to consume questionnaire file"} -- 3408
	end -- 3408
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3409
	if not replaced.success then -- 3409
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3411
		return replaced -- 3412
	end -- 3412
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3414
	session.workMode = "plan" -- 3415
	local result = startPromptTask( -- 3416
		session, -- 3416
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3416
		nil, -- 3416
		{}, -- 3416
		{ -- 3416
			workMode = "plan", -- 3417
			persistUserMessage = false, -- 3418
			resumeConversation = true, -- 3419
			existingTaskId = questionnaire.taskId, -- 3420
			initialStep = replaced.answerStep, -- 3421
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3422
			llmConfig = llmConfigRes.config -- 3423
		} -- 3423
	) -- 3423
	if not result.success then -- 3423
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3426
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3427
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3428
		emitAgentSessionPatch( -- 3429
			session.id, -- 3429
			{ -- 3429
				session = getSessionItem(session.id), -- 3430
				pendingQuestionnaire = questionnaire -- 3431
			} -- 3431
		) -- 3431
		return result -- 3433
	end -- 3433
	emitAgentSessionPatch( -- 3435
		sessionId, -- 3435
		{ -- 3435
			session = getSessionItem(sessionId), -- 3436
			pendingQuestionnaire = false -- 3437
		} -- 3437
	) -- 3437
	return result -- 3439
end -- 3396
function ____exports.stopSessionTask(sessionId) -- 3442
	InputInbox.holdInputs(sessionId) -- 3443
	followup.publish(sessionId) -- 3444
	local session = getSessionItem(sessionId) -- 3445
	if not session or session.currentTaskId == nil then -- 3445
		return {success = false, message = "session task not found"} -- 3447
	end -- 3447
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3447
		return {success = false, message = "session task is finalizing"} -- 3450
	end -- 3450
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime) -- 3452
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3453
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3454
	if localControl ~= nil then -- 3454
		localControl:stop() -- 3456
		return {success = true, stopping = true} -- 3457
	end -- 3457
	local stopToken = activeStopTokens[session.currentTaskId] -- 3459
	if stopToken == nil then -- 3459
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3459
			return {success = true, recovered = true} -- 3462
		end -- 3462
		return {success = false, message = "task is not running"} -- 3464
	end -- 3464
	if stopToken.stopped then -- 3464
		return {success = true, stopping = true} -- 3467
	end -- 3467
	stopToken.stopped = true -- 3469
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3470
	return {success = true, stopping = true} -- 3474
end -- 3442
function ____exports.getCurrentTaskId(sessionId) -- 3477
	local ____opt_171 = getSessionItem(sessionId) -- 3477
	return ____opt_171 and ____opt_171.currentTaskId -- 3478
end -- 3477
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3482
	local owner = getSessionItem(sessionId) -- 3483
	if not owner then -- 3483
		return {success = false, message = "session not found"} -- 3484
	end -- 3484
	local projectRoot = owner.projectRoot -- 3485
	local release = holdProjectTaskAdmission(projectRoot) -- 3486
	local closed = false -- 3487
	return { -- 3488
		success = true, -- 3489
		projectRoot = projectRoot, -- 3490
		close = function() -- 3491
			if not closed then -- 3491
				closed = true -- 3491
				release() -- 3491
			end -- 3491
		end, -- 3491
		poll = function() -- 3492
			if closed then -- 3492
				return {success = false, message = "quiescence handle closed"} -- 3493
			end -- 3493
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3494
			if not rows then -- 3494
				return {success = false, message = "failed to inspect project tasks"} -- 3495
			end -- 3495
			local pending = {} -- 3496
			for ____, row in ipairs(rows) do -- 3497
				do -- 3497
					local session = rowToSession(row) -- 3498
					local taskId = session.currentTaskId -- 3499
					if taskId == nil then -- 3499
						goto __continue634 -- 3500
					end -- 3500
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3501
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3501
						goto __continue634 -- 3502
					end -- 3502
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3504
					local ____session_id_174 = session.id -- 3505
					local ____taskId_175 = taskId -- 3505
					local ____finalizing_176 = finalizing -- 3505
					local ____result_success_177 = result.success -- 3505
					local ____result_success_173 -- 3505
					if result.success then -- 3505
						____result_success_173 = nil -- 3505
					else -- 3505
						____result_success_173 = result.message -- 3505
					end -- 3505
					pending[#pending + 1] = { -- 3505
						sessionId = ____session_id_174, -- 3505
						taskId = ____taskId_175, -- 3505
						finalizing = ____finalizing_176, -- 3505
						stopRequested = ____result_success_177, -- 3505
						message = ____result_success_173 -- 3505
					} -- 3505
				end -- 3505
				::__continue634:: -- 3505
			end -- 3505
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3509
		end -- 3492
	} -- 3492
end -- 3482
function ____exports.validateTaskAccess(sessionId, taskId) -- 3514
	local session = getSessionItem(sessionId) -- 3515
	if not session then -- 3515
		return {success = false, message = "session not found"} -- 3516
	end -- 3516
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3516
		getSessionOperableTaskIds(sessionId), -- 3517
		taskId -- 3517
	) < 0 then -- 3517
		return {success = false, message = "task is not operable for this session"} -- 3518
	end -- 3518
	return {success = true, session = session} -- 3520
end -- 3514
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3523
	if checkpointId <= 0 then -- 3523
		return {success = false, message = "invalid checkpointId"} -- 3525
	end -- 3525
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3527
	if not checkpoint then -- 3527
		return {success = false, message = "checkpoint not found"} -- 3529
	end -- 3529
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3531
	if not taskAccess.success then -- 3531
		return taskAccess -- 3532
	end -- 3532
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3533
end -- 3523
function ____exports.listRunningSessions() -- 3536
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3537
	local sessions = {} -- 3544
	do -- 3544
		local i = 0 -- 3545
		while i < #rows do -- 3545
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3546
			if session.currentTaskStatus == "RUNNING" then -- 3546
				sessions[#sessions + 1] = session -- 3548
			end -- 3548
			i = i + 1 -- 3545
		end -- 3545
	end -- 3545
	return {success = true, sessions = sessions} -- 3551
end -- 3536
return ____exports -- 3536
