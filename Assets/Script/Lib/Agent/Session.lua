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
local TeamWake = require("Agent.Runtime.TeamWake") -- 14
local Tools = require("Agent.Tools") -- 15
local ____Database = require("Agent.Storage.Database") -- 16
local TABLE_SESSION = ____Database.TABLE_SESSION -- 17
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE -- 18
local TABLE_STEP = ____Database.TABLE_STEP -- 19
local TABLE_TASK = ____Database.TABLE_TASK -- 20
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE -- 21
local addTaskReference = ____Database.addTaskReference -- 22
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData -- 23
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds -- 24
local requireAgentStorage = ____Database.requireAgentStorage -- 25
local InputInbox = require("Agent.Runtime.InputInbox") -- 27
local ____Memory = require("Agent.Runtime.Memory") -- 29
local DualLayerStorage = ____Memory.DualLayerStorage -- 29
local ____Utils = require("Agent.Utils") -- 30
local Log = ____Utils.Log -- 30
local getLLMConfig = ____Utils.getLLMConfig -- 30
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport -- 30
local safeJsonDecode = ____Utils.safeJsonDecode -- 30
local safeJsonEncode = ____Utils.safeJsonEncode -- 30
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 30
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig -- 30
local ____Questionnaire = require("Agent.Runtime.Questionnaire") -- 34
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers -- 34
local ____Support = require("Agent.Storage.Support") -- 36
local getLastInsertRowId = ____Support.getLastInsertRowId -- 36
local queryOne = ____Support.queryOne -- 36
local queryRows = ____Support.queryRows -- 36
local toStr = ____Support.toStr -- 36
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, submission) -- 424
	return followup.submit( -- 426
		sessionId, -- 426
		prompt, -- 426
		{disabledAgentTools = disabledAgentTools, workMode = workMode, llmConfigId = llmConfigId, maxSteps = maxSteps}, -- 426
		{llmConfig = llmConfig, llmConfigId = llmConfigId}, -- 427
		submission -- 427
	) -- 427
end -- 424
function scheduleStreamFlush() -- 505
	if streamFlushScheduled or not streamUpdates:hasPending() then -- 505
		return -- 506
	end -- 506
	streamFlushScheduled = true -- 507
	Director.systemScheduler:schedule(function() -- 508
		streamUpdates:flushDue(App.runningTime) -- 509
		if streamUpdates:hasPending() then -- 509
			return false -- 510
		end -- 510
		streamFlushScheduled = false -- 511
		return true -- 512
	end) -- 508
end -- 508
function getDefaultUseChineseResponse() -- 526
	local zh = string.match(App.locale, "^zh") -- 527
	return zh ~= nil -- 528
end -- 528
function encodeJson(value) -- 531
	local text = safeJsonEncode(value) -- 532
	return text or "" -- 533
end -- 533
function decodeJsonObject(text) -- 536
	if text == "" then -- 536
		return nil -- 537
	end -- 537
	local value = safeJsonDecode(text) -- 538
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 538
		return value -- 540
	end -- 540
	return nil -- 542
end -- 542
function decodeJsonFiles(text) -- 545
	if text == "" then -- 545
		return nil -- 546
	end -- 546
	local value = safeJsonDecode(text) -- 547
	if not value or not __TS__ArrayIsArray(value) then -- 547
		return nil -- 548
	end -- 548
	local files = {} -- 549
	do -- 549
		local i = 0 -- 550
		while i < #value do -- 550
			do -- 550
				local item = value[i + 1] -- 551
				if type(item) ~= "table" then -- 551
					goto __continue78 -- 552
				end -- 552
				files[#files + 1] = { -- 553
					path = sanitizeUTF8(toStr(item.path)), -- 554
					op = sanitizeUTF8(toStr(item.op)) -- 555
				} -- 555
			end -- 555
			::__continue78:: -- 555
			i = i + 1 -- 550
		end -- 550
	end -- 550
	return files -- 558
end -- 558
function decodeChangeSetSummary(value) -- 561
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 561
		return nil -- 562
	end -- 562
	local row = value -- 563
	if row.success ~= true then -- 563
		return nil -- 564
	end -- 564
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 565
	if taskId <= 0 then -- 565
		return nil -- 566
	end -- 566
	local files = {} -- 567
	if __TS__ArrayIsArray(row.files) then -- 567
		do -- 567
			local i = 0 -- 569
			while i < #row.files do -- 569
				do -- 569
					local file = row.files[i + 1] -- 570
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 570
						goto __continue86 -- 571
					end -- 571
					local fileRow = file -- 572
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 573
					if path == "" then -- 573
						goto __continue86 -- 574
					end -- 574
					local checkpointIds = {} -- 575
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 575
						do -- 575
							local j = 0 -- 577
							while j < #fileRow.checkpointIds do -- 577
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 578
								if checkpointId > 0 then -- 578
									checkpointIds[#checkpointIds + 1] = checkpointId -- 579
								end -- 579
								j = j + 1 -- 577
							end -- 577
						end -- 577
					end -- 577
					local op = toStr(fileRow.op) -- 582
					files[#files + 1] = { -- 583
						path = path, -- 584
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 585
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 586
						checkpointIds = checkpointIds -- 587
					} -- 587
				end -- 587
				::__continue86:: -- 587
				i = i + 1 -- 569
			end -- 569
		end -- 569
	end -- 569
	return { -- 591
		success = true, -- 592
		taskId = taskId, -- 593
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 594
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 595
		files = files, -- 596
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 597
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 598
	} -- 598
end -- 598
function decodeHandoffEvidence(value) -- 602
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 602
		return nil -- 603
	end -- 603
	local row = value -- 604
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 605
		__TS__ArrayFilter( -- 606
			row.modifiedFiles, -- 606
			function(____, item) return type(item) == "string" end -- 606
		), -- 606
		function(____, item) return sanitizeUTF8(item) end -- 606
	) or ({}) -- 606
	local lastBuild = nil -- 608
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 608
		local build = row.lastBuild -- 610
		lastBuild = { -- 611
			result = build.result == "passed" and "passed" or "failed", -- 612
			path = sanitizeUTF8(toStr(build.path)), -- 613
			evidence = takeUtf8Head( -- 614
				sanitizeUTF8(toStr(build.evidence)), -- 614
				600 -- 614
			) -- 614
		} -- 614
	end -- 614
	local commands = {} -- 617
	if __TS__ArrayIsArray(row.commands) then -- 617
		do -- 617
			local i = 0 -- 619
			while i < #row.commands and #commands < 8 do -- 619
				do -- 619
					local raw = row.commands[i + 1] -- 620
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 620
						goto __continue100 -- 621
					end -- 621
					local item = raw -- 622
					commands[#commands + 1] = { -- 623
						mode = sanitizeUTF8(toStr(item.mode)), -- 624
						command = takeUtf8Head( -- 625
							sanitizeUTF8(toStr(item.command)), -- 625
							600 -- 625
						), -- 625
						result = item.result == "passed" and "passed" or "failed", -- 626
						evidence = takeUtf8Head( -- 627
							sanitizeUTF8(toStr(item.evidence)), -- 627
							600 -- 627
						) -- 627
					} -- 627
				end -- 627
				::__continue100:: -- 627
				i = i + 1 -- 619
			end -- 619
		end -- 619
	end -- 619
	local authoritativeSources = {} -- 631
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 631
		do -- 631
			local i = 0 -- 633
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 633
				do -- 633
					local raw = row.authoritativeSources[i + 1] -- 634
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 634
						goto __continue104 -- 635
					end -- 635
					local item = raw -- 636
					authoritativeSources[#authoritativeSources + 1] = { -- 637
						tool = "search_dora_doc", -- 638
						query = takeUtf8Head( -- 639
							sanitizeUTF8(toStr(item.query)), -- 639
							300 -- 639
						), -- 639
						source = sanitizeUTF8(toStr(item.source)), -- 640
						result = item.result == "passed" and "passed" or "failed" -- 641
					} -- 641
				end -- 641
				::__continue104:: -- 641
				i = i + 1 -- 633
			end -- 633
		end -- 633
	end -- 633
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 645
end -- 645
function takeUtf8Head(text, maxChars) -- 648
	if maxChars <= 0 or text == "" then -- 648
		return "" -- 649
	end -- 649
	local nextPos = utf8.offset(text, maxChars + 1) -- 650
	if nextPos == nil then -- 650
		return text -- 651
	end -- 651
	return string.sub(text, 1, nextPos - 1) -- 652
end -- 652
function normalizeMemoryEntryEvidence(value) -- 655
	local evidence = {} -- 656
	if not __TS__ArrayIsArray(value) then -- 656
		return evidence -- 657
	end -- 657
	do -- 657
		local i = 0 -- 658
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 658
			do -- 658
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 659
				if item == "" then -- 659
					goto __continue112 -- 660
				end -- 660
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 660
					evidence[#evidence + 1] = item -- 662
				end -- 662
			end -- 662
			::__continue112:: -- 662
			i = i + 1 -- 658
		end -- 658
	end -- 658
	return evidence -- 665
end -- 665
function decodeSubAgentMemoryEntry(value) -- 668
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 668
		return nil -- 669
	end -- 669
	local row = value -- 670
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 671
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 672
	local content = takeUtf8Head( -- 673
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 673
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 673
	) -- 673
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 673
		return nil -- 674
	end -- 674
	return { -- 675
		sourceSessionId = sourceSessionId, -- 676
		sourceTaskId = sourceTaskId, -- 677
		content = content, -- 678
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 679
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 680
	} -- 680
end -- 680
function getTaskChangeSetSummary(taskId) -- 684
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 685
	return summary.success and summary or nil -- 686
end -- 686
function summarizeHandoffResult(result) -- 689
	local candidates = {result.output, result.message, result.state, result.phase} -- 690
	do -- 690
		local i = 0 -- 691
		while i < #candidates do -- 691
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 692
			if text ~= "" then -- 692
				return takeUtf8Head(text, 600) -- 693
			end -- 693
			i = i + 1 -- 691
		end -- 691
	end -- 691
	local messages = result.messages -- 695
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 695
		local parts = {} -- 697
		do -- 697
			local i = 0 -- 698
			while i < #messages and #parts < 4 do -- 698
				do -- 698
					local row = messages[i + 1] -- 699
					if not row or type(row) ~= "table" then -- 699
						goto __continue125 -- 700
					end -- 700
					local item = row -- 701
					local ____sanitizeUTF8_33 = sanitizeUTF8 -- 702
					local ____toStr_32 = toStr -- 702
					local ____item_message_30 = item.message -- 702
					if ____item_message_30 == nil then -- 702
						____item_message_30 = item.error -- 702
					end -- 702
					local ____item_message_30_31 = ____item_message_30 -- 702
					if ____item_message_30_31 == nil then -- 702
						____item_message_30_31 = item.file -- 702
					end -- 702
					local text = __TS__StringTrim(____sanitizeUTF8_33(____toStr_32(____item_message_30_31))) -- 702
					if text ~= "" then -- 702
						parts[#parts + 1] = text -- 703
					end -- 703
				end -- 703
				::__continue125:: -- 703
				i = i + 1 -- 698
			end -- 698
		end -- 698
		if #parts > 0 then -- 698
			return takeUtf8Head( -- 705
				table.concat(parts, "; "), -- 705
				600 -- 705
			) -- 705
		end -- 705
	end -- 705
	return result.success == true and "tool result success=true" or "tool result success=false" -- 707
end -- 707
function getTaskHandoffEvidence(taskId, changeSet) -- 710
	local ____opt_34 = changeSet -- 710
	local evidence = { -- 711
		modifiedFiles = ____opt_34 and __TS__ArrayMap( -- 712
			changeSet and changeSet.files, -- 712
			function(____, item) return item.path end -- 712
		) or ({}), -- 712
		commands = {}, -- 713
		authoritativeSources = {} -- 714
	} -- 714
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 716
	do -- 716
		local i = 0 -- 721
		while i < #rows do -- 721
			local tool = toStr(rows[i + 1][1]) -- 722
			local status = toStr(rows[i + 1][2]) -- 723
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 724
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 725
			local passed = status == "DONE" and result.success == true -- 726
			if tool == "build" then -- 726
				evidence.lastBuild = { -- 728
					result = passed and "passed" or "failed", -- 729
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 730
					evidence = summarizeHandoffResult(result) -- 731
				} -- 731
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 731
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 734
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 735
				local ____evidence_commands_38 = evidence.commands -- 735
				____evidence_commands_38[#____evidence_commands_38 + 1] = { -- 736
					mode = mode, -- 737
					command = takeUtf8Head( -- 738
						__TS__StringTrim(sanitizeUTF8(command)), -- 738
						600 -- 738
					), -- 738
					result = passed and "passed" or "failed", -- 739
					evidence = summarizeHandoffResult(result) -- 740
				} -- 740
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 740
				local ____evidence_authoritativeSources_39 = evidence.authoritativeSources -- 740
				____evidence_authoritativeSources_39[#____evidence_authoritativeSources_39 + 1] = { -- 743
					tool = "search_dora_doc", -- 744
					query = takeUtf8Head( -- 745
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 745
						300 -- 745
					), -- 745
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 746
					result = passed and "passed" or "failed" -- 747
				} -- 747
			end -- 747
			i = i + 1 -- 721
		end -- 721
	end -- 721
	return evidence -- 751
end -- 751
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 754
	local lastBuild = evidence.lastBuild -- 758
	if not lastBuild or lastBuild.result ~= "failed" then -- 758
		return completion -- 759
	end -- 759
	local validation = __TS__ArraySlice(completion.validation) -- 760
	local foundBuild = false -- 761
	do -- 761
		local i = 0 -- 762
		while i < #validation do -- 762
			do -- 762
				if validation[i + 1].kind ~= "build" then -- 762
					goto __continue139 -- 763
				end -- 763
				foundBuild = true -- 764
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 765
			end -- 765
			::__continue139:: -- 765
			i = i + 1 -- 762
		end -- 762
	end -- 762
	if not foundBuild then -- 762
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 772
	end -- 772
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 774
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 775
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 775
		knownIssues[#knownIssues + 1] = issue -- 776
	end -- 776
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 777
end -- 777
function isValidProjectRoot(path) -- 785
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 786
end -- 786
function rowToSession(row) -- 789
	return { -- 790
		id = row[1], -- 791
		projectRoot = toStr(row[2]), -- 792
		title = toStr(row[3]), -- 793
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 794
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 795
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 796
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 797
		status = toStr(row[8]), -- 798
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 799
		currentTaskStatus = toStr(row[10]), -- 800
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 801
		createdAt = row[11], -- 802
		updatedAt = row[12], -- 803
		metrics = decodeSessionMetrics(toStr(row[13])), -- 804
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 805
	} -- 805
end -- 805
function rowToMessage(row) -- 809
	local message = { -- 810
		id = row[1], -- 811
		sessionId = row[2], -- 812
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 813
		role = toStr(row[4]), -- 814
		content = toStr(row[5]), -- 815
		createdAt = row[7], -- 816
		updatedAt = row[8] -- 817
	} -- 817
	local displayContent = toStr(row[6]) -- 819
	if displayContent ~= "" then -- 819
		message.displayContent = displayContent -- 820
	end -- 820
	local receipt = queryOne("SELECT delivery,delivered_step FROM agent.AgentSessionInput WHERE message_id=? AND status='delivered'", {message.id}) -- 821
	if (receipt and receipt[1]) == "steer" then -- 821
		message.inputKind = "steer" -- 822
		message.afterStep = type(receipt[2]) == "number" and receipt[2] or 0 -- 822
	end -- 822
	return message -- 823
end -- 823
function rowToStep(row) -- 826
	return { -- 827
		id = row[1], -- 828
		sessionId = row[2], -- 829
		taskId = row[3], -- 830
		step = row[4], -- 831
		tool = toStr(row[5]), -- 832
		status = toStr(row[6]), -- 833
		reason = toStr(row[7]), -- 834
		reasoningContent = toStr(row[8]), -- 835
		params = decodeJsonObject(toStr(row[9])), -- 836
		result = decodeJsonObject(toStr(row[10])), -- 837
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 838
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 839
		files = decodeJsonFiles(toStr(row[13])), -- 840
		createdAt = row[14], -- 841
		updatedAt = row[15] -- 842
	} -- 842
end -- 842
function getQuestionnairePath(projectRoot) -- 846
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 847
end -- 847
function decodeQuestionnaireFile(text) -- 850
	local value = decodeJsonObject(text) -- 851
	if not value then -- 851
		return nil -- 852
	end -- 852
	local schema = value.schema -- 853
	local id = type(value.id) == "number" and value.id or 0 -- 854
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 855
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 856
	local step = type(value.step) == "number" and value.step or 0 -- 857
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 858
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 858
		return nil -- 860
	end -- 860
	return { -- 862
		id = id, -- 862
		sessionId = sessionId, -- 862
		taskId = taskId, -- 862
		step = step, -- 862
		status = "PENDING", -- 862
		schema = schema, -- 862
		createdAt = createdAt -- 862
	} -- 862
end -- 862
function getPendingQuestionnaire(sessionId) -- 865
	local session = getSessionItem(sessionId) -- 866
	if not session or session.kind ~= "main" then -- 866
		return nil -- 867
	end -- 867
	local path = getQuestionnairePath(session.projectRoot) -- 868
	if not Content:exist(path) then -- 868
		return nil -- 869
	end -- 869
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 870
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 871
end -- 871
function restorePendingQuestionnaireState(session) -- 874
	local questionnaire = getPendingQuestionnaire(session.id) -- 875
	if not questionnaire then -- 875
		return {session = session} -- 876
	end -- 876
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 876
		local t = now() -- 883
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 884
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 890
		local restored = getSessionItem(session.id) -- 891
		if restored then -- 891
			session = restored -- 892
		end -- 892
	end -- 892
	return {session = session, questionnaire = questionnaire} -- 894
end -- 894
function savePendingQuestionnaire(projectRoot, questionnaire) -- 897
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 898
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 898
		return false -- 899
	end -- 899
	local path = getQuestionnairePath(projectRoot) -- 900
	local tempPath = path .. ".tmp" -- 901
	local backupPath = path .. ".bak" -- 902
	Content:remove(tempPath) -- 903
	Content:remove(backupPath) -- 904
	if not Content:save( -- 904
		tempPath, -- 905
		encodeJson(questionnaire) -- 905
	) then -- 905
		return false -- 905
	end -- 905
	local hadOriginal = Content:exist(path) -- 906
	if hadOriginal and not Content:move(path, backupPath) then -- 906
		Content:remove(tempPath) -- 908
		return false -- 909
	end -- 909
	if Content:move(tempPath, path) then -- 909
		Content:remove(backupPath) -- 912
		Tools.sendWebIDEFileUpdate( -- 913
			path, -- 913
			true, -- 913
			encodeJson(questionnaire) -- 913
		) -- 913
		return true -- 914
	end -- 914
	Content:remove(tempPath) -- 916
	if hadOriginal and Content:exist(backupPath) then -- 916
		Content:move(backupPath, path) -- 918
	end -- 918
	return false -- 920
end -- 920
function removePendingQuestionnaire(session) -- 923
	local path = getQuestionnairePath(session.projectRoot) -- 924
	if not Content:exist(path) then -- 924
		return true -- 925
	end -- 925
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 926
	if questionnaire and questionnaire.sessionId ~= session.id then -- 926
		return false -- 927
	end -- 927
	if not Content:remove(path) then -- 927
		return false -- 928
	end -- 928
	Tools.sendWebIDEFileUpdate(path, false, "") -- 929
	return true -- 930
end -- 930
function publishQuestionnaire(request) -- 933
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 933
		local session = getSessionItem(request.sessionId) -- 939
		if not session or session.kind ~= "main" then -- 939
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 939
		end -- 939
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 941
		if Content:exist(pendingPath) then -- 941
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 941
		end -- 941
		local questionnaire = { -- 943
			id = request.taskId, -- 944
			sessionId = request.sessionId, -- 945
			taskId = request.taskId, -- 946
			step = request.step, -- 947
			status = "PENDING", -- 948
			schema = request.schema, -- 949
			createdAt = now() -- 950
		} -- 950
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 950
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 950
		end -- 950
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 950
	end) -- 950
end -- 950
function getMessageItem(messageId) -- 958
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 959
	return row and rowToMessage(row) or nil -- 965
end -- 965
function getStepItem(sessionId, taskId, step) -- 968
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 969
	return row and rowToStep(row) or nil -- 975
end -- 975
function deleteMessageSteps(sessionId, taskId) -- 978
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 979
	local ids = {} -- 984
	do -- 984
		local i = 0 -- 985
		while i < #rows do -- 985
			local row = rows[i + 1] -- 986
			if type(row[1]) == "number" then -- 986
				ids[#ids + 1] = row[1] -- 988
			end -- 988
			i = i + 1 -- 985
		end -- 985
	end -- 985
	if #ids > 0 then -- 985
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 992
	end -- 992
	return ids -- 998
end -- 998
function normalizeDisabledAgentTools(value) -- 1001
	if not __TS__ArrayIsArray(value) then -- 1001
		return {} -- 1002
	end -- 1002
	local tools = {} -- 1003
	do -- 1003
		local i = 0 -- 1004
		while i < #value do -- 1004
			do -- 1004
				local name = value[i + 1] -- 1005
				if name == "edit_file" and __TS__ArrayIndexOf(tools, "write_file") < 0 then -- 1005
					tools[#tools + 1] = "write_file" -- 1006
				end -- 1006
				if name == "delete_file" then -- 1006
					name = "edit_file" -- 1007
				end -- 1007
				if name == "glob_files" then -- 1007
					name = "grep_files" -- 1008
				end -- 1008
				if name == "spawn_sub_agent" or name == "list_sub_agents" then -- 1008
					name = "spawn_agent" -- 1009
				end -- 1009
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 1009
					goto __continue184 -- 1010
				end -- 1010
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 1010
					tools[#tools + 1] = name -- 1011
				end -- 1011
			end -- 1011
			::__continue184:: -- 1011
			i = i + 1 -- 1004
		end -- 1004
	end -- 1004
	return tools -- 1013
end -- 1013
function normalizeWorkMode(value, fallback) -- 1016
	if fallback == nil then -- 1016
		fallback = "code" -- 1016
	end -- 1016
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 1017
end -- 1017
function getSessionRow(sessionId) -- 1020
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 1021
end -- 1021
function getPendingSessionInputs(sessionId) -- 1029
	return __TS__ArrayMap( -- 1032
		__TS__ArrayFilter( -- 1032
			InputInbox.listInputs(sessionId), -- 1032
			function(____, item) return item.status ~= "delivering" end -- 1032
		), -- 1032
		function(____, item) return { -- 1033
			id = item.id, -- 1033
			content = item.content, -- 1033
			delivery = item.delivery, -- 1033
			held = item.held, -- 1033
			status = item.status -- 1033
		} end -- 1033
	) -- 1033
end -- 1033
function getSessionItem(sessionId) -- 1036
	local row = getSessionRow(sessionId) -- 1037
	if not row then -- 1037
		return nil -- 1038
	end -- 1038
	local session = rowToSession(row) -- 1039
	session.pendingInputs = getPendingSessionInputs(session.id) -- 1040
	return session -- 1041
end -- 1041
function getTaskPrompt(taskId) -- 1044
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1045
	if not row or type(row[1]) ~= "string" then -- 1045
		return nil -- 1046
	end -- 1046
	return toStr(row[1]) -- 1047
end -- 1047
function getLatestMainSessionByProjectRoot(projectRoot) -- 1050
	if not isValidProjectRoot(projectRoot) then -- 1050
		return nil -- 1051
	end -- 1051
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1052
	if not row then -- 1052
		return nil -- 1060
	end -- 1060
	local session = rowToSession(row) -- 1061
	session.pendingInputs = getPendingSessionInputs(session.id) -- 1062
	return session -- 1063
end -- 1063
function countRunningSubSessions(rootSessionId) -- 1066
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 1067
	local count = 0 -- 1074
	do -- 1074
		local i = 0 -- 1075
		while i < #rows do -- 1075
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1076
			if session.currentTaskStatus == "RUNNING" then -- 1076
				count = count + 1 -- 1078
			end -- 1078
			i = i + 1 -- 1075
		end -- 1075
	end -- 1075
	return count -- 1081
end -- 1081
function deleteSessionRecords(sessionId, preserveArtifacts) -- 1084
	if preserveArtifacts == nil then -- 1084
		preserveArtifacts = false -- 1084
	end -- 1084
	for ____, input in ipairs(InputInbox.listInputs(sessionId, true)) do -- 1085
		__TS__Delete(followup.configs, input.id) -- 1085
	end -- 1085
	DB:exec("DELETE FROM agent.AgentSessionInput WHERE session_id=?", {sessionId}) -- 1086
	__TS__Delete(followup.bindings, sessionId) -- 1087
	__TS__Delete(followup.recovered, sessionId) -- 1088
	streamUpdates:clear(sessionId) -- 1089
	local session = getSessionItem(sessionId) -- 1090
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 1091
	local taskIds = {} -- 1099
	do -- 1099
		local i = 0 -- 1100
		while i < #taskRows do -- 1100
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 1101
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 1101
				taskIds[#taskIds + 1] = taskId -- 1103
				local stopToken = activeStopTokens[taskId] -- 1104
				if stopToken ~= nil then -- 1104
					stopToken.stopped = true -- 1106
					stopToken.reason = "session deleted" -- 1107
				end -- 1107
			end -- 1107
			i = i + 1 -- 1100
		end -- 1100
	end -- 1100
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 1111
	do -- 1111
		local i = 0 -- 1112
		while i < #children do -- 1112
			local row = children[i + 1] -- 1113
			if type(row[1]) == "number" and row[1] > 0 then -- 1113
				deleteSessionRecords(row[1], preserveArtifacts) -- 1115
			end -- 1115
			i = i + 1 -- 1112
		end -- 1112
	end -- 1112
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 1118
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 1119
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 1120
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 1121
	if session and session.kind == "main" then -- 1121
		removePendingQuestionnaire(session) -- 1123
	end -- 1123
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 1123
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 1123
			Tools.sendWebIDERefreshTree() -- 1127
		end -- 1127
	end -- 1127
	do -- 1127
		local i = 0 -- 1130
		while i < #taskIds do -- 1130
			cleanupTaskHeavyData(taskIds[i + 1]) -- 1131
			i = i + 1 -- 1130
		end -- 1130
	end -- 1130
end -- 1130
function getSessionRootId(session) -- 1135
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 1136
end -- 1136
function getRootSessionItem(sessionId) -- 1139
	local session = getSessionItem(sessionId) -- 1140
	if not session then -- 1140
		return nil -- 1141
	end -- 1141
	return getSessionItem(getSessionRootId(session)) or session -- 1142
end -- 1142
function listRelatedSessions(sessionId) -- 1145
	local root = getRootSessionItem(sessionId) -- 1146
	if not root then -- 1146
		return {} -- 1147
	end -- 1147
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 1148
	return __TS__ArrayMap( -- 1157
		rows, -- 1157
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 1157
	) -- 1157
end -- 1157
function getSessionSpawnInfo(session) -- 1160
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1161
	if not info then -- 1161
		return nil -- 1162
	end -- 1162
	local ____temp_47 = type(info.sessionId) == "number" and info.sessionId or nil -- 1164
	local ____temp_48 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 1165
	local ____temp_49 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 1166
	local ____temp_50 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 1167
	local ____temp_51 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 1168
	local ____temp_52 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 1169
	local ____temp_53 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 1170
	local ____temp_54 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1171
		__TS__ArrayFilter( -- 1172
			info.filesHint, -- 1172
			function(____, item) return type(item) == "string" end -- 1172
		), -- 1172
		function(____, item) return sanitizeUTF8(item) end -- 1172
	) or nil -- 1172
	local ____temp_55 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 1174
	local ____temp_45 -- 1177
	if info.success == true then -- 1177
		____temp_45 = true -- 1177
	else -- 1177
		local ____temp_44 -- 1177
		if info.success == false then -- 1177
			____temp_44 = false -- 1177
		else -- 1177
			____temp_44 = nil -- 1177
		end -- 1177
		____temp_45 = ____temp_44 -- 1177
	end -- 1177
	local ____temp_46 -- 1178
	if info.cleared == true then -- 1178
		____temp_46 = true -- 1178
	else -- 1178
		____temp_46 = nil -- 1178
	end -- 1178
	return { -- 1163
		sessionId = ____temp_47, -- 1164
		rootSessionId = ____temp_48, -- 1165
		parentSessionId = ____temp_49, -- 1166
		title = ____temp_50, -- 1167
		prompt = ____temp_51, -- 1168
		goal = ____temp_52, -- 1169
		expectedOutput = ____temp_53, -- 1170
		filesHint = ____temp_54, -- 1171
		status = ____temp_55, -- 1174
		success = ____temp_45, -- 1177
		cleared = ____temp_46, -- 1178
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 1179
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 1180
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 1181
		changeSet = decodeChangeSetSummary(info.changeSet), -- 1182
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1183
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1184
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 1185
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 1186
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 1189
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 1190
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 1191
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 1192
	} -- 1192
end -- 1192
function ensureDirRecursive(dir) -- 1209
	if dir == "" then -- 1209
		return false -- 1210
	end -- 1210
	if Content:exist(dir) then -- 1210
		return Content:isdir(dir) -- 1211
	end -- 1211
	local parent = Path:getPath(dir) -- 1212
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1212
		if not ensureDirRecursive(parent) then -- 1212
			return false -- 1215
		end -- 1215
	end -- 1215
	return Content:mkdir(dir) -- 1218
end -- 1218
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1221
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1222
	if not Content:exist(dir) then -- 1222
		ensureDirRecursive(dir) -- 1224
	end -- 1224
	local path = Path(dir, SPAWN_INFO_FILE) -- 1226
	local text = safeJsonEncode(value) -- 1227
	if not text then -- 1227
		return false -- 1228
	end -- 1228
	local content = text .. "\n" -- 1229
	if not Content:save(path, content) then -- 1229
		return false -- 1231
	end -- 1231
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1233
	return true -- 1234
end -- 1234
function readSpawnInfo(projectRoot, memoryScope) -- 1237
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1238
	if not Content:exist(path) then -- 1238
		return nil -- 1239
	end -- 1239
	local text = Content:load(path) -- 1240
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1240
		return nil -- 1241
	end -- 1241
	local value = safeJsonDecode(text) -- 1242
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1242
		return value -- 1244
	end -- 1244
	return nil -- 1246
end -- 1246
function getArtifactRelativeDir(memoryScope) -- 1249
	return Path(".agent", memoryScope) -- 1250
end -- 1250
function getArtifactDir(projectRoot, memoryScope) -- 1253
	return Path( -- 1254
		projectRoot, -- 1254
		getArtifactRelativeDir(memoryScope) -- 1254
	) -- 1254
end -- 1254
function getResultRelativePath(memoryScope) -- 1257
	return Path( -- 1258
		getArtifactRelativeDir(memoryScope), -- 1258
		RESULT_FILE -- 1258
	) -- 1258
end -- 1258
function getResultPath(projectRoot, memoryScope) -- 1261
	return Path( -- 1262
		projectRoot, -- 1262
		getResultRelativePath(memoryScope) -- 1262
	) -- 1262
end -- 1262
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1265
	if resultFilePath == "" then -- 1265
		return "" -- 1266
	end -- 1266
	local path = Path(projectRoot, resultFilePath) -- 1267
	if not Content:exist(path) then -- 1267
		return "" -- 1268
	end -- 1268
	local text = sanitizeUTF8(Content:load(path)) -- 1269
	if __TS__StringTrim(text) == "" then -- 1269
		return "" -- 1270
	end -- 1270
	local marker = "\n## Summary\n" -- 1271
	local start = string.find(text, marker, 1, true) -- 1272
	if start ~= nil then -- 1272
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1274
	end -- 1274
	return __TS__StringTrim(text) -- 1276
end -- 1276
function buildStructuredSubAgentMemoryEntry(record) -- 1279
	local hasPassedValidation = false -- 1280
	do -- 1280
		local i = 0 -- 1281
		while i < #record.completion.validation do -- 1281
			local result = record.completion.validation[i + 1].result -- 1282
			if result == "failed" then -- 1282
				return nil -- 1287
			end -- 1287
			if result == "passed" then -- 1287
				hasPassedValidation = true -- 1289
			end -- 1289
			i = i + 1 -- 1281
		end -- 1281
	end -- 1281
	if not hasPassedValidation then -- 1281
		return nil -- 1292
	end -- 1292
	local candidates = record.completion.learningCandidates -- 1293
	local claims = {} -- 1294
	local evidence = {} -- 1295
	do -- 1295
		local i = 0 -- 1296
		while i < #candidates do -- 1296
			do -- 1296
				local candidate = candidates[i + 1] -- 1297
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1297
					goto __continue266 -- 1298
				end -- 1298
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1299
				do -- 1299
					local j = 0 -- 1300
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1300
						local item = candidate.evidence[j + 1] -- 1301
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1301
							evidence[#evidence + 1] = item -- 1302
						end -- 1302
						j = j + 1 -- 1300
					end -- 1300
				end -- 1300
			end -- 1300
			::__continue266:: -- 1300
			i = i + 1 -- 1296
		end -- 1296
	end -- 1296
	local content = takeUtf8Head( -- 1305
		table.concat(claims, "\n"), -- 1305
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1305
	) -- 1305
	if content == "" then -- 1305
		return nil -- 1306
	end -- 1306
	return { -- 1307
		sourceSessionId = record.sessionId, -- 1308
		sourceTaskId = record.sourceTaskId, -- 1309
		content = content, -- 1310
		evidence = evidence, -- 1311
		createdAt = record.finishedAt -- 1312
	} -- 1312
end -- 1312
function containsNormalizedText(text, query) -- 1316
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1317
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1318
	if normalizedQuery == "" then -- 1318
		return true -- 1319
	end -- 1319
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1320
end -- 1320
function getSubAgentDisplayKey(item) -- 1323
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1329
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1330
	local label = goal ~= "" and goal or title -- 1331
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1332
end -- 1332
function writeSubAgentResultFile(session, record, resultText) -- 1335
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1336
	if not Content:exist(dir) then -- 1336
		ensureDirRecursive(dir) -- 1338
	end -- 1338
	local ____array_64 = __TS__SparseArrayNew( -- 1338
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1341
		"- Status: " .. record.status, -- 1342
		"- Success: " .. (record.success and "true" or "false"), -- 1343
		"- Outcome: " .. record.completion.outcome, -- 1344
		"- Session ID: " .. tostring(record.sessionId), -- 1345
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1346
		"- Goal: " .. record.goal, -- 1347
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1348
	) -- 1348
	__TS__SparseArrayPush( -- 1348
		____array_64, -- 1348
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1349
	) -- 1349
	__TS__SparseArrayPush( -- 1349
		____array_64, -- 1349
		"- Finished At: " .. record.finishedAt, -- 1350
		"", -- 1351
		"## Validation", -- 1352
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1353
			record.completion.validation, -- 1354
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1354
		) or ({"- Not reported"})) -- 1354
	) -- 1354
	__TS__SparseArrayPush(____array_64, "", "## Recorded Evidence") -- 1354
	local ____opt_56 = record.handoffEvidence -- 1354
	__TS__SparseArrayPush( -- 1354
		____array_64, -- 1354
		table.unpack(____opt_56 and #____opt_56.modifiedFiles and __TS__ArrayMap( -- 1358
			record.handoffEvidence.modifiedFiles, -- 1359
			function(____, item) return "- modified: " .. item end -- 1359
		) or ({"- modified: none recorded"})) -- 1359
	) -- 1359
	local ____opt_58 = record.handoffEvidence -- 1359
	__TS__SparseArrayPush( -- 1359
		____array_64, -- 1359
		table.unpack(____opt_58 and ____opt_58.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1361
	) -- 1361
	local ____opt_60 = record.handoffEvidence -- 1361
	__TS__SparseArrayPush( -- 1361
		____array_64, -- 1361
		table.unpack(__TS__ArrayMap( -- 1364
			____opt_60 and ____opt_60.commands or ({}), -- 1364
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1364
		)) -- 1364
	) -- 1364
	local ____opt_62 = record.handoffEvidence -- 1364
	__TS__SparseArrayPush( -- 1364
		____array_64, -- 1364
		table.unpack(__TS__ArrayMap( -- 1365
			____opt_62 and ____opt_62.authoritativeSources or ({}), -- 1365
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1365
		)) -- 1365
	) -- 1365
	__TS__SparseArrayPush( -- 1365
		____array_64, -- 1365
		"", -- 1366
		"## Known Issues", -- 1367
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1368
			record.completion.knownIssues, -- 1368
			function(____, item) return "- " .. item end -- 1368
		) or ({"- None reported"})) -- 1368
	) -- 1368
	__TS__SparseArrayPush( -- 1368
		____array_64, -- 1368
		"", -- 1369
		"## Assumptions", -- 1370
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1371
			record.completion.assumptions, -- 1371
			function(____, item) return "- " .. item end -- 1371
		) or ({"- None reported"})) -- 1371
	) -- 1371
	__TS__SparseArrayPush(____array_64, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1371
	local lines = {__TS__SparseArraySpread(____array_64)} -- 1340
	local path = getResultPath(session.projectRoot, session.memoryScope) -- 1376
	local content = table.concat(lines, "\n") .. "\n" -- 1377
	if not Content:save(path, content) then -- 1377
		return false -- 1379
	end -- 1379
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1381
	return true -- 1382
end -- 1382
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1385
	local dir = Path(projectRoot, ".agent", "subagents") -- 1386
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1386
		return {} -- 1387
	end -- 1387
	local items = {} -- 1388
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1389
		do -- 1389
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1390
			if not Content:exist(path) or not Content:isdir(path) then -- 1390
				goto __continue286 -- 1391
			end -- 1391
			local info = readSpawnInfo( -- 1392
				projectRoot, -- 1392
				Path( -- 1392
					"subagents", -- 1392
					Path:getFilename(path) -- 1392
				) -- 1392
			) -- 1392
			if not info then -- 1392
				goto __continue286 -- 1393
			end -- 1393
			local sessionId = tonumber(info.sessionId) -- 1394
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1395
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1396
			local status = sanitizeUTF8(toStr(info.status)) -- 1397
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1397
				goto __continue286 -- 1398
			end -- 1398
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1398
				goto __continue286 -- 1399
			end -- 1399
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1400
			items[#items + 1] = { -- 1401
				sessionId = sessionId, -- 1402
				rootSessionId = infoRootSessionId, -- 1403
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1404
				title = sanitizeUTF8(toStr(info.title)), -- 1405
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1406
				goal = sanitizeUTF8(toStr(info.goal)), -- 1407
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1408
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1409
					__TS__ArrayFilter( -- 1410
						info.filesHint, -- 1410
						function(____, item) return type(item) == "string" end -- 1410
					), -- 1410
					function(____, item) return sanitizeUTF8(item) end -- 1410
				) or ({}), -- 1410
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1412
				success = info.success == true, -- 1413
				cleared = info.cleared == true, -- 1414
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1415
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1416
					"subagents", -- 1416
					Path:getFilename(path) -- 1416
				)), -- 1416
				sourceTaskId = sourceTaskId or 0, -- 1417
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1418
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1419
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1420
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1421
				completion = normalizeAgentCompletionReport(info.completion), -- 1422
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1423
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1424
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1425
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1426
			} -- 1426
		end -- 1426
		::__continue286:: -- 1426
	end -- 1426
	__TS__ArraySort( -- 1429
		items, -- 1429
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1429
	) -- 1429
	return items -- 1430
end -- 1430
function getPendingHandoffDir(projectRoot, memoryScope) -- 1433
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1434
end -- 1434
function writePendingHandoff(projectRoot, memoryScope, value) -- 1437
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1438
	if not Content:exist(dir) then -- 1438
		ensureDirRecursive(dir) -- 1440
	end -- 1440
	local path = Path(dir, value.id .. ".json") -- 1442
	local text = safeJsonEncode(value) -- 1443
	if not text then -- 1443
		return false -- 1444
	end -- 1444
	local content = text .. "\n" -- 1445
	if not Content:save(path, content) then -- 1445
		return false -- 1446
	end -- 1446
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1447
	return true -- 1448
end -- 1448
function listPendingHandoffs(projectRoot, memoryScope) -- 1451
	local dir = getPendingHandoffDir(projectRoot, memoryScope) -- 1452
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1452
		return {} -- 1453
	end -- 1453
	local items = {} -- 1454
	for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1455
		do -- 1455
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1456
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1456
				goto __continue302 -- 1457
			end -- 1457
			local text = Content:load(path) -- 1458
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1458
				goto __continue302 -- 1459
			end -- 1459
			local obj = safeJsonDecode(text) -- 1460
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1460
				goto __continue302 -- 1461
			end -- 1461
			local value = obj -- 1462
			local sourceTaskId = tonumber(value.sourceTaskId) -- 1463
			local sourceSessionId = tonumber(value.sourceSessionId) -- 1464
			local id = sanitizeUTF8(toStr(value.id)) -- 1465
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1466
			local message = sanitizeUTF8(toStr(value.message)) -- 1467
			local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1468
			local goal = sanitizeUTF8(toStr(value.goal)) -- 1469
			local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1470
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then -- 1470
				goto __continue302 -- 1472
			end -- 1472
			items[#items + 1] = { -- 1474
				id = id, -- 1475
				sourceSessionId = sourceSessionId, -- 1476
				sourceTitle = sourceTitle, -- 1477
				sourceTaskId = sourceTaskId, -- 1478
				message = message, -- 1479
				prompt = prompt, -- 1480
				goal = goal, -- 1481
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)), -- 1482
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1483
					__TS__ArrayFilter( -- 1484
						value.filesHint, -- 1484
						function(____, item) return type(item) == "string" end -- 1484
					), -- 1484
					function(____, item) return sanitizeUTF8(item) end -- 1484
				) or ({}), -- 1484
				success = value.success == true, -- 1486
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1487
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1488
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1489
				changeSet = decodeChangeSetSummary(value.changeSet), -- 1490
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1491
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1492
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1493
				createdAt = createdAt -- 1496
			} -- 1496
		end -- 1496
		::__continue302:: -- 1496
	end -- 1496
	__TS__ArraySort( -- 1499
		items, -- 1499
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end -- 1499
	) -- 1499
	return items -- 1500
end -- 1500
function deletePendingHandoff(projectRoot, memoryScope, id) -- 1503
	local path = Path( -- 1504
		getPendingHandoffDir(projectRoot, memoryScope), -- 1504
		id .. ".json" -- 1504
	) -- 1504
	if Content:exist(path) then -- 1504
		if Content:remove(path) then -- 1504
			Tools.sendWebIDEFileUpdate(path, false, "") -- 1507
		end -- 1507
	end -- 1507
end -- 1507
function normalizePromptText(prompt) -- 1512
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1513
end -- 1513
function normalizePromptTextSafe(prompt) -- 1516
	if type(prompt) == "string" then -- 1516
		local normalized = normalizePromptText(prompt) -- 1518
		if normalized ~= "" then -- 1518
			return normalized -- 1519
		end -- 1519
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1520
		if sanitized ~= "" then -- 1520
			return truncateAgentUserPrompt(sanitized) -- 1522
		end -- 1522
		return "" -- 1524
	end -- 1524
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1526
	if text == "" then -- 1526
		return "" -- 1527
	end -- 1527
	return truncateAgentUserPrompt(text) -- 1528
end -- 1528
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1531
	local sections = {} -- 1532
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1533
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1534
	local normalizedFiles = __TS__ArrayFilter( -- 1535
		__TS__ArrayMap( -- 1535
			__TS__ArrayFilter( -- 1535
				filesHint or ({}), -- 1535
				function(____, item) return type(item) == "string" end -- 1536
			), -- 1536
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1537
		), -- 1537
		function(____, item) return item ~= "" end -- 1538
	) -- 1538
	if normalizedTitle ~= "" then -- 1538
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1540
	end -- 1540
	if normalizedExpected ~= "" then -- 1540
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1543
	end -- 1543
	if #normalizedFiles > 0 then -- 1543
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1546
	end -- 1546
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1548
end -- 1548
function normalizeSessionRuntimeState(session) -- 1551
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1551
		return session -- 1553
	end -- 1553
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1553
		return session -- 1556
	end -- 1556
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1556
		return session -- 1559
	end -- 1559
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1561
		session.id, -- 1564
		session.currentTaskId, -- 1564
		"fetch_url", -- 1564
		"execute_command", -- 1564
		"analyze_image" -- 1564
	}) or ({}) -- 1564
	if #pendingToolRows > 0 then -- 1564
		local t = now() -- 1567
		do -- 1567
			local i = 0 -- 1568
			while i < #pendingToolRows do -- 1568
				local row = pendingToolRows[i + 1] -- 1569
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1570
				result.success = false -- 1571
				result.state = "failed" -- 1572
				result.interrupted = true -- 1573
				result.message = "tool call was interrupted because the program exited before it completed." -- 1574
				DB:exec( -- 1575
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1575
					{ -- 1577
						encodeJson(result), -- 1577
						t, -- 1577
						row[1] -- 1577
					} -- 1577
				) -- 1577
				i = i + 1 -- 1568
			end -- 1568
		end -- 1568
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1580
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1581
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1582
	end -- 1582
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1589
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1590
	return __TS__ObjectAssign( -- 1591
		{}, -- 1591
		session, -- 1592
		{ -- 1591
			status = "STOPPED", -- 1593
			currentTaskStatus = "STOPPED", -- 1594
			updatedAt = now() -- 1595
		} -- 1595
	) -- 1595
end -- 1595
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1599
	DB:exec( -- 1600
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1600
		{ -- 1604
			status, -- 1605
			currentTaskId or 0, -- 1606
			currentTaskStatus or status, -- 1607
			now(), -- 1608
			sessionId -- 1609
		} -- 1609
	) -- 1609
end -- 1609
function decodeSessionMetrics(text) -- 1614
	local metrics = decodeJsonObject(text) -- 1615
	local context = metrics and metrics.context -- 1616
	if (context and context.source) == "llm_input_estimate" and type(context.maxTokens) == "number" and context.maxTokens > 0 and type(context.messagesTokens) == "number" then -- 1616
		local usedTokens = context.messagesTokens + (context.optionsTokens or 0) + (context.toolDefinitionsTokens or 0) + (context.structuralOverhead or 0) -- 1619
		return __TS__ObjectAssign( -- 1621
			{}, -- 1621
			metrics, -- 1622
			{context = __TS__ObjectAssign( -- 1621
				{}, -- 1623
				context, -- 1624
				{ -- 1623
					usedTokens = usedTokens, -- 1625
					ratio = math.max( -- 1626
						0, -- 1626
						math.min(1, usedTokens / context.maxTokens) -- 1626
					), -- 1626
					source = "llm_input_only_estimate" -- 1627
				} -- 1627
			)} -- 1627
		) -- 1627
	end -- 1627
	return metrics -- 1631
end -- 1631
function mergeAgentMetrics(current, next) -- 1634
	return __TS__ObjectAssign({}, current or ({}), next) -- 1635
end -- 1635
function updateSessionMetrics(sessionId, metrics) -- 1641
	local session = getSessionItem(sessionId) -- 1642
	if not session then -- 1642
		return nil -- 1643
	end -- 1643
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1644
	DB:exec( -- 1645
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1645
		{ -- 1649
			encodeJson(merged), -- 1650
			now(), -- 1651
			sessionId -- 1652
		} -- 1652
	) -- 1652
	return merged -- 1655
end -- 1655
function clearSessionTokenUsage(sessionId) -- 1658
	local session = getSessionItem(sessionId) -- 1659
	if not session then -- 1659
		return nil -- 1660
	end -- 1660
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1661
	__TS__Delete(metrics, "usage") -- 1662
	__TS__Delete(metrics, "visionUsage") -- 1663
	DB:exec( -- 1664
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1664
		{ -- 1668
			encodeJson(metrics), -- 1669
			now(), -- 1670
			sessionId -- 1671
		} -- 1671
	) -- 1671
	return metrics -- 1674
end -- 1674
function getInitialTokenUsage(session) -- 1677
	local ____opt_69 = session.metrics -- 1677
	local usage = ____opt_69 and ____opt_69.usage -- 1678
	if not usage or (usage.requestCount or 0) <= 0 then -- 1678
		return nil -- 1679
	end -- 1679
	return { -- 1680
		inputTokens = usage.inputTokens or 0, -- 1681
		outputTokens = usage.outputTokens or 0, -- 1682
		totalTokens = usage.totalTokens, -- 1683
		cachedInputTokens = usage.cachedInputTokens, -- 1684
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1685
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1686
		requestCount = usage.requestCount or 0, -- 1687
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1688
		model = usage.model or "", -- 1689
		phase = usage.phase or "", -- 1690
		step = usage.step or 0, -- 1691
		updatedAt = usage.updatedAt or now() -- 1692
	} -- 1692
end -- 1692
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1696
	if taskId == nil or taskId <= 0 then -- 1696
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1698
		return -- 1699
	end -- 1699
	local row = getSessionRow(sessionId) -- 1701
	if not row then -- 1701
		return -- 1702
	end -- 1702
	local session = rowToSession(row) -- 1703
	if session.currentTaskId ~= taskId then -- 1703
		Log( -- 1705
			"Info", -- 1705
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1705
		) -- 1705
		return -- 1706
	end -- 1706
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1708
end -- 1708
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1711
	local t = now() -- 1712
	DB:exec( -- 1713
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1713
		{ -- 1716
			sessionId, -- 1717
			taskId or 0, -- 1718
			role, -- 1719
			sanitizeUTF8(content), -- 1720
			displayContent and sanitizeUTF8(displayContent) or "", -- 1721
			t, -- 1722
			t -- 1723
		} -- 1723
	) -- 1723
	return getLastInsertRowId() -- 1726
end -- 1726
function updateMessage(messageId, content) -- 1729
	DB:exec( -- 1730
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1730
		{ -- 1732
			sanitizeUTF8(content), -- 1732
			now(), -- 1732
			messageId -- 1732
		} -- 1732
	) -- 1732
end -- 1732
function updateUserMessageForTask(messageId, content, taskId) -- 1736
	DB:exec( -- 1737
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1737
		{ -- 1741
			sanitizeUTF8(content), -- 1741
			taskId, -- 1741
			now(), -- 1741
			messageId -- 1741
		} -- 1741
	) -- 1741
end -- 1741
function removeContinuableTaskSummary(session) -- 1798
	local taskId = session.currentTaskId -- 1799
	if taskId == nil then -- 1799
		return -- 1800
	end -- 1800
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1801
end -- 1801
function upsertAssistantMessage(sessionId, taskId, content) -- 1813
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1814
	if row and type(row[1]) == "number" then -- 1814
		updateMessage(row[1], content) -- 1821
		return row[1] -- 1822
	end -- 1822
	return insertMessage(sessionId, "assistant", content, taskId) -- 1824
end -- 1824
function upsertStep(sessionId, taskId, step, tool, patch) -- 1827
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1837
	local reason = sanitizeUTF8(patch.reason or "") -- 1841
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1842
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1843
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1844
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1845
	local statusPatch = patch.status or "" -- 1846
	local status = patch.status or "PENDING" -- 1847
	if not row then -- 1847
		local t = now() -- 1849
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1850
			sessionId, -- 1854
			taskId, -- 1855
			step, -- 1856
			tool, -- 1857
			status, -- 1858
			reason, -- 1859
			reasoningContent, -- 1860
			paramsJson, -- 1861
			resultJson, -- 1862
			patch.checkpointId or 0, -- 1863
			patch.checkpointSeq or 0, -- 1864
			filesJson, -- 1865
			t, -- 1866
			t -- 1867
		}) -- 1867
		return -- 1870
	end -- 1870
	DB:exec( -- 1872
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1872
		{ -- 1884
			tool, -- 1885
			statusPatch, -- 1886
			status, -- 1887
			reason, -- 1888
			reason, -- 1889
			reasoningContent, -- 1890
			reasoningContent, -- 1891
			paramsJson, -- 1892
			paramsJson, -- 1893
			resultJson, -- 1894
			resultJson, -- 1895
			patch.checkpointId or 0, -- 1896
			patch.checkpointId or 0, -- 1897
			patch.checkpointSeq or 0, -- 1898
			patch.checkpointSeq or 0, -- 1899
			filesJson, -- 1900
			filesJson, -- 1901
			now(), -- 1902
			row[1] -- 1903
		} -- 1903
	) -- 1903
end -- 1903
function getNextStepNumber(sessionId, taskId) -- 1908
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1909
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1913
	return math.max(0, current) + 1 -- 1914
end -- 1914
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 1955
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 1963
	local t = now() -- 1964
	local sqls = { -- 1965
		{ -- 1966
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 1966
			{{ -- 1969
				sessionId, -- 1970
				ownerTaskId, -- 1971
				step, -- 1972
				"sub_agent_handoff", -- 1973
				"DONE", -- 1974
				sanitizeUTF8(reason), -- 1975
				encodeJson(params), -- 1976
				encodeJson(result), -- 1977
				t, -- 1978
				t -- 1979
			}} -- 1979
		}, -- 1979
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 1982
	} -- 1982
	if not DB:transaction(sqls) then -- 1982
		return nil -- 1988
	end -- 1988
	return getStepItem(sessionId, ownerTaskId, step) -- 1989
end -- 1989
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 1992
	if taskId <= 0 then -- 1992
		return -- 1993
	end -- 1993
	if finalSteps ~= nil and finalSteps >= 0 then -- 1993
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 1995
	end -- 1995
	if not finalStatus then -- 1995
		return -- 2001
	end -- 2001
	if finalSteps ~= nil and finalSteps >= 0 then -- 2001
		DB:exec( -- 2003
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 2003
			{ -- 2007
				finalStatus, -- 2007
				now(), -- 2007
				sessionId, -- 2007
				taskId, -- 2007
				finalSteps -- 2007
			} -- 2007
		) -- 2007
		return -- 2009
	end -- 2009
	DB:exec( -- 2011
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 2011
		{ -- 2015
			finalStatus, -- 2015
			now(), -- 2015
			sessionId, -- 2015
			taskId -- 2015
		} -- 2015
	) -- 2015
end -- 2015
function emitAgentSessionPatch(sessionId, patch) -- 2042
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 2043
	if not text then -- 2043
		return -- 2048
	end -- 2048
	local failed = publishSessionPatch(sessionId, text) -- 2049
	if failed > 0 then -- 2049
		Log( -- 2050
			"Warn", -- 2050
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 2050
		) -- 2050
	end -- 2050
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 2050
		emit("AppWS", "Send", text) -- 2051
	end -- 2051
end -- 2051
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 2054
	emitAgentSessionPatch( -- 2055
		sessionId, -- 2055
		{ -- 2055
			sessionDeleted = true, -- 2056
			relatedSessions = listRelatedSessions(rootSessionId) -- 2057
		} -- 2057
	) -- 2057
	local rootSession = getSessionItem(rootSessionId) -- 2059
	if rootSession then -- 2059
		emitAgentSessionPatch( -- 2061
			rootSessionId, -- 2061
			{ -- 2061
				session = rootSession, -- 2062
				relatedSessions = listRelatedSessions(rootSessionId) -- 2063
			} -- 2063
		) -- 2063
	end -- 2063
end -- 2063
function flushPendingSubAgentHandoffs(rootSession) -- 2068
	if rootSession.kind ~= "main" then -- 2068
		return -- 2069
	end -- 2069
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then -- 2069
		return -- 2071
	end -- 2071
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope) -- 2073
	if #items == 0 then -- 2073
		return -- 2074
	end -- 2074
	local handoffTaskId = 0 -- 2075
	local previousTaskId = rootSession.currentTaskId -- 2076
	local ____rootSession_currentTaskId_73 -- 2077
	if rootSession.currentTaskId then -- 2077
		____rootSession_currentTaskId_73 = getTaskPrompt(rootSession.currentTaskId) -- 2077
	else -- 2077
		____rootSession_currentTaskId_73 = nil -- 2077
	end -- 2077
	local currentTaskPrompt = ____rootSession_currentTaskId_73 -- 2077
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then -- 2077
		handoffTaskId = rootSession.currentTaskId -- 2085
	else -- 2085
		local taskRes = Tools.createTask( -- 2087
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 2087
			"code" -- 2087
		) -- 2087
		if not taskRes.success then -- 2087
			Log( -- 2089
				"Warn", -- 2089
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 2089
			) -- 2089
			return -- 2090
		end -- 2090
		handoffTaskId = taskRes.taskId -- 2092
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 2093
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 2094
		emitAgentSessionPatch( -- 2095
			rootSession.id, -- 2095
			{session = getSessionItem(rootSession.id)} -- 2095
		) -- 2095
	end -- 2095
	do -- 2095
		local i = 0 -- 2099
		while i < #items do -- 2099
			local item = items[i + 1] -- 2100
			local step = appendHandoffSystemStep( -- 2101
				rootSession.id, -- 2102
				handoffTaskId, -- 2103
				item.sourceTaskId, -- 2104
				item.message, -- 2105
				{ -- 2106
					sourceSessionId = item.sourceSessionId, -- 2107
					sourceTitle = item.sourceTitle, -- 2108
					sourceTaskId = item.sourceTaskId, -- 2109
					success = item.success == true, -- 2110
					summary = item.message, -- 2111
					resultFilePath = item.resultFilePath or "", -- 2112
					artifactDir = item.artifactDir or "", -- 2113
					finishedAt = item.finishedAt or "", -- 2114
					changeSet = item.changeSet, -- 2115
					handoffEvidence = item.handoffEvidence, -- 2116
					memoryEntry = item.memoryEntry, -- 2117
					completion = item.completion -- 2118
				}, -- 2118
				{ -- 2120
					sourceSessionId = item.sourceSessionId, -- 2121
					sourceTitle = item.sourceTitle, -- 2122
					sourceTaskId = item.sourceTaskId, -- 2123
					prompt = item.prompt, -- 2124
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 2125
					expectedOutput = item.expectedOutput or "", -- 2126
					filesHint = item.filesHint or ({}), -- 2127
					resultFilePath = item.resultFilePath or "", -- 2128
					artifactDir = item.artifactDir or "", -- 2129
					changeSet = item.changeSet, -- 2130
					handoffEvidence = item.handoffEvidence, -- 2131
					memoryEntry = item.memoryEntry, -- 2132
					completion = item.completion -- 2133
				} -- 2133
			) -- 2133
			if step then -- 2133
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 2137
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id) -- 2138
			else -- 2138
				Log( -- 2140
					"Warn", -- 2140
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 2140
				) -- 2140
			end -- 2140
			i = i + 1 -- 2099
		end -- 2099
	end -- 2099
	if previousTaskId and previousTaskId ~= handoffTaskId then -- 2099
		cleanupTaskHeavyData(previousTaskId) -- 2144
	end -- 2144
end -- 2144
function applyEvent(sessionId, event) -- 2156
	if not getSessionItem(sessionId) then -- 2156
		streamUpdates:clear(sessionId) -- 2158
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 2158
			__TS__Delete(activeStopTokens, event.taskId) -- 2160
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 2161
		end -- 2161
		return -- 2163
	end -- 2163
	repeat -- 2163
		local ____switch399 = event.type -- 2163
		local metrics, startedSession -- 2163
		local ____cond399 = ____switch399 == "task_started" -- 2163
		if ____cond399 then -- 2163
			streamUpdates:clear(sessionId) -- 2167
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 2168
			local ____event_resumed_76 -- 2169
			if event.resumed then -- 2169
				local ____opt_74 = getSessionItem(sessionId) -- 2169
				____event_resumed_76 = ____opt_74 and ____opt_74.metrics -- 2170
			else -- 2170
				____event_resumed_76 = clearSessionTokenUsage(sessionId) -- 2171
			end -- 2171
			metrics = ____event_resumed_76 -- 2169
			startedSession = getSessionItem(sessionId) -- 2172
			emitAgentSessionPatch( -- 2173
				sessionId, -- 2173
				{ -- 2173
					session = startedSession, -- 2174
					metrics = metrics, -- 2175
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2176
				} -- 2176
			) -- 2176
			break -- 2180
		end -- 2180
		____cond399 = ____cond399 or ____switch399 == "decision_made" -- 2180
		if ____cond399 then -- 2180
			upsertStep( -- 2182
				sessionId, -- 2182
				event.taskId, -- 2182
				event.step, -- 2182
				event.tool, -- 2182
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 2182
			) -- 2182
			emitAgentSessionPatch( -- 2190
				sessionId, -- 2190
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2190
			) -- 2190
			break -- 2193
		end -- 2193
		____cond399 = ____cond399 or ____switch399 == "tool_started" -- 2193
		if ____cond399 then -- 2193
			upsertStep( -- 2195
				sessionId, -- 2195
				event.taskId, -- 2195
				event.step, -- 2195
				event.tool, -- 2195
				{status = "RUNNING"} -- 2195
			) -- 2195
			emitAgentSessionPatch( -- 2198
				sessionId, -- 2198
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2198
			) -- 2198
			break -- 2201
		end -- 2201
		____cond399 = ____cond399 or ____switch399 == "tool_finished" -- 2201
		if ____cond399 then -- 2201
			do -- 2201
				upsertStep( -- 2203
					sessionId, -- 2203
					event.taskId, -- 2203
					event.step, -- 2203
					event.tool, -- 2203
					{status = event.execution.status, reason = event.reason, result = event.result} -- 2203
				) -- 2203
				emitAgentSessionPatch( -- 2211
					sessionId, -- 2211
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2211
				) -- 2211
				break -- 2214
			end -- 2214
		end -- 2214
		____cond399 = ____cond399 or ____switch399 == "tool_progress" -- 2214
		if ____cond399 then -- 2214
			do -- 2214
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 2218
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 2218
					break -- 2220
				end -- 2220
			end -- 2220
			upsertStep( -- 2223
				sessionId, -- 2223
				event.taskId, -- 2223
				event.step, -- 2223
				event.tool, -- 2223
				{status = "RUNNING", result = event.result} -- 2223
			) -- 2223
			emitAgentSessionPatch( -- 2227
				sessionId, -- 2227
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2227
			) -- 2227
			break -- 2230
		end -- 2230
		____cond399 = ____cond399 or ____switch399 == "checkpoint_created" -- 2230
		if ____cond399 then -- 2230
			upsertStep( -- 2232
				sessionId, -- 2232
				event.taskId, -- 2232
				event.step, -- 2232
				event.tool, -- 2232
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2232
			) -- 2232
			emitAgentSessionPatch( -- 2237
				sessionId, -- 2237
				{ -- 2237
					step = getStepItem(sessionId, event.taskId, event.step), -- 2238
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2239
				} -- 2239
			) -- 2239
			break -- 2241
		end -- 2241
		____cond399 = ____cond399 or ____switch399 == "memory_compression_started" -- 2241
		if ____cond399 then -- 2241
			upsertStep( -- 2243
				sessionId, -- 2243
				event.taskId, -- 2243
				event.step, -- 2243
				event.tool, -- 2243
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2243
			) -- 2243
			emitAgentSessionPatch( -- 2248
				sessionId, -- 2248
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2248
			) -- 2248
			break -- 2251
		end -- 2251
		____cond399 = ____cond399 or ____switch399 == "memory_compression_finished" -- 2251
		if ____cond399 then -- 2251
			upsertStep( -- 2253
				sessionId, -- 2253
				event.taskId, -- 2253
				event.step, -- 2253
				event.tool, -- 2253
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2253
			) -- 2253
			emitAgentSessionPatch( -- 2258
				sessionId, -- 2258
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2258
			) -- 2258
			break -- 2261
		end -- 2261
		____cond399 = ____cond399 or ____switch399 == "metrics_updated" -- 2261
		if ____cond399 then -- 2261
			do -- 2261
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2263
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2264
				break -- 2267
			end -- 2267
		end -- 2267
		____cond399 = ____cond399 or ____switch399 == "assistant_message_updated" -- 2267
		if ____cond399 then -- 2267
			do -- 2267
				local session = getSessionItem(sessionId) -- 2270
				if (session and session.currentTaskId) ~= event.taskId then -- 2270
					streamUpdates:clear(sessionId, event.taskId) -- 2272
					break -- 2272
				end -- 2272
				streamUpdates:update( -- 2274
					sessionId, -- 2274
					event.taskId, -- 2274
					event.step, -- 2274
					event, -- 2274
					App.runningTime -- 2274
				) -- 2274
				scheduleStreamFlush() -- 2275
				break -- 2276
			end -- 2276
		end -- 2276
		____cond399 = ____cond399 or ____switch399 == "assistant_message_finished" -- 2276
		if ____cond399 then -- 2276
			do -- 2276
				local ____opt_79 = getSessionItem(sessionId) -- 2276
				if (____opt_79 and ____opt_79.currentTaskId) ~= event.taskId then -- 2276
					streamUpdates:clear(sessionId, event.taskId) -- 2280
					break -- 2280
				end -- 2280
				streamUpdates:finish(sessionId, event.taskId, event.step) -- 2282
				upsertStep( -- 2283
					sessionId, -- 2283
					event.taskId, -- 2283
					event.step, -- 2283
					"message", -- 2283
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2283
				) -- 2283
				emitAgentSessionPatch( -- 2289
					sessionId, -- 2289
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2289
				) -- 2289
				break -- 2292
			end -- 2292
		end -- 2292
		____cond399 = ____cond399 or ____switch399 == "task_waiting_for_user" -- 2292
		if ____cond399 then -- 2292
			do -- 2292
				local ____opt_81 = getSessionItem(sessionId) -- 2292
				if (____opt_81 and ____opt_81.currentTaskId) ~= event.taskId then -- 2292
					streamUpdates:clear(sessionId, event.taskId) -- 2296
					break -- 2296
				end -- 2296
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2298
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2299
				__TS__Delete(activeStopTokens, event.taskId) -- 2300
				emitAgentSessionPatch( -- 2301
					sessionId, -- 2301
					{ -- 2301
						session = getSessionItem(sessionId), -- 2302
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2303
					} -- 2303
				) -- 2303
				break -- 2305
			end -- 2305
		end -- 2305
		____cond399 = ____cond399 or ____switch399 == "task_finished" -- 2305
		if ____cond399 then -- 2305
			do -- 2305
				local session = getSessionItem(sessionId) -- 2308
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2308
					__TS__Delete(activeStopTokens, event.taskId) -- 2310
					streamUpdates:clear(sessionId, event.taskId) -- 2311
					Log( -- 2312
						"Info", -- 2312
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2312
					) -- 2312
					break -- 2313
				end -- 2313
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2315
				local ____opt_83 = activeStopTokens[event.taskId or -1] -- 2315
				local stopped = (____opt_83 and ____opt_83.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2316
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2318
				local isSubSession = (session and session.kind) == "sub" -- 2321
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2322
				if isSubSession and event.taskId ~= nil then -- 2322
					finalizingSubSessionTaskIds[event.taskId] = true -- 2324
				end -- 2324
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2326
				if event.taskId ~= nil then -- 2326
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2328
					local ____finalizeTaskSteps_89 = finalizeTaskSteps -- 2329
					local ____array_88 = __TS__SparseArrayNew( -- 2329
						sessionId, -- 2330
						event.taskId, -- 2331
						type(event.steps) == "number" and math.max( -- 2332
							0, -- 2332
							math.floor(event.steps) -- 2332
						) or nil -- 2332
					) -- 2332
					local ____event_success_87 -- 2333
					if event.success then -- 2333
						____event_success_87 = nil -- 2333
					else -- 2333
						____event_success_87 = stopped and "STOPPED" or "FAILED" -- 2333
					end -- 2333
					__TS__SparseArrayPush(____array_88, ____event_success_87) -- 2333
					____finalizeTaskSteps_89(__TS__SparseArraySpread(____array_88)) -- 2329
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2335
					if not isSubSession then -- 2335
						__TS__Delete(activeStopTokens, event.taskId) -- 2337
					end -- 2337
					emitAgentSessionPatch( -- 2339
						sessionId, -- 2339
						{ -- 2339
							session = getSessionItem(sessionId), -- 2340
							message = getMessageItem(messageId), -- 2341
							removedStepIds = removedStepIds -- 2342
						} -- 2342
					) -- 2342
				end -- 2342
				if session and session.kind == "main" then -- 2342
					flushPendingSubAgentHandoffs(session) -- 2346
				end -- 2346
				break -- 2348
			end -- 2348
		end -- 2348
	until true -- 2348
end -- 2348
function ____exports.createSession(projectRoot, title) -- 2353
	if title == nil then -- 2353
		title = "" -- 2353
	end -- 2353
	local storage = requireAgentStorage() -- 2354
	if not storage.success then -- 2354
		return storage -- 2355
	end -- 2355
	if not isValidProjectRoot(projectRoot) then -- 2355
		return {success = false, message = "invalid projectRoot"} -- 2357
	end -- 2357
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2359
	if row then -- 2359
		return { -- 2368
			success = true, -- 2368
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2368
		} -- 2368
	end -- 2368
	local t = now() -- 2370
	DB:exec( -- 2371
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2371
		{ -- 2374
			projectRoot, -- 2374
			title ~= "" and title or Path:getFilename(projectRoot), -- 2374
			t, -- 2374
			t -- 2374
		} -- 2374
	) -- 2374
	local sessionId = getLastInsertRowId() -- 2376
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2377
	local session = getSessionItem(sessionId) -- 2378
	if not session then -- 2378
		return {success = false, message = "failed to create session"} -- 2380
	end -- 2380
	return {success = true, session = session} -- 2382
end -- 2353
function ____exports.createSubSession(parentSessionId, title) -- 2385
	if title == nil then -- 2385
		title = "" -- 2385
	end -- 2385
	local storage = requireAgentStorage() -- 2386
	if not storage.success then -- 2386
		return storage -- 2387
	end -- 2387
	local parent = getSessionItem(parentSessionId) -- 2388
	if not parent then -- 2388
		return {success = false, message = "parent session not found"} -- 2390
	end -- 2390
	local rootId = getSessionRootId(parent) -- 2392
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2392
		return {success = false, message = "project task admission is closed"} -- 2393
	end -- 2393
	local t = now() -- 2394
	DB:exec( -- 2395
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2395
		{ -- 2398
			parent.projectRoot, -- 2398
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2398
			rootId, -- 2398
			parent.id, -- 2398
			t, -- 2398
			t -- 2398
		} -- 2398
	) -- 2398
	local sessionId = getLastInsertRowId() -- 2400
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2401
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2402
	local session = getSessionItem(sessionId) -- 2403
	if not session then -- 2403
		return {success = false, message = "failed to create sub session"} -- 2405
	end -- 2405
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2407
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2408
	subStorage:writeMemory(parentStorage:readMemory()) -- 2409
	return {success = true, session = session} -- 2410
end -- 2385
function spawnSubAgentSession(request) -- 2413
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2413
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2427
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2428
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2429
		if normalizedPrompt == "" then -- 2429
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2431
		end -- 2431
		if normalizedPrompt == "" then -- 2431
			local ____Log_95 = Log -- 2438
			local ____temp_92 = #normalizedTitle -- 2438
			local ____temp_93 = #rawPrompt -- 2438
			local ____temp_94 = #toStr(request.expectedOutput) -- 2438
			local ____opt_90 = request.filesHint -- 2438
			____Log_95( -- 2438
				"Warn", -- 2438
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_92)) .. " raw_prompt_len=") .. tostring(____temp_93)) .. " expected_len=") .. tostring(____temp_94)) .. " files_hint_count=") .. tostring(____opt_90 and #____opt_90 or 0) -- 2438
			) -- 2438
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2438
		end -- 2438
		Log( -- 2441
			"Info", -- 2441
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2441
		) -- 2441
		local parentSessionId = request.parentSessionId -- 2442
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2442
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2444
			if not fallbackParent then -- 2444
				local createdMain = ____exports.createSession(request.projectRoot) -- 2446
				if createdMain.success then -- 2446
					fallbackParent = createdMain.session -- 2448
				end -- 2448
			end -- 2448
			if fallbackParent then -- 2448
				Log( -- 2452
					"Warn", -- 2452
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2452
				) -- 2452
				parentSessionId = fallbackParent.id -- 2453
			end -- 2453
		end -- 2453
		local parentSession = getSessionItem(parentSessionId) -- 2456
		if not parentSession then -- 2456
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2456
		end -- 2456
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2460
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2460
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2460
		end -- 2460
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2460
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2460
		end -- 2460
		local agentType = type(request.agentType) == "string" and __TS__StringTrim(request.agentType) or "" -- 2465
		local subPrompt = normalizedPrompt -- 2466
		if agentType ~= "" and agentType ~= "general" then -- 2466
			local wakeContext = TeamWake.buildTeamWakeContext(parentSession.projectRoot, agentType) -- 2468
			if wakeContext ~= "" then -- 2468
				subPrompt = (wakeContext .. "\n\n---\n\n# Task\n") .. normalizedPrompt
				Log( -- 2471
					"Info", -- 2471
					(("[AgentSession] team wake context type=" .. agentType) .. " added_len=") .. tostring(#subPrompt - #normalizedPrompt) -- 2471
				) -- 2471
			else -- 2471
				Log("Info", ("[AgentSession] team wake context type=" .. agentType) .. " empty (no team files yet)") -- 2473
			end -- 2473
		end -- 2473
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2476
		if not created.success then -- 2476
			return ____awaiter_resolve(nil, created) -- 2476
		end -- 2476
		writeSpawnInfo( -- 2480
			created.session.projectRoot, -- 2480
			created.session.memoryScope, -- 2480
			{ -- 2480
				sessionId = created.session.id, -- 2481
				rootSessionId = created.session.rootSessionId, -- 2482
				parentSessionId = created.session.parentSessionId, -- 2483
				title = created.session.title, -- 2484
				prompt = normalizedPrompt, -- 2485
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2486
				expectedOutput = request.expectedOutput or "", -- 2487
				filesHint = request.filesHint or ({}), -- 2488
				agentType = agentType, -- 2489
				status = "RUNNING", -- 2490
				success = false, -- 2491
				resultFilePath = "", -- 2492
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2493
				sourceTaskId = 0, -- 2494
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2495
				createdAtTs = created.session.createdAt, -- 2496
				finishedAt = "", -- 2497
				finishedAtTs = 0 -- 2498
			} -- 2498
		) -- 2498
		local sent = ____exports.sendPrompt( -- 2500
			created.session.id, -- 2500
			subPrompt, -- 2500
			request.disabledAgentTools, -- 2500
			nil, -- 2500
			nil, -- 2500
			request.llmConfig -- 2500
		) -- 2500
		if not sent.success then -- 2500
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2500
		end -- 2500
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2500
	end) -- 2500
end -- 2500
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2624
	local rootSession = getRootSessionItem(session.id) -- 2625
	if not rootSession then -- 2625
		return -- 2626
	end -- 2626
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2627
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2628
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "") -- 2629
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z") -- 2630
	local queueResult = writePendingHandoff( -- 2631
		rootSession.projectRoot, -- 2631
		rootSession.memoryScope, -- 2631
		{ -- 2631
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2632
			sourceSessionId = session.id, -- 2633
			sourceTitle = session.title, -- 2634
			sourceTaskId = taskId, -- 2635
			message = summary, -- 2636
			prompt = result.prompt, -- 2637
			goal = result.goal, -- 2638
			expectedOutput = result.expectedOutput or "", -- 2639
			filesHint = result.filesHint or ({}), -- 2640
			success = result.success, -- 2641
			resultFilePath = result.resultFilePath, -- 2642
			artifactDir = result.artifactDir, -- 2643
			finishedAt = result.finishedAt, -- 2644
			changeSet = changeSet, -- 2645
			handoffEvidence = result.handoffEvidence, -- 2646
			memoryEntry = result.memoryEntry, -- 2647
			completion = result.completion, -- 2648
			createdAt = createdAt -- 2649
		} -- 2649
	) -- 2649
	if not queueResult then -- 2649
		Log( -- 2652
			"Warn", -- 2652
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2652
		) -- 2652
		return -- 2653
	end -- 2653
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2653
		addTaskReference(rootSession.currentTaskId, taskId) -- 2656
	end -- 2656
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2656
		flushPendingSubAgentHandoffs(rootSession) -- 2659
	end -- 2659
end -- 2659
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff) -- 2663
	if forceHandoff == nil then -- 2663
		forceHandoff = false -- 2669
	end -- 2669
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2669
		local rootSessionId = getSessionRootId(session) -- 2671
		local rootSession = getRootSessionItem(session.id) -- 2672
		if not rootSession then -- 2672
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2672
		end -- 2672
		local spawnInfo = getSessionSpawnInfo(session) -- 2676
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2677
		local finishedAtTs = now() -- 2678
		local resultText = sanitizeUTF8(message) -- 2679
		local changeSet = getTaskChangeSetSummary(taskId) -- 2680
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2681
		local ____completion_107 = completion -- 2683
		if ____completion_107 == nil then -- 2683
			local ____normalizeAgentCompletionReport_106 = normalizeAgentCompletionReport -- 2683
			local ____opt_104 = handoffEvidence.lastBuild -- 2683
			____completion_107 = ____normalizeAgentCompletionReport_106({outcome = (____opt_104 and ____opt_104.result) == "passed" and "completed" or "partial", knownIssues = {}}) -- 2683
		end -- 2683
		local completionReport = ____completion_107 -- 2683
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2687
		if not success and completionReport.outcome == "completed" and not forceHandoff then -- 2687
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "blocked", knownIssues = {resultText ~= "" and resultText or "The sub-agent did not complete."}})) -- 2689
		end -- 2689
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2689
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2696
		end -- 2696
		local completed = success and completionReport.outcome == "completed" -- 2704
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED") -- 2705
		local record = { -- 2708
			sessionId = session.id, -- 2709
			rootSessionId = rootSessionId, -- 2710
			parentSessionId = session.parentSessionId, -- 2711
			title = session.title, -- 2712
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2713
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2714
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2715
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2716
			status = recordStatus, -- 2717
			success = completed, -- 2718
			resultFilePath = getResultRelativePath(session.memoryScope), -- 2719
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2720
			sourceTaskId = taskId, -- 2721
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2722
			finishedAt = finishedAt, -- 2723
			createdAtTs = session.createdAt, -- 2724
			finishedAtTs = finishedAtTs, -- 2725
			changeSet = changeSet, -- 2726
			handoffEvidence = handoffEvidence, -- 2727
			completion = completionReport -- 2728
		} -- 2728
		local ____record_success_118 -- 2730
		if record.success then -- 2730
			____record_success_118 = buildStructuredSubAgentMemoryEntry(record) -- 2730
		else -- 2730
			____record_success_118 = nil -- 2730
		end -- 2730
		record.memoryEntry = ____record_success_118 -- 2730
		if not writeSubAgentResultFile(session, record, resultText) then -- 2730
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2730
		end -- 2730
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2730
			sessionId = record.sessionId, -- 2735
			rootSessionId = record.rootSessionId, -- 2736
			parentSessionId = record.parentSessionId, -- 2737
			title = record.title, -- 2738
			prompt = record.prompt, -- 2739
			goal = record.goal, -- 2740
			expectedOutput = record.expectedOutput or "", -- 2741
			filesHint = record.filesHint or ({}), -- 2742
			status = record.status, -- 2743
			success = record.success, -- 2744
			resultFilePath = record.resultFilePath, -- 2745
			artifactDir = record.artifactDir, -- 2746
			sourceTaskId = record.sourceTaskId, -- 2747
			createdAt = record.createdAt, -- 2748
			finishedAt = record.finishedAt, -- 2749
			createdAtTs = record.createdAtTs, -- 2750
			finishedAtTs = record.finishedAtTs, -- 2751
			changeSet = record.changeSet, -- 2752
			handoffEvidence = record.handoffEvidence, -- 2753
			memoryEntry = record.memoryEntry, -- 2754
			memoryEntryError = record.memoryEntryError, -- 2755
			completion = record.completion -- 2756
		}) then -- 2756
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2756
		end -- 2756
		if success or forceHandoff then -- 2756
			appendSubAgentHandoffStep(session, taskId, record, resultText) -- 2761
			deleteSessionRecords(session.id, true) -- 2762
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2763
		end -- 2763
		return ____awaiter_resolve(nil, {success = true}) -- 2763
	end) -- 2763
end -- 2763
function stopClearedSubSession(session, taskId) -- 2768
	local spawnInfo = getSessionSpawnInfo(session) -- 2769
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2770
	local rootSessionId = getSessionRootId(session) -- 2771
	Tools.setTaskStatus(taskId, "STOPPED") -- 2772
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2773
	if not writeSpawnInfo( -- 2773
		session.projectRoot, -- 2774
		session.memoryScope, -- 2774
		{ -- 2774
			sessionId = session.id, -- 2775
			rootSessionId = rootSessionId, -- 2776
			parentSessionId = session.parentSessionId, -- 2777
			title = session.title, -- 2778
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2779
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2780
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2781
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2782
			status = "STOPPED", -- 2783
			success = false, -- 2784
			cleared = true, -- 2785
			resultFilePath = "", -- 2786
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2787
			sourceTaskId = taskId, -- 2788
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2789
			finishedAt = finishedAt, -- 2790
			createdAtTs = session.createdAt, -- 2791
			finishedAtTs = now() -- 2792
		} -- 2792
	) then -- 2792
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2794
	end -- 2794
	deleteSessionRecords(session.id, true) -- 2796
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2797
	return {success = true} -- 2798
end -- 2798
function startImmediatePrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, inputId) -- 2801
	local session = getSessionItem(sessionId) -- 2802
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2802
		return {success = false, message = "project task admission is closed"} -- 2803
	end -- 2803
	if not session then -- 2803
		return {success = false, message = "session not found"} -- 2805
	end -- 2805
	if getPendingQuestionnaire(sessionId) then -- 2805
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2807
	end -- 2807
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2807
		return {success = false, message = "session task is finalizing"} -- 2809
	end -- 2809
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2809
		return {success = false, message = "session task is still running"} -- 2812
	end -- 2812
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2814
	if normalizedPrompt == "" and session.kind == "sub" then -- 2814
		local spawnInfo = getSessionSpawnInfo(session) -- 2816
		if spawnInfo then -- 2816
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2818
			if normalizedPrompt == "" then -- 2818
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2820
			end -- 2820
		end -- 2820
	end -- 2820
	if normalizedPrompt == "" then -- 2820
		return {success = false, message = "prompt is empty"} -- 2829
	end -- 2829
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2831
	if session.workMode ~= nextWorkMode then -- 2831
		DB:exec( -- 2833
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2833
			{ -- 2833
				nextWorkMode, -- 2833
				now(), -- 2833
				session.id -- 2833
			} -- 2833
		) -- 2833
		session.workMode = nextWorkMode -- 2834
	end -- 2834
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2836
	return startPromptTask( -- 2837
		session, -- 2837
		normalizedPrompt, -- 2837
		nil, -- 2837
		normalizeDisabledAgentTools(disabledAgentTools), -- 2837
		{ -- 2837
			workMode = nextWorkMode, -- 2837
			llmConfigId = llmConfigId, -- 2837
			llmConfig = llmConfig, -- 2837
			maxSteps = boundedMaxSteps, -- 2837
			inputId = inputId -- 2837
		} -- 2837
	) -- 2837
end -- 2837
function startLocalPrompt(sessionId, prompt, localAgentConfigId, inputId) -- 2840
	local session = getSessionItem(sessionId) -- 2841
	if not session then -- 2841
		return {success = false, message = "session not found"} -- 2842
	end -- 2842
	if session.kind ~= "main" then -- 2842
		return {success = false, message = "local Agent only supports main sessions"} -- 2843
	end -- 2843
	if getPendingQuestionnaire(sessionId) then -- 2843
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2844
	end -- 2844
	if session.currentTaskStatus == "RUNNING" then -- 2844
		return {success = false, message = "session task is still running"} -- 2845
	end -- 2845
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2846
	if normalizedPrompt == "" then -- 2846
		return {success = false, message = "prompt is empty"} -- 2847
	end -- 2847
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2848
	if not config then -- 2848
		return {success = false, message = "local Agent config not found"} -- 2849
	end -- 2849
	if not config.verifiedAt then -- 2849
		return {success = false, message = "local Agent config is not verified"} -- 2850
	end -- 2850
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2851
	if not taskRes.success then -- 2851
		return taskRes -- 2852
	end -- 2852
	local taskId = taskRes.taskId -- 2853
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2854
	if inputId ~= nil then -- 2854
		InputInbox.markDelivering(inputId, taskId) -- 2855
		InputInbox.markDelivered(inputId, messageId) -- 2855
	end -- 2855
	followup.activeRuns[sessionId] = taskId -- 2856
	Tools.setTaskStatus(taskId, "RUNNING") -- 2857
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2858
	upsertStep( -- 2859
		session.id, -- 2859
		taskId, -- 2859
		1, -- 2859
		"local_agent_message", -- 2859
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2859
	) -- 2859
	emitAgentSessionPatch( -- 2865
		session.id, -- 2865
		{ -- 2865
			session = getSessionItem(session.id), -- 2866
			message = getMessageItem(messageId), -- 2867
			step = getStepItem(session.id, taskId, 1) -- 2868
		} -- 2868
	) -- 2868
	local events = {} -- 2870
	local transcript = "" -- 2871
	local assistant = "" -- 2872
	local lastFlush = 0 -- 2873
	local function flush(force) -- 2874
		if force == nil then -- 2874
			force = false -- 2874
		end -- 2874
		if not force and App.runningTime - lastFlush < 0.075 then -- 2874
			return -- 2875
		end -- 2875
		lastFlush = App.runningTime -- 2876
		if #events > 400 then -- 2876
			events = __TS__ArraySlice(events, #events - 400) -- 2877
		end -- 2877
		if #transcript > 1024 * 1024 then -- 2877
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2878
		end -- 2878
		upsertStep( -- 2879
			session.id, -- 2879
			taskId, -- 2879
			1, -- 2879
			"local_agent_message", -- 2879
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2879
		) -- 2879
		local message -- 2884
		if assistant ~= "" then -- 2884
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2886
			message = getMessageItem(assistantId) -- 2887
		end -- 2887
		emitAgentSessionPatch( -- 2889
			session.id, -- 2889
			__TS__ObjectAssign( -- 2889
				{step = getStepItem(session.id, taskId, 1)}, -- 2889
				message and ({message = message}) or ({}) -- 2889
			) -- 2889
		) -- 2889
	end -- 2874
	local completedSynchronously = false -- 2891
	local control = LocalAgent.run( -- 2892
		session.id, -- 2892
		config, -- 2892
		session.projectRoot, -- 2892
		normalizedPrompt, -- 2892
		function(event) -- 2892
			local text = sanitizeUTF8(event.text) -- 2893
			if text == "" then -- 2893
				return -- 2894
			end -- 2894
			local previous = #events > 0 and events[#events] or nil -- 2895
			if previous and previous.kind == event.kind and previous.text == text then -- 2895
				return -- 2896
			end -- 2896
			events[#events + 1] = {kind = event.kind, text = text} -- 2897
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2898
			if event.kind == "assistant" then -- 2898
				assistant = text -- 2899
			end -- 2899
			flush(false) -- 2900
		end, -- 2892
		function(result) -- 2901
			completedSynchronously = true -- 2902
			flush(true) -- 2903
			__TS__Delete(activeLocalAgentControls, taskId) -- 2904
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2905
			Tools.setTaskStatus(taskId, status) -- 2906
			setSessionState(session.id, status, taskId, status) -- 2907
			upsertStep( -- 2908
				session.id, -- 2908
				taskId, -- 2908
				1, -- 2908
				"local_agent_message", -- 2908
				{status = status, reason = config.name .. " · full permissions", result = { -- 2908
					provider = config.provider, -- 2911
					events = events, -- 2911
					transcript = transcript, -- 2911
					exitCode = result.exitCode, -- 2911
					resumeId = result.resumeId, -- 2911
					message = result.message -- 2911
				}} -- 2911
			) -- 2911
			emitAgentSessionPatch( -- 2913
				session.id, -- 2913
				{ -- 2913
					session = getSessionItem(session.id), -- 2913
					step = getStepItem(session.id, taskId, 1) -- 2913
				} -- 2913
			) -- 2913
			followup.settle(sessionId, taskId, result.success and not result.stopped) -- 2914
		end -- 2901
	) -- 2901
	if not completedSynchronously then -- 2901
		activeLocalAgentControls[taskId] = control -- 2916
	end -- 2916
	return {success = true, sessionId = session.id, taskId = taskId} -- 2917
end -- 2917
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 2990
	if disabledAgentTools == nil then -- 2990
		disabledAgentTools = {} -- 2994
	end -- 2994
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 2997
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 2997
		return {success = false, message = "project task admission is closed"} -- 2998
	end -- 2998
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 2999
	if not llmConfigRes.success then -- 2999
		return {success = false, message = llmConfigRes.message} -- 3003
	end -- 3003
	local llmConfig = llmConfigRes.config -- 3005
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 3006
	if not llmConfigValidation.success then -- 3006
		return llmConfigValidation -- 3008
	end -- 3008
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 3010
	if not taskRes.success then -- 3010
		return {success = false, message = taskRes.message} -- 3013
	end -- 3013
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 3013
		removeContinuableTaskSummary(session) -- 3015
	end -- 3015
	local taskId = taskRes.taskId -- 3017
	if (options and options.inputId) ~= nil then -- 3017
		InputInbox.markDelivering(options.inputId, taskId) -- 3018
	end -- 3018
	followup.activeRuns[session.id] = taskId -- 3019
	local ____temp_141 -- 3020
	if (options and options.existingTaskId) == nil then -- 3020
		____temp_141 = session.currentTaskId -- 3020
	else -- 3020
		____temp_141 = nil -- 3020
	end -- 3020
	local previousTaskId = ____temp_141 -- 3020
	local useChineseResponse = getDefaultUseChineseResponse() -- 3021
	local promptMessageId -- 3022
	if existingUserMessageId ~= nil then -- 3022
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 3024
		promptMessageId = existingUserMessageId -- 3025
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 3025
		promptMessageId = insertMessage( -- 3027
			session.id, -- 3027
			"user", -- 3027
			normalizedPrompt, -- 3027
			taskId, -- 3027
			options and options.displayContent -- 3027
		) -- 3027
	end -- 3027
	if (options and options.inputId) ~= nil and promptMessageId ~= nil then -- 3027
		if DB:exec("UPDATE agent.AgentSessionInput SET message_id=? WHERE id=?", {promptMessageId, options.inputId}) < 0 then -- 3027
			error( -- 3030
				__TS__New(Error, "failed to link input display"), -- 3030
				0 -- 3030
			) -- 3030
		end -- 3030
		if normalizedPrompt == "/clear" or normalizedPrompt == "/compact" then -- 3030
			InputInbox.markDelivered(options.inputId, promptMessageId) -- 3031
		end -- 3031
	end -- 3031
	local stopToken = {stopped = false} -- 3033
	activeStopTokens[taskId] = stopToken -- 3034
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3035
	emitAgentSessionPatch( -- 3039
		session.id, -- 3039
		__TS__ObjectAssign( -- 3039
			{session = getSessionItem(session.id)}, -- 3039
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 3041
		) -- 3041
	) -- 3041
	if previousTaskId and previousTaskId ~= taskId then -- 3041
		cleanupTaskHeavyData(previousTaskId) -- 3044
	end -- 3044
	activePromptRuns = activePromptRuns + 1 -- 3046
	local ____runCodingAgent_176 = runCodingAgent -- 3047
	local ____normalizedPrompt_167 = normalizedPrompt -- 3048
	local ____temp_168 = options and options.inputId -- 3049
	local ____temp_169 = { -- 3050
		pending = function() return __TS__ArrayMap( -- 3051
			__TS__ArrayFilter( -- 3051
				InputInbox.listInputs(session.id), -- 3051
				function(____, item) return item.delivery == "steer" and not item.held and item.status == "pending" end -- 3051
			), -- 3051
			function(____, item) return {id = item.id, content = item.content} end -- 3051
		) end, -- 3051
		delivered = function(id, step) return followup.delivered(session.id, taskId, id, step) end -- 3052
	} -- 3052
	local ____temp_170 = options and options.resumeConversation -- 3054
	local ____temp_171 = (options and options.existingTaskId) ~= nil -- 3055
	local ____temp_172 = options and options.initialStep -- 3056
	local ____temp_173 = options and options.initialAgentStepCount -- 3057
	local ____temp_162 -- 3058
	if (options and options.existingTaskId) ~= nil then -- 3058
		____temp_162 = getInitialTokenUsage(session) -- 3058
	else -- 3058
		____temp_162 = nil -- 3058
	end -- 3058
	____runCodingAgent_176( -- 3047
		{ -- 3047
			prompt = ____normalizedPrompt_167, -- 3048
			inputId = ____temp_168, -- 3049
			inputSource = ____temp_169, -- 3050
			resumeConversation = ____temp_170, -- 3054
			resumeTask = ____temp_171, -- 3055
			initialStep = ____temp_172, -- 3056
			initialAgentStepCount = ____temp_173, -- 3057
			initialTokenUsage = ____temp_162, -- 3058
			workDir = session.projectRoot, -- 3059
			useChineseResponse = useChineseResponse, -- 3060
			taskId = taskId, -- 3061
			sessionId = session.id, -- 3062
			memoryScope = session.memoryScope, -- 3063
			role = session.kind, -- 3064
			maxSteps = options and options.maxSteps, -- 3065
			disabledAgentTools = disabledAgentTools, -- 3066
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 3067
			llmConfig = llmConfig, -- 3068
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 3069
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 3072
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 3075
			stopToken = stopToken, -- 3076
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 3077
		}, -- 3077
		function(result) -- 3078
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3078
				local ____hasReturned, ____returnValue -- 3078
				local ____try = __TS__AsyncAwaiter(function() -- 3078
					local nextSession = getSessionItem(session.id) -- 3080
					if nextSession and nextSession.kind == "sub" then -- 3080
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 3080
							local stopped = stopClearedSubSession(nextSession, taskId) -- 3083
							if not stopped.success then -- 3083
								Log( -- 3085
									"Warn", -- 3085
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 3085
								) -- 3085
								emitAgentSessionPatch( -- 3086
									session.id, -- 3086
									{session = getSessionItem(session.id)} -- 3086
								) -- 3086
							end -- 3086
							__TS__Delete(activeStopTokens, taskId) -- 3090
							____hasReturned = true -- 3091
							return -- 3091
						end -- 3091
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3093
						emitAgentSessionPatch( -- 3094
							session.id, -- 3094
							{session = getSessionItem(session.id)} -- 3094
						) -- 3094
						local finalized = __TS__Await(finalizeSubSession( -- 3097
							nextSession, -- 3098
							taskId, -- 3099
							result.success, -- 3100
							result.message, -- 3101
							result.completion, -- 3102
							(options and options.forceSubAgentHandoff) == true -- 3103
						)) -- 3103
						if not finalized.success then -- 3103
							Log( -- 3106
								"Warn", -- 3106
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 3106
							) -- 3106
						end -- 3106
						local finalizedSession = getSessionItem(session.id) -- 3108
						if finalizedSession then -- 3108
							local stopped = stopToken.stopped == true -- 3110
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 3111
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 3114
							emitAgentSessionPatch( -- 3115
								session.id, -- 3115
								{session = getSessionItem(session.id)} -- 3115
							) -- 3115
						end -- 3115
						__TS__Delete(activeStopTokens, taskId) -- 3119
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 3120
					end -- 3120
					local fallbackSession = getSessionItem(session.id) -- 3122
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 3122
						applyEvent(session.id, { -- 3128
							type = "task_finished", -- 3129
							sessionId = session.id, -- 3130
							taskId = result.taskId, -- 3131
							success = false, -- 3132
							message = result.message, -- 3133
							steps = result.steps -- 3134
						}) -- 3134
					end -- 3134
				end) -- 3134
				____try = ____try.finally( -- 3134
					____try, -- 3134
					function() -- 3134
						return __TS__AsyncAwaiter(function() -- 3134
							activePromptRuns = activePromptRuns - 1 -- 3138
							followup.settle(session.id, taskId, result.success and not result.waitingForUser and not stopToken.stopped) -- 3139
						end) -- 3139
					end -- 3139
				) -- 3139
				__TS__Await(____try) -- 3079
				if ____hasReturned then -- 3079
					return ____awaiter_resolve(nil, ____returnValue) -- 3079
				end -- 3079
			end) -- 3079
		end -- 3078
	) -- 3078
	return {success = true, sessionId = session.id, taskId = taskId} -- 3142
end -- 3142
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3296
	local lines = {} -- 3297
	do -- 3297
		local i = 0 -- 3298
		while i < #questionnaire.schema.questions do -- 3298
			local question = questionnaire.schema.questions[i + 1] -- 3299
			local answer = __TS__ArrayFind( -- 3300
				answers, -- 3300
				function(____, item) return item.questionId == question.id end -- 3300
			) -- 3300
			local answerText = "已跳过" -- 3301
			if answer and answer.status == "answered" then -- 3301
				local parts = {} -- 3303
				do -- 3303
					local j = 0 -- 3304
					while j < #(answer.selectedOptionIds or ({})) do -- 3304
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3305
						local option = __TS__ArrayFind( -- 3306
							question.options or ({}), -- 3306
							function(____, item) return item.id == optionId end -- 3306
						) -- 3306
						if option then -- 3306
							parts[#parts + 1] = option.label -- 3307
						end -- 3307
						j = j + 1 -- 3304
					end -- 3304
				end -- 3304
				if answer.otherText then -- 3304
					parts[#parts + 1] = answer.otherText -- 3309
				end -- 3309
				if answer.text then -- 3309
					parts[#parts + 1] = answer.text -- 3310
				end -- 3310
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3311
			end -- 3311
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3313
			i = i + 1 -- 3298
		end -- 3298
	end -- 3298
	return table.concat(lines, "\n\n") -- 3315
end -- 3315
function ____exports.listRunningSubAgents(request) -- 3602
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3602
		local session = getSessionItem(request.sessionId) -- 3610
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3610
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3612
		end -- 3612
		if not session then -- 3612
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3612
		end -- 3612
		local rootSession = getRootSessionItem(session.id) -- 3617
		if not rootSession then -- 3617
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3617
		end -- 3617
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3621
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3622
		local limit = math.max( -- 3623
			1, -- 3623
			math.floor(tonumber(request.limit) or 5) -- 3623
		) -- 3623
		local offset = math.max( -- 3624
			0, -- 3624
			math.floor(tonumber(request.offset) or 0) -- 3624
		) -- 3624
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3625
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3626
		local runningSessions = {} -- 3633
		do -- 3633
			local i = 0 -- 3634
			while i < #rows do -- 3634
				do -- 3634
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3635
					if current.currentTaskStatus ~= "RUNNING" then -- 3635
						goto __continue663 -- 3637
					end -- 3637
					local spawnInfo = getSessionSpawnInfo(current) -- 3639
					runningSessions[#runningSessions + 1] = { -- 3640
						sessionId = current.id, -- 3641
						title = current.title, -- 3642
						parentSessionId = current.parentSessionId, -- 3643
						rootSessionId = current.rootSessionId, -- 3644
						status = "RUNNING", -- 3645
						currentTaskId = current.currentTaskId, -- 3646
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3647
						goal = spawnInfo and spawnInfo.goal, -- 3648
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3649
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3650
						createdAt = current.createdAt, -- 3651
						updatedAt = current.updatedAt -- 3652
					} -- 3652
				end -- 3652
				::__continue663:: -- 3652
				i = i + 1 -- 3634
			end -- 3634
		end -- 3634
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3655
		local completedSessions = __TS__ArrayMap( -- 3656
			completedRecords, -- 3656
			function(____, record) return { -- 3656
				sessionId = record.sessionId, -- 3657
				title = record.title, -- 3658
				parentSessionId = record.parentSessionId, -- 3659
				rootSessionId = record.rootSessionId, -- 3660
				status = record.status, -- 3661
				goal = record.goal, -- 3662
				expectedOutput = record.expectedOutput, -- 3663
				filesHint = record.filesHint, -- 3664
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3665
				success = record.success, -- 3666
				cleared = record.cleared, -- 3667
				resultFilePath = record.resultFilePath, -- 3668
				artifactDir = record.artifactDir, -- 3669
				finishedAt = record.finishedAt, -- 3670
				createdAt = record.createdAtTs, -- 3671
				updatedAt = record.finishedAtTs -- 3672
			} end -- 3672
		) -- 3672
		local merged = {} -- 3674
		if status == "running" then -- 3674
			merged = runningSessions -- 3676
		elseif status == "done" then -- 3676
			merged = __TS__ArrayFilter( -- 3678
				completedSessions, -- 3678
				function(____, item) return item.status == "DONE" end -- 3678
			) -- 3678
		elseif status == "failed" then -- 3678
			merged = __TS__ArrayFilter( -- 3680
				completedSessions, -- 3680
				function(____, item) return item.status == "FAILED" end -- 3680
			) -- 3680
		elseif status == "stopped" then -- 3680
			merged = __TS__ArrayFilter( -- 3682
				completedSessions, -- 3682
				function(____, item) return item.status == "STOPPED" end -- 3682
			) -- 3682
		elseif status == "all" then -- 3682
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3684
		else -- 3684
			local runningKeys = {} -- 3686
			do -- 3686
				local i = 0 -- 3687
				while i < #runningSessions do -- 3687
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3688
					i = i + 1 -- 3687
				end -- 3687
			end -- 3687
			local latestCompletedByKey = {} -- 3690
			do -- 3690
				local i = 0 -- 3691
				while i < #completedSessions do -- 3691
					do -- 3691
						local item = completedSessions[i + 1] -- 3692
						local key = getSubAgentDisplayKey(item) -- 3693
						if runningKeys[key] then -- 3693
							goto __continue678 -- 3695
						end -- 3695
						local current = latestCompletedByKey[key] -- 3697
						if current == nil or item.updatedAt > current.updatedAt then -- 3697
							latestCompletedByKey[key] = item -- 3699
						end -- 3699
					end -- 3699
					::__continue678:: -- 3699
					i = i + 1 -- 3691
				end -- 3691
			end -- 3691
			local latestCompleted = {} -- 3702
			for ____, item in pairs(latestCompletedByKey) do -- 3703
				latestCompleted[#latestCompleted + 1] = item -- 3704
			end -- 3704
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3706
		end -- 3706
		if query ~= "" then -- 3706
			merged = __TS__ArrayFilter( -- 3709
				merged, -- 3709
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3709
			) -- 3709
		end -- 3709
		__TS__ArraySort( -- 3715
			merged, -- 3715
			function(____, a, b) -- 3715
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3715
					return -1 -- 3716
				end -- 3716
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3716
					return 1 -- 3717
				end -- 3717
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3717
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3719
				end -- 3719
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3721
			end -- 3715
		) -- 3715
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3723
		return ____awaiter_resolve(nil, { -- 3723
			success = true, -- 3725
			rootSessionId = rootSession.id, -- 3726
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3727
			status = status, -- 3728
			limit = limit, -- 3729
			offset = offset, -- 3730
			hasMore = offset + limit < #merged, -- 3731
			sessions = paged -- 3732
		}) -- 3732
	end) -- 3732
end -- 3602
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 284
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 285
SPAWN_INFO_FILE = "SPAWN.json" -- 286
RESULT_FILE = "RESULT.md" -- 287
PENDING_HANDOFF_DIR = "pending-handoffs" -- 288
MAX_CONCURRENT_SUB_AGENTS = 4 -- 289
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 290
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 291
activeStopTokens = {} -- 341
followup = { -- 344
	activeRuns = {}, -- 345
	pendingWakes = 0, -- 346
	configs = {}, -- 347
	recovered = {}, -- 348
	bindings = {}, -- 349
	publish = nil, -- 350
	recover = nil, -- 351
	delivered = nil, -- 352
	dispatch = nil, -- 353
	settle = nil, -- 354
	submit = nil -- 355
} -- 355
followup.publish = function(sessionId) -- 360
	emitAgentSessionPatch( -- 361
		sessionId, -- 361
		{session = getSessionItem(sessionId)} -- 361
	) -- 361
end -- 360
followup.recover = function(session) -- 363
	if followup.recovered[session.id] or followup.activeRuns[session.id] then -- 363
		return -- 364
	end -- 364
	followup.recovered[session.id] = true -- 365
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 366
	local history = storage:readSessionState().messages -- 367
	for ____, input in ipairs(InputInbox.listInputs(session.id)) do -- 368
		local message = __TS__ArrayFind( -- 369
			history, -- 369
			function(____, item) return item.inputId == input.id end -- 369
		) -- 369
		if message then -- 369
			followup.delivered(session.id, message.taskId or session.currentTaskId or 0, input.id, message.afterStep or 0) -- 370
		end -- 370
	end -- 370
	InputInbox.recoverInputs(session.id) -- 372
end -- 363
followup.delivered = function(sessionId, taskId, inputId, step) -- 374
	local input = InputInbox.getInput(sessionId, inputId) -- 375
	if not input or input.status == "delivered" then -- 375
		return -- 376
	end -- 376
	local receipt = queryOne("SELECT message_id FROM agent.AgentSessionInput WHERE id=?", {inputId}) -- 377
	local messageId = type(receipt and receipt[1]) == "number" and receipt[1] > 0 and receipt[1] or nil -- 378
	if not messageId then -- 378
		if not DB:transaction({ -- 378
			{ -- 381
				("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id,task_id,role,content,display_content,created_at,updated_at) VALUES(?,?,'user',?,'',?,?)", -- 381
				{{ -- 381
					sessionId, -- 381
					taskId, -- 381
					input.content, -- 381
					now(), -- 381
					now() -- 381
				}} -- 381
			}, -- 381
			{"UPDATE agent.AgentSessionInput SET message_id=last_insert_rowid(),delivered_step=?,status='delivered' WHERE id=?", {{step, inputId}}} -- 382
		}) then -- 382
			error( -- 383
				__TS__New(Error, "failed to commit input display"), -- 383
				0 -- 383
			) -- 383
		end -- 383
		local saved = queryOne("SELECT message_id FROM agent.AgentSessionInput WHERE id=?", {inputId}) -- 384
		messageId = saved and saved[1] -- 385
	else -- 385
		InputInbox.markDelivered(inputId, messageId, step) -- 386
	end -- 386
	__TS__Delete(followup.configs, inputId) -- 387
	emitAgentSessionPatch( -- 388
		sessionId, -- 388
		{ -- 388
			session = getSessionItem(sessionId), -- 388
			message = getMessageItem(messageId) -- 388
		} -- 388
	) -- 388
end -- 374
followup.dispatch = function(sessionId) -- 390
	local session = getSessionItem(sessionId) -- 391
	if not session or followup.activeRuns[sessionId] ~= nil or session.currentTaskFinalizing or getPendingQuestionnaire(sessionId) or isProjectTaskAdmissionClosed(session.projectRoot) or session.currentTaskStatus == "RUNNING" then -- 391
		return nil -- 393
	end -- 393
	local input = InputInbox.listInputs(sessionId)[1] -- 394
	if input == nil then -- 394
		__TS__Delete(followup.bindings, sessionId) -- 395
		return nil -- 395
	end -- 395
	if input.held or input.status ~= "pending" then -- 395
		return nil -- 396
	end -- 396
	local binding = followup.bindings[sessionId] -- 397
	if binding == nil then -- 397
		InputInbox.holdInputs(sessionId) -- 398
		followup.publish(sessionId) -- 398
		return nil -- 398
	end -- 398
	local options = input.options -- 399
	local result -- 400
	if type(options.localAgentConfigId) == "number" then -- 400
		result = startLocalPrompt(sessionId, input.content, options.localAgentConfigId, input.id) -- 402
	else -- 402
		local ____startImmediatePrompt_6 = startImmediatePrompt -- 404
		local ____array_5 = __TS__SparseArrayNew(sessionId, input.content, options.disabledAgentTools, options.workMode) -- 404
		local ____options_llmConfigId_4 = options.llmConfigId -- 405
		if ____options_llmConfigId_4 == nil then -- 405
			____options_llmConfigId_4 = binding.llmConfigId -- 405
		end -- 405
		__TS__SparseArrayPush( -- 405
			____array_5, -- 405
			____options_llmConfigId_4, -- 405
			followup.configs[input.id] or binding.llmConfig, -- 405
			options.maxSteps, -- 405
			input.id -- 405
		) -- 405
		result = ____startImmediatePrompt_6(__TS__SparseArraySpread(____array_5)) -- 404
	end -- 404
	if not result.success then -- 404
		InputInbox.holdInputs(sessionId) -- 407
		followup.publish(sessionId) -- 407
	end -- 407
	return result -- 408
end -- 390
followup.settle = function(sessionId, taskId, succeeded) -- 410
	if followup.activeRuns[sessionId] ~= taskId then -- 410
		return -- 411
	end -- 411
	__TS__Delete(followup.activeRuns, sessionId) -- 412
	if not succeeded then -- 412
		InputInbox.holdInputs(sessionId) -- 413
	else -- 413
		DB:exec("UPDATE agent.AgentSessionInput SET delivery='queue' WHERE session_id=? AND status='pending'", {sessionId}) -- 416
	end -- 416
	followup.publish(sessionId) -- 418
	if succeeded then -- 418
		followup.pendingWakes = followup.pendingWakes + 1 -- 420
		Director.systemScheduler:schedule(function() -- 421
			do -- 421
				local ____try, ____error = pcall(function() -- 421
					followup.dispatch(sessionId) -- 421
				end) -- 421
				do -- 421
					followup.pendingWakes = followup.pendingWakes - 1 -- 421
				end -- 421
				if not ____try then -- 421
					error(____error, 0) -- 421
				end -- 421
			end -- 421
			return true -- 421
		end) -- 421
	end -- 421
end -- 410
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId, submission) -- 429
	local ____opt_7 = getSessionItem(sessionId) -- 429
	if (____opt_7 and ____opt_7.kind) ~= "main" then -- 429
		return {success = false, message = "local Agent only supports main sessions"} -- 430
	end -- 430
	local id = tonumber(localAgentConfigId) -- 431
	if not id then -- 431
		return {success = false, message = "invalid local Agent config"} -- 432
	end -- 432
	return followup.submit( -- 433
		sessionId, -- 433
		prompt, -- 433
		{localAgentConfigId = id}, -- 433
		{localAgentConfigId = id}, -- 433
		submission -- 433
	) -- 433
end -- 429
followup.submit = function(sessionId, prompt, options, binding, submission) -- 435
	if submission ~= nil and type(submission) ~= "table" then -- 435
		return {success = false, message = "invalid input submission"} -- 436
	end -- 436
	local session = getSessionItem(sessionId) -- 437
	if not session then -- 437
		return {success = false, message = "session not found"} -- 438
	end -- 438
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 438
		return {success = false, message = "project task admission is closed"} -- 439
	end -- 439
	if session.kind ~= "main" then -- 439
		return startImmediatePrompt( -- 440
			sessionId, -- 440
			prompt, -- 440
			options.disabledAgentTools, -- 440
			options.workMode, -- 440
			options.llmConfigId, -- 440
			binding.llmConfig, -- 440
			options.maxSteps -- 440
		) -- 440
	end -- 440
	if (submission and submission.delivery) ~= nil and submission.delivery ~= "steer" and submission.delivery ~= "queue" then -- 440
		return {success = false, message = "invalid input delivery"} -- 441
	end -- 441
	if (submission and submission.requestId) ~= nil and (type(submission.requestId) ~= "string" or #submission.requestId > 128 or submission.requestId == "") then -- 441
		return {success = false, message = "invalid input request ID"} -- 442
	end -- 442
	do -- 442
		local function ____catch(____error) -- 442
			return true, { -- 491
				success = false, -- 491
				message = tostring(____error) -- 491
			} -- 491
		end -- 491
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 491
			followup.recover(session) -- 444
			followup.bindings[sessionId] = binding -- 445
			if submission and submission.action then -- 445
				if submission.action == "resume" and binding.llmConfig then -- 445
					for ____, item in ipairs(InputInbox.listInputs(sessionId)) do -- 448
						followup.configs[item.id] = binding.llmConfig -- 448
					end -- 448
				end -- 448
				InputInbox.mutateInput( -- 450
					sessionId, -- 450
					submission, -- 450
					normalizePromptTextSafe(prompt) -- 450
				) -- 450
				if submission.action == "cancel" and submission.inputId ~= nil then -- 450
					__TS__Delete(followup.configs, submission.inputId) -- 451
				end -- 451
				followup.publish(sessionId) -- 452
				local next = followup.dispatch(sessionId) -- 453
				return true, next or ({success = true, sessionId = sessionId, taskId = session.currentTaskId or 0}) -- 454
			end -- 454
			if getPendingQuestionnaire(sessionId) then -- 454
				return true, {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 456
			end -- 456
			if binding.localAgentConfigId ~= nil then -- 456
				local config = LocalAgent.getConfig(binding.localAgentConfigId) -- 458
				if not (config and config.verifiedAt) then -- 458
					return true, {success = false, message = "local Agent config is not verified"} -- 459
				end -- 459
			else -- 459
				local resolved = binding.llmConfig and ({success = true, config = binding.llmConfig}) or getLLMConfig(binding.llmConfigId) -- 461
				if not resolved.success then -- 461
					return true, {success = false, message = resolved.message} -- 462
				end -- 462
				local valid = validateAgentLLMConfig(resolved.config) -- 463
				if not valid.success then -- 463
					return true, valid -- 464
				end -- 464
			end -- 464
			local content = normalizePromptTextSafe(prompt) -- 466
			if content == "" then -- 466
				return true, {success = false, message = "prompt is empty"} -- 467
			end -- 467
			local pending = InputInbox.listInputs(sessionId) -- 468
			if followup.activeRuns[sessionId] == nil and session.currentTaskStatus ~= "RUNNING" and not session.currentTaskFinalizing and #pending == 0 then -- 468
				return true, binding.localAgentConfigId ~= nil and startLocalPrompt(sessionId, content, binding.localAgentConfigId) or startImmediatePrompt( -- 473
					sessionId, -- 475
					content, -- 475
					options.disabledAgentTools, -- 475
					options.workMode, -- 475
					options.llmConfigId, -- 476
					binding.llmConfig, -- 476
					options.maxSteps -- 476
				) -- 476
			end -- 476
			local requestId = submission and submission.requestId or (((("input-" .. tostring(sessionId)) .. "-") .. tostring(os.time())) .. "-") .. tostring(math.random(1, 1000000000)) -- 478
			local ____temp_21 = followup.activeRuns[sessionId] ~= nil -- 479
			if ____temp_21 then -- 479
				local ____opt_19 = activeStopTokens[session.currentTaskId or -1] -- 479
				____temp_21 = not (____opt_19 and ____opt_19.stopped) -- 479
			end -- 479
			local isActive = ____temp_21 -- 479
			local delivery = content ~= "/clear" and content ~= "/compact" and isActive and not binding.localAgentConfigId and (submission and submission.delivery) == "steer" and "steer" or "queue" -- 480
			local wasPaused = __TS__ArraySome( -- 481
				pending, -- 481
				function(____, item) return item.held end -- 481
			) -- 481
			local ____InputInbox_admitInput_27 = InputInbox.admitInput -- 482
			local ____sessionId_25 = sessionId -- 482
			local ____options_26 = options -- 482
			local ____temp_24 -- 482
			if delivery == "steer" then -- 482
				____temp_24 = session.currentTaskId -- 482
			else -- 482
				____temp_24 = nil -- 482
			end -- 482
			local input = ____InputInbox_admitInput_27( -- 482
				____sessionId_25, -- 482
				content, -- 482
				delivery, -- 482
				requestId, -- 482
				____options_26, -- 482
				____temp_24 -- 482
			) -- 482
			if wasPaused and delivery == "queue" then -- 482
				InputInbox.holdInputs(sessionId) -- 483
			end -- 483
			if input.status == "delivered" or input.status == "cancelled" then -- 483
				return true, {success = true, sessionId = sessionId, taskId = input.taskId or session.currentTaskId or 0} -- 484
			end -- 484
			if binding.llmConfig then -- 484
				followup.configs[input.id] = binding.llmConfig -- 485
			end -- 485
			local next = followup.dispatch(sessionId) -- 486
			if not next then -- 486
				followup.publish(sessionId) -- 489
			end -- 489
			return true, next or ({success = true, sessionId = sessionId, taskId = session.currentTaskId or 0}) -- 490
		end) -- 490
		if not ____try then -- 490
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 490
		end -- 490
		if ____hasReturned then -- 490
			return ____returnValue -- 443
		end -- 443
	end -- 443
end -- 435
activeLocalAgentControls = {} -- 493
finalizingSubSessionTaskIds = {} -- 494
activePromptRuns = 0 -- 495
streamUpdates = __TS__New( -- 497
	StreamUpdates, -- 497
	function(sessionId, taskId, step, value) -- 497
		local ____opt_28 = getSessionItem(sessionId) -- 497
		if (____opt_28 and ____opt_28.currentTaskId) ~= taskId then -- 497
			return -- 498
		end -- 498
		upsertStep( -- 499
			sessionId, -- 499
			taskId, -- 499
			step, -- 499
			"message", -- 499
			{status = "RUNNING", reason = value.content, reasoningContent = value.reasoningContent} -- 499
		) -- 499
		emitAgentSessionPatch( -- 502
			sessionId, -- 502
			{step = getStepItem(sessionId, taskId, step)} -- 502
		) -- 502
	end -- 497
) -- 497
streamFlushScheduled = false -- 504
--- Runtime ownership, including asynchronous completion after task status changes.
function ____exports.isRuntimeIdle() -- 517
	return followup.pendingWakes == 0 and activePromptRuns == 0 and #__TS__ObjectKeys(activeStopTokens) == 0 and #__TS__ObjectKeys(activeLocalAgentControls) == 0 and #__TS__ObjectKeys(finalizingSubSessionTaskIds) == 0 -- 518
end -- 517
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 523
now = function() return os.time() end -- 524
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1196
	if projectRoot == oldRoot then -- 1196
		return newRoot -- 1198
	end -- 1198
	for ____, separator in ipairs({"/", "\\"}) do -- 1200
		local prefix = oldRoot .. separator -- 1201
		if __TS__StringStartsWith(projectRoot, prefix) then -- 1201
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1203
		end -- 1203
	end -- 1203
	return nil -- 1206
end -- 1196
local function clearSessionAfterMessage(sessionId, message) -- 1745
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1746
	local removedStepIds = {} -- 1754
	do -- 1754
		local i = 0 -- 1755
		while i < #removedStepRows do -- 1755
			local row = removedStepRows[i + 1] -- 1756
			if type(row[1]) == "number" then -- 1756
				removedStepIds[#removedStepIds + 1] = row[1] -- 1758
			end -- 1758
			i = i + 1 -- 1755
		end -- 1755
	end -- 1755
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1761
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1769
	return removedStepIds -- 1774
end -- 1745
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1777
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1778
	local persisted = storage:readSessionState() -- 1779
	local userIndex = -1 -- 1780
	do -- 1780
		local i = #persisted.messages - 1 -- 1781
		while i >= 0 do -- 1781
			if persisted.messages[i + 1].role == "user" and persisted.messages[i + 1].inputKind ~= "steer" then -- 1781
				userIndex = i -- 1783
				break -- 1784
			end -- 1784
			i = i - 1 -- 1781
		end -- 1781
	end -- 1781
	if userIndex < 0 then -- 1781
		return -- 1787
	end -- 1787
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex) -- 1788
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages) -- 1789
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1790
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1795
end -- 1777
local function listCurrentTaskCheckpoints(sessionId) -- 1807
	local session = getSessionItem(sessionId) -- 1808
	local taskId = session and session.currentTaskId -- 1809
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1810
end -- 1807
local function getAgentStepCount(sessionId, taskId) -- 1917
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1918
		sessionId, -- 1923
		taskId, -- 1924
		"compress_memory", -- 1925
		"merge_memory", -- 1926
		"sub_agent_handoff", -- 1927
		"questionnaire_answer", -- 1928
		"message" -- 1929
	}) -- 1929
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 1932
end -- 1917
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 1935
	if status == nil then -- 1935
		status = "DONE" -- 1943
	end -- 1943
	local step = getNextStepNumber(sessionId, taskId) -- 1945
	upsertStep( -- 1946
		sessionId, -- 1946
		taskId, -- 1946
		step, -- 1946
		tool, -- 1946
		{status = status, reason = reason, params = params, result = result} -- 1946
	) -- 1946
	return getStepItem(sessionId, taskId, step) -- 1952
end -- 1935
local function sanitizeStoredSteps(sessionId) -- 2019
	DB:exec( -- 2020
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 2020
		{ -- 2038
			now(), -- 2038
			sessionId -- 2038
		} -- 2038
	) -- 2038
end -- 2019
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2512
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2512
		return {success = false, message = "invalid projectRoot"} -- 2514
	end -- 2514
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2516
	for ____, row in ipairs(rows) do -- 2517
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2518
		if sessionId > 0 then -- 2518
			deleteSessionRecords(sessionId) -- 2520
		end -- 2520
	end -- 2520
	return {success = true, deleted = #rows} -- 2523
end -- 2512
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2526
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2526
		return {success = false, message = "invalid projectRoot"} -- 2528
	end -- 2528
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2530
	local renamed = 0 -- 2531
	for ____, row in ipairs(rows) do -- 2532
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2533
		local projectRoot = toStr(row[2]) -- 2534
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2535
		if sessionId > 0 and nextProjectRoot then -- 2535
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2537
			DB:exec( -- 2538
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2538
				{ -- 2540
					nextProjectRoot, -- 2540
					Path:getFilename(nextProjectRoot), -- 2540
					now(), -- 2540
					sessionId -- 2540
				} -- 2540
			) -- 2540
			renamed = renamed + 1 -- 2542
		end -- 2542
	end -- 2542
	return {success = true, renamed = renamed} -- 2545
end -- 2526
function ____exports.getSession(sessionId, view) -- 2548
	local session = getSessionItem(sessionId) -- 2549
	if not session then -- 2549
		return {success = false, message = "session not found"} -- 2551
	end -- 2551
	if followup.activeRuns[sessionId] == nil then -- 2551
		followup.recover(session) -- 2553
	end -- 2553
	local restored = restorePendingQuestionnaireState(session) -- 2554
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2555
	local ____opt_96 = getSessionItem(sessionId) -- 2555
	normalizedSession.pendingInputs = ____opt_96 and ____opt_96.pendingInputs -- 2556
	local relatedSessions = listRelatedSessions(sessionId) -- 2557
	sanitizeStoredSteps(sessionId) -- 2558
	local firstMessageId = 0 -- 2559
	local hasEarlierMessages = false -- 2560
	if view then -- 2560
		local limit = math.max( -- 2562
			1, -- 2562
			math.min( -- 2562
				1000, -- 2562
				math.floor(view.recentRounds) -- 2562
			) -- 2562
		) -- 2562
		local requests = queryRows(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m WHERE m.session_id = ? AND m.role = 'user'\n    AND NOT EXISTS (SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n\t\t\tORDER BY m.id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2563
		if #requests > limit then -- 2563
			firstMessageId = requests[limit][1] -- 2569
			hasEarlierMessages = true -- 2570
		end -- 2570
	end -- 2570
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2573
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2580
	local ____relatedSessions_103 = relatedSessions -- 2592
	local ____temp_102 -- 2593
	if normalizedSession.kind == "sub" then -- 2593
		____temp_102 = getSessionSpawnInfo(normalizedSession) -- 2593
	else -- 2593
		____temp_102 = nil -- 2593
	end -- 2593
	return { -- 2589
		success = true, -- 2590
		session = normalizedSession, -- 2591
		relatedSessions = ____relatedSessions_103, -- 2592
		spawnInfo = ____temp_102, -- 2593
		messages = __TS__ArrayMap( -- 2594
			messages, -- 2594
			function(____, row) return rowToMessage(row) end -- 2594
		), -- 2594
		hasEarlierMessages = hasEarlierMessages, -- 2595
		steps = __TS__ArrayMap( -- 2596
			steps, -- 2596
			function(____, row) return rowToStep(row) end -- 2596
		), -- 2596
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2597
		pendingQuestionnaire = restored.questionnaire, -- 2598
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2599
	} -- 2599
end -- 2548
function ____exports.setWorkMode(sessionId, workMode) -- 2604
	local session = getSessionItem(sessionId) -- 2605
	if not session then -- 2605
		return {success = false, message = "session not found"} -- 2606
	end -- 2606
	if session.kind ~= "main" then -- 2606
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2607
	end -- 2607
	if workMode ~= "code" and workMode ~= "plan" then -- 2607
		return {success = false, message = "invalid work mode"} -- 2608
	end -- 2608
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2609
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2609
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2611
	end -- 2611
	if getPendingQuestionnaire(sessionId) then -- 2611
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2614
	end -- 2614
	if normalizedSession.workMode ~= workMode then -- 2614
		DB:exec( -- 2617
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2617
			{ -- 2617
				workMode, -- 2617
				now(), -- 2617
				sessionId -- 2617
			} -- 2617
		) -- 2617
	end -- 2617
	local updated = getSessionItem(sessionId) -- 2619
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2620
	return { -- 2621
		success = true, -- 2621
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2621
	} -- 2621
end -- 2604
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId, llmConfig) -- 2920
	local session = getSessionItem(sessionId) -- 2921
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2921
		return {success = false, message = "project task admission is closed"} -- 2922
	end -- 2922
	if not session then -- 2922
		return {success = false, message = "session not found"} -- 2924
	end -- 2924
	if getPendingQuestionnaire(sessionId) then -- 2924
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2926
	end -- 2926
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2926
		return {success = false, message = "session task is finalizing"} -- 2928
	end -- 2928
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 2928
		return {success = false, message = "session task is still stopping"} -- 2931
	end -- 2931
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 2931
		return {success = false, message = "session task is not continuable"} -- 2934
	end -- 2934
	if session.currentTaskId == nil then -- 2934
		return {success = false, message = "session task not found"} -- 2937
	end -- 2937
	local resolved = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 2939
	if not resolved.success then -- 2939
		return {success = false, message = resolved.message} -- 2940
	end -- 2940
	followup.recover(session) -- 2941
	local previousBinding = followup.bindings[sessionId] -- 2942
	followup.bindings[sessionId] = {llmConfig = resolved.config, llmConfigId = llmConfigId} -- 2943
	local taskId = session.currentTaskId -- 2944
	local result = startPromptTask( -- 2945
		session, -- 2946
		"", -- 2947
		nil, -- 2948
		normalizeDisabledAgentTools(disabledAgentTools), -- 2949
		{ -- 2950
			workMode = session.workMode, -- 2951
			persistUserMessage = false, -- 2952
			resumeConversation = true, -- 2953
			existingTaskId = taskId, -- 2954
			initialStep = math.max( -- 2955
				0, -- 2955
				getNextStepNumber(session.id, taskId) - 1 -- 2955
			), -- 2955
			initialAgentStepCount = 0, -- 2959
			llmConfigId = llmConfigId, -- 2960
			llmConfig = resolved.config -- 2961
		} -- 2961
	) -- 2961
	if result.success then -- 2961
		for ____, input in ipairs(InputInbox.listInputs(sessionId)) do -- 2967
			followup.configs[input.id] = resolved.config -- 2967
		end -- 2967
		InputInbox.mutateInput(sessionId, {action = "resume"}, "") -- 2968
		followup.publish(sessionId) -- 2969
	elseif previousBinding ~= nil then -- 2969
		followup.bindings[sessionId] = previousBinding -- 2970
	else -- 2970
		__TS__Delete(followup.bindings, sessionId) -- 2971
	end -- 2971
	return result -- 2972
end -- 2920
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 3145
	local session = getSessionItem(sessionId) -- 3146
	if not session then -- 3146
		return {success = false, message = "session not found"} -- 3148
	end -- 3148
	if session.kind ~= "sub" then -- 3148
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 3151
	end -- 3151
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3151
		return {success = false, message = "session task is finalizing"} -- 3154
	end -- 3154
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3156
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 3156
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 3161
	end -- 3161
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 3161
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 3164
	end -- 3164
	local disabledAgentTools = AgentToolRegistry.getAllowedToolsForRole("sub") -- 3166
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并给出最终总结。不要再调用任何工具；用纯文本如实总结已完成内容、文件变更、验证状态和剩余问题。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Use plain text only, without tools, to summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 3167
	return startPromptTask( -- 3170
		session, -- 3170
		prompt, -- 3170
		nil, -- 3170
		disabledAgentTools, -- 3170
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 3170
	) -- 3170
end -- 3145
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 3177
	local session = getSessionItem(sessionId) -- 3178
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3178
		return {success = false, message = "project task admission is closed"} -- 3179
	end -- 3179
	if not session then -- 3179
		return {success = false, message = "session not found"} -- 3181
	end -- 3181
	if #InputInbox.listInputs(sessionId) > 0 then -- 3181
		return {success = false, message = "finish or remove pending messages before editing task history"} -- 3183
	end -- 3183
	if getPendingQuestionnaire(sessionId) then -- 3183
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 3184
	end -- 3184
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3184
		return {success = false, message = "session task is finalizing"} -- 3186
	end -- 3186
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 3186
		return {success = false, message = "session task is still running"} -- 3189
	end -- 3189
	local message = getMessageItem(messageId) -- 3191
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 3191
		return {success = false, message = "message not found"} -- 3193
	end -- 3193
	local latestUserRow = queryOne(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m\n  WHERE m.session_id = ? AND m.role = ? AND NOT EXISTS (\n   SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n  ORDER BY m.id DESC LIMIT 1", {sessionId, "user"}) -- 3195
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 3202
	if latestUserMessageId ~= messageId then -- 3202
		return {success = false, message = "only the latest user prompt can be edited"} -- 3204
	end -- 3204
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 3206
	if normalizedPrompt == "" then -- 3206
		return {success = false, message = "prompt is empty"} -- 3208
	end -- 3208
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 3210
	if session.workMode ~= nextWorkMode then -- 3210
		DB:exec( -- 3212
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 3212
			{ -- 3212
				nextWorkMode, -- 3212
				now(), -- 3212
				session.id -- 3212
			} -- 3212
		) -- 3212
		session.workMode = nextWorkMode -- 3213
	end -- 3213
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 3215
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 3216
	local result = startPromptTask( -- 3217
		session, -- 3217
		normalizedPrompt, -- 3217
		messageId, -- 3217
		normalizeDisabledAgentTools(disabledAgentTools), -- 3217
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 3217
	) -- 3217
	if result.success and #removedStepIds > 0 then -- 3217
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 3219
	end -- 3219
	return result -- 3221
end -- 3177
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 3226
	if status == "dismissed" then -- 3226
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 3232
	end -- 3232
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3234
end -- 3226
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3237
	if status == "dismissed" then -- 3237
		return { -- 3243
			success = true, -- 3244
			status = "dismissed", -- 3245
			source = "user", -- 3246
			questionnaireId = questionnaire.id, -- 3247
			title = questionnaire.schema.title, -- 3248
			answers = {}, -- 3249
			responses = {}, -- 3250
			displayText = "用户关闭了调查问卷，未作答。", -- 3251
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 3252
		} -- 3252
	end -- 3252
	local responses = {} -- 3255
	do -- 3255
		local i = 0 -- 3256
		while i < #questionnaire.schema.questions do -- 3256
			do -- 3256
				local question = questionnaire.schema.questions[i + 1] -- 3257
				local answer = __TS__ArrayFind( -- 3258
					answers, -- 3258
					function(____, item) return item.questionId == question.id end -- 3258
				) -- 3258
				if not answer or answer.status == "skipped" then -- 3258
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3260
					goto __continue575 -- 3265
				end -- 3265
				local selectedOptionLabels = {} -- 3267
				do -- 3267
					local j = 0 -- 3268
					while j < #(answer.selectedOptionIds or ({})) do -- 3268
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3269
						local option = __TS__ArrayFind( -- 3270
							question.options or ({}), -- 3270
							function(____, item) return item.id == optionId end -- 3270
						) -- 3270
						if option then -- 3270
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3271
						end -- 3271
						j = j + 1 -- 3268
					end -- 3268
				end -- 3268
				responses[#responses + 1] = { -- 3273
					questionId = question.id, -- 3274
					prompt = question.prompt, -- 3275
					status = "answered", -- 3276
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3277
					selectedOptionLabels = selectedOptionLabels, -- 3278
					otherText = answer.otherText, -- 3279
					text = answer.text -- 3280
				} -- 3280
			end -- 3280
			::__continue575:: -- 3280
			i = i + 1 -- 3256
		end -- 3256
	end -- 3256
	return { -- 3283
		success = true, -- 3284
		status = "answered", -- 3285
		source = "user", -- 3286
		questionnaireId = questionnaire.id, -- 3287
		title = questionnaire.schema.title, -- 3288
		answers = answers, -- 3289
		responses = responses, -- 3290
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3291
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3292
	} -- 3292
end -- 3237
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3318
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3324
	local persisted = storage:readSessionState() -- 3325
	local messages = __TS__ArraySlice(persisted.messages) -- 3326
	local toolResultIndex = -1 -- 3327
	local existingResult -- 3328
	do -- 3328
		local i = #messages - 1 -- 3329
		while i >= 0 do -- 3329
			do -- 3329
				local message = messages[i + 1] -- 3330
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3330
					goto __continue595 -- 3331
				end -- 3331
				local decoded = safeJsonDecode(message.content) -- 3332
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3332
					goto __continue595 -- 3333
				end -- 3333
				local row = decoded -- 3334
				if row.questionnaireId ~= questionnaire.id then -- 3334
					goto __continue595 -- 3335
				end -- 3335
				toolResultIndex = i -- 3336
				existingResult = row -- 3337
				break -- 3338
			end -- 3338
			::__continue595:: -- 3338
			i = i - 1 -- 3329
		end -- 3329
	end -- 3329
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3340
	local guidance = {} -- 3341
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3341
		guidance[#guidance + 1] = existingResult.guidance -- 3343
	end -- 3343
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3343
		guidance[#guidance + 1] = result.guidance -- 3346
	end -- 3346
	result.guidance = table.concat(guidance, "\n") -- 3348
	if toolResultIndex < 0 then -- 3348
		messages[#messages + 1] = { -- 3350
			role = "user", -- 3351
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3352
		} -- 3352
		toolResultIndex = #messages - 1 -- 3354
	else -- 3354
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3356
			{}, -- 3356
			messages[toolResultIndex + 1], -- 3357
			{content = encodeJson(result)} -- 3356
		) -- 3356
	end -- 3356
	local pairStartIndex = toolResultIndex -- 3362
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3363
	if toolCallId and toolCallId ~= "" then -- 3363
		do -- 3363
			local i = toolResultIndex - 1 -- 3365
			while i >= 0 do -- 3365
				do -- 3365
					local message = messages[i + 1] -- 3366
					if message.role ~= "assistant" or not message.tool_calls then -- 3366
						goto __continue605 -- 3367
					end -- 3367
					if __TS__ArraySome( -- 3367
						message.tool_calls, -- 3368
						function(____, call) return call.id == toolCallId end -- 3368
					) then -- 3368
						pairStartIndex = i -- 3369
						break -- 3370
					end -- 3370
				end -- 3370
				::__continue605:: -- 3370
				i = i - 1 -- 3365
			end -- 3365
		end -- 3365
	end -- 3365
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3374
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3377
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3381
	upsertStep( -- 3383
		session.id, -- 3383
		questionnaire.taskId, -- 3383
		questionnaire.step, -- 3383
		"ask_user", -- 3383
		{status = "DONE", result = result} -- 3383
	) -- 3383
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3387
	upsertStep( -- 3388
		session.id, -- 3388
		questionnaire.taskId, -- 3388
		answerStep, -- 3388
		"questionnaire_answer", -- 3388
		{status = "DONE", result = result} -- 3388
	) -- 3388
	return {success = true, answerStep = answerStep, result = result} -- 3392
end -- 3318
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3395
	local session = getSessionItem(sessionId) -- 3396
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3396
		return {success = false, message = "project task admission is closed"} -- 3397
	end -- 3397
	if not session then -- 3397
		return {success = false, message = "session not found"} -- 3398
	end -- 3398
	if session.kind ~= "main" then -- 3398
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3399
	end -- 3399
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3400
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3400
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3402
	end -- 3402
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3404
	if not llmConfigRes.success then -- 3404
		return {success = false, message = llmConfigRes.message} -- 3405
	end -- 3405
	if not removePendingQuestionnaire(session) then -- 3405
		return {success = false, message = "failed to consume questionnaire file"} -- 3406
	end -- 3406
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3407
	if not replaced.success then -- 3407
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3409
		return replaced -- 3410
	end -- 3410
	local t = now() -- 3412
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3413
	session.workMode = "plan" -- 3414
	local result = startPromptTask( -- 3415
		session, -- 3415
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3415
		nil, -- 3415
		{}, -- 3415
		{ -- 3415
			workMode = "plan", -- 3416
			persistUserMessage = false, -- 3417
			resumeConversation = true, -- 3418
			existingTaskId = questionnaire.taskId, -- 3419
			initialStep = replaced.answerStep, -- 3420
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3421
			llmConfig = llmConfigRes.config -- 3422
		} -- 3422
	) -- 3422
	if not result.success then -- 3422
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3425
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3426
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3427
		emitAgentSessionPatch( -- 3428
			session.id, -- 3428
			{ -- 3428
				session = getSessionItem(session.id), -- 3429
				pendingQuestionnaire = questionnaire -- 3430
			} -- 3430
		) -- 3430
		return result -- 3432
	end -- 3432
	emitAgentSessionPatch( -- 3434
		sessionId, -- 3434
		{ -- 3434
			session = getSessionItem(sessionId), -- 3435
			pendingQuestionnaire = false -- 3436
		} -- 3436
	) -- 3436
	return result -- 3438
end -- 3395
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3441
	local session = getSessionItem(sessionId) -- 3442
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3442
		return {success = false, message = "project task admission is closed"} -- 3443
	end -- 3443
	if not session then -- 3443
		return {success = false, message = "session not found"} -- 3444
	end -- 3444
	if session.kind ~= "main" then -- 3444
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3445
	end -- 3445
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3446
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3446
		return {success = false, message = "pending questionnaire not found"} -- 3447
	end -- 3447
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3448
	if not validated.success then -- 3448
		return validated -- 3449
	end -- 3449
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3450
	if not llmConfigRes.success then -- 3450
		return {success = false, message = llmConfigRes.message} -- 3451
	end -- 3451
	local t = now() -- 3452
	if not removePendingQuestionnaire(session) then -- 3452
		return {success = false, message = "failed to consume questionnaire file"} -- 3453
	end -- 3453
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3454
	if not replaced.success then -- 3454
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3456
		return replaced -- 3457
	end -- 3457
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3459
	session.workMode = "plan" -- 3460
	local result = startPromptTask( -- 3461
		session, -- 3461
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3461
		nil, -- 3461
		{}, -- 3461
		{ -- 3461
			workMode = "plan", -- 3462
			persistUserMessage = false, -- 3463
			resumeConversation = true, -- 3464
			existingTaskId = questionnaire.taskId, -- 3465
			initialStep = replaced.answerStep, -- 3466
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3467
			llmConfig = llmConfigRes.config -- 3468
		} -- 3468
	) -- 3468
	if not result.success then -- 3468
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3471
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3472
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3473
		emitAgentSessionPatch( -- 3474
			session.id, -- 3474
			{ -- 3474
				session = getSessionItem(session.id), -- 3475
				pendingQuestionnaire = questionnaire -- 3476
			} -- 3476
		) -- 3476
		return result -- 3478
	end -- 3478
	emitAgentSessionPatch( -- 3480
		sessionId, -- 3480
		{ -- 3480
			session = getSessionItem(sessionId), -- 3481
			pendingQuestionnaire = false -- 3482
		} -- 3482
	) -- 3482
	return result -- 3484
end -- 3441
function ____exports.stopSessionTask(sessionId) -- 3487
	InputInbox.holdInputs(sessionId) -- 3488
	followup.publish(sessionId) -- 3489
	local session = getSessionItem(sessionId) -- 3490
	if not session or session.currentTaskId == nil then -- 3490
		return {success = false, message = "session task not found"} -- 3492
	end -- 3492
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3492
		return {success = false, message = "session task is finalizing"} -- 3495
	end -- 3495
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime) -- 3497
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3498
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3499
	if localControl ~= nil then -- 3499
		localControl:stop() -- 3501
		return {success = true, stopping = true} -- 3502
	end -- 3502
	local stopToken = activeStopTokens[session.currentTaskId] -- 3504
	if stopToken == nil then -- 3504
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3504
			return {success = true, recovered = true} -- 3507
		end -- 3507
		return {success = false, message = "task is not running"} -- 3509
	end -- 3509
	if stopToken.stopped then -- 3509
		return {success = true, stopping = true} -- 3512
	end -- 3512
	stopToken.stopped = true -- 3514
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3515
	return {success = true, stopping = true} -- 3519
end -- 3487
function ____exports.getCurrentTaskId(sessionId) -- 3522
	local ____opt_179 = getSessionItem(sessionId) -- 3522
	return ____opt_179 and ____opt_179.currentTaskId -- 3523
end -- 3522
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3527
	local owner = getSessionItem(sessionId) -- 3528
	if not owner then -- 3528
		return {success = false, message = "session not found"} -- 3529
	end -- 3529
	local projectRoot = owner.projectRoot -- 3530
	local release = holdProjectTaskAdmission(projectRoot) -- 3531
	local closed = false -- 3532
	return { -- 3533
		success = true, -- 3534
		projectRoot = projectRoot, -- 3535
		close = function() -- 3536
			if not closed then -- 3536
				closed = true -- 3536
				release() -- 3536
			end -- 3536
		end, -- 3536
		poll = function() -- 3537
			if closed then -- 3537
				return {success = false, message = "quiescence handle closed"} -- 3538
			end -- 3538
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3539
			if not rows then -- 3539
				return {success = false, message = "failed to inspect project tasks"} -- 3540
			end -- 3540
			local pending = {} -- 3541
			for ____, row in ipairs(rows) do -- 3542
				do -- 3542
					local session = rowToSession(row) -- 3543
					local taskId = session.currentTaskId -- 3544
					if taskId == nil then -- 3544
						goto __continue643 -- 3545
					end -- 3545
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3546
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3546
						goto __continue643 -- 3547
					end -- 3547
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3549
					local ____session_id_182 = session.id -- 3550
					local ____taskId_183 = taskId -- 3550
					local ____finalizing_184 = finalizing -- 3550
					local ____result_success_185 = result.success -- 3550
					local ____result_success_181 -- 3550
					if result.success then -- 3550
						____result_success_181 = nil -- 3550
					else -- 3550
						____result_success_181 = result.message -- 3550
					end -- 3550
					pending[#pending + 1] = { -- 3550
						sessionId = ____session_id_182, -- 3550
						taskId = ____taskId_183, -- 3550
						finalizing = ____finalizing_184, -- 3550
						stopRequested = ____result_success_185, -- 3550
						message = ____result_success_181 -- 3550
					} -- 3550
				end -- 3550
				::__continue643:: -- 3550
			end -- 3550
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3554
		end -- 3537
	} -- 3537
end -- 3527
function ____exports.validateTaskAccess(sessionId, taskId) -- 3559
	local session = getSessionItem(sessionId) -- 3560
	if not session then -- 3560
		return {success = false, message = "session not found"} -- 3561
	end -- 3561
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3561
		getSessionOperableTaskIds(sessionId), -- 3562
		taskId -- 3562
	) < 0 then -- 3562
		return {success = false, message = "task is not operable for this session"} -- 3563
	end -- 3563
	return {success = true, session = session} -- 3565
end -- 3559
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3568
	if checkpointId <= 0 then -- 3568
		return {success = false, message = "invalid checkpointId"} -- 3570
	end -- 3570
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3572
	if not checkpoint then -- 3572
		return {success = false, message = "checkpoint not found"} -- 3574
	end -- 3574
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3576
	if not taskAccess.success then -- 3576
		return taskAccess -- 3577
	end -- 3577
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3578
end -- 3568
function ____exports.listRunningSessions() -- 3581
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3582
	local sessions = {} -- 3589
	do -- 3589
		local i = 0 -- 3590
		while i < #rows do -- 3590
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3591
			if session.currentTaskStatus == "RUNNING" then -- 3591
				sessions[#sessions + 1] = session -- 3593
			end -- 3593
			i = i + 1 -- 3590
		end -- 3590
	end -- 3590
	return {success = true, sessions = sessions} -- 3596
end -- 3581
return ____exports -- 3581