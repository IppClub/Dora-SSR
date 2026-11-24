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
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat -- 1
local ____exports = {} -- 1
local scheduleStreamFlush, getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getPendingSessionInputs, getSessionItem, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, decodeSessionMetrics, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startImmediatePrompt, startLocalPrompt, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, followup, activeLocalAgentControls, finalizingSubSessionTaskIds, activePromptRuns, streamUpdates, streamFlushScheduled, SESSION_SELECT_COLUMNS, now, handoffs -- 1
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
local isTaskInstruction = ____Memory.isTaskInstruction -- 29
local ____Utils = require("Agent.Utils") -- 30
local Log = ____Utils.Log -- 30
local clipTextToTokenBudget = ____Utils.clipTextToTokenBudget -- 30
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
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, submission) -- 425
	return followup.submit( -- 427
		sessionId, -- 427
		prompt, -- 427
		{disabledAgentTools = disabledAgentTools, workMode = workMode, llmConfigId = llmConfigId, maxSteps = maxSteps}, -- 427
		{llmConfig = llmConfig, llmConfigId = llmConfigId}, -- 428
		submission -- 428
	) -- 428
end -- 425
function scheduleStreamFlush() -- 506
	if streamFlushScheduled or not streamUpdates:hasPending() then -- 506
		return -- 507
	end -- 507
	streamFlushScheduled = true -- 508
	Director.systemScheduler:schedule(function() -- 509
		streamUpdates:flushDue(App.runningTime) -- 510
		if streamUpdates:hasPending() then -- 510
			return false -- 511
		end -- 511
		streamFlushScheduled = false -- 512
		return true -- 513
	end) -- 509
end -- 509
function getDefaultUseChineseResponse() -- 527
	local zh = string.match(App.locale, "^zh") -- 528
	return zh ~= nil -- 529
end -- 529
function encodeJson(value) -- 532
	local text = safeJsonEncode(value) -- 533
	return text or "" -- 534
end -- 534
function decodeJsonObject(text) -- 537
	if text == "" then -- 537
		return nil -- 538
	end -- 538
	local value = safeJsonDecode(text) -- 539
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 539
		return value -- 541
	end -- 541
	return nil -- 543
end -- 543
function decodeJsonFiles(text) -- 546
	if text == "" then -- 546
		return nil -- 547
	end -- 547
	local value = safeJsonDecode(text) -- 548
	if not value or not __TS__ArrayIsArray(value) then -- 548
		return nil -- 549
	end -- 549
	local files = {} -- 550
	do -- 550
		local i = 0 -- 551
		while i < #value do -- 551
			do -- 551
				local item = value[i + 1] -- 552
				if type(item) ~= "table" then -- 552
					goto __continue78 -- 553
				end -- 553
				files[#files + 1] = { -- 554
					path = sanitizeUTF8(toStr(item.path)), -- 555
					op = sanitizeUTF8(toStr(item.op)) -- 556
				} -- 556
			end -- 556
			::__continue78:: -- 556
			i = i + 1 -- 551
		end -- 551
	end -- 551
	return files -- 559
end -- 559
function decodeChangeSetSummary(value) -- 562
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 562
		return nil -- 563
	end -- 563
	local row = value -- 564
	if row.success ~= true then -- 564
		return nil -- 565
	end -- 565
	local taskId = type(row.taskId) == "number" and row.taskId or 0 -- 566
	if taskId <= 0 then -- 566
		return nil -- 567
	end -- 567
	local files = {} -- 568
	if __TS__ArrayIsArray(row.files) then -- 568
		do -- 568
			local i = 0 -- 570
			while i < #row.files do -- 570
				do -- 570
					local file = row.files[i + 1] -- 571
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then -- 571
						goto __continue86 -- 572
					end -- 572
					local fileRow = file -- 573
					local path = sanitizeUTF8(toStr(fileRow.path)) -- 574
					if path == "" then -- 574
						goto __continue86 -- 575
					end -- 575
					local checkpointIds = {} -- 576
					if __TS__ArrayIsArray(fileRow.checkpointIds) then -- 576
						do -- 576
							local j = 0 -- 578
							while j < #fileRow.checkpointIds do -- 578
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0 -- 579
								if checkpointId > 0 then -- 579
									checkpointIds[#checkpointIds + 1] = checkpointId -- 580
								end -- 580
								j = j + 1 -- 578
							end -- 578
						end -- 578
					end -- 578
					local op = toStr(fileRow.op) -- 583
					files[#files + 1] = { -- 584
						path = path, -- 585
						op = (op == "create" or op == "delete" or op == "write") and op or "write", -- 586
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds, -- 587
						checkpointIds = checkpointIds -- 588
					} -- 588
				end -- 588
				::__continue86:: -- 588
				i = i + 1 -- 570
			end -- 570
		end -- 570
	end -- 570
	return { -- 592
		success = true, -- 593
		taskId = taskId, -- 594
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0, -- 595
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files, -- 596
		files = files, -- 597
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil, -- 598
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil -- 599
	} -- 599
end -- 599
function decodeHandoffEvidence(value) -- 603
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 603
		return nil -- 604
	end -- 604
	local row = value -- 605
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap( -- 606
		__TS__ArrayFilter( -- 607
			row.modifiedFiles, -- 607
			function(____, item) return type(item) == "string" end -- 607
		), -- 607
		function(____, item) return sanitizeUTF8(item) end -- 607
	) or ({}) -- 607
	local lastBuild = nil -- 609
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then -- 609
		local build = row.lastBuild -- 611
		lastBuild = { -- 612
			result = build.result == "passed" and "passed" or "failed", -- 613
			path = sanitizeUTF8(toStr(build.path)), -- 614
			evidence = takeUtf8Head( -- 615
				sanitizeUTF8(toStr(build.evidence)), -- 615
				600 -- 615
			) -- 615
		} -- 615
	end -- 615
	local commands = {} -- 618
	if __TS__ArrayIsArray(row.commands) then -- 618
		do -- 618
			local i = 0 -- 620
			while i < #row.commands and #commands < 8 do -- 620
				do -- 620
					local raw = row.commands[i + 1] -- 621
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 621
						goto __continue100 -- 622
					end -- 622
					local item = raw -- 623
					commands[#commands + 1] = { -- 624
						mode = sanitizeUTF8(toStr(item.mode)), -- 625
						command = takeUtf8Head( -- 626
							sanitizeUTF8(toStr(item.command)), -- 626
							600 -- 626
						), -- 626
						result = item.result == "passed" and "passed" or "failed", -- 627
						evidence = takeUtf8Head( -- 628
							sanitizeUTF8(toStr(item.evidence)), -- 628
							600 -- 628
						) -- 628
					} -- 628
				end -- 628
				::__continue100:: -- 628
				i = i + 1 -- 620
			end -- 620
		end -- 620
	end -- 620
	local authoritativeSources = {} -- 632
	if __TS__ArrayIsArray(row.authoritativeSources) then -- 632
		do -- 632
			local i = 0 -- 634
			while i < #row.authoritativeSources and #authoritativeSources < 8 do -- 634
				do -- 634
					local raw = row.authoritativeSources[i + 1] -- 635
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then -- 635
						goto __continue104 -- 636
					end -- 636
					local item = raw -- 637
					authoritativeSources[#authoritativeSources + 1] = { -- 638
						tool = "search_dora_doc", -- 639
						query = takeUtf8Head( -- 640
							sanitizeUTF8(toStr(item.query)), -- 640
							300 -- 640
						), -- 640
						source = sanitizeUTF8(toStr(item.source)), -- 641
						result = item.result == "passed" and "passed" or "failed" -- 642
					} -- 642
				end -- 642
				::__continue104:: -- 642
				i = i + 1 -- 634
			end -- 634
		end -- 634
	end -- 634
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources} -- 646
end -- 646
function takeUtf8Head(text, maxChars) -- 649
	if maxChars <= 0 or text == "" then -- 649
		return "" -- 650
	end -- 650
	local nextPos = utf8.offset(text, maxChars + 1) -- 651
	if nextPos == nil then -- 651
		return text -- 652
	end -- 652
	return string.sub(text, 1, nextPos - 1) -- 653
end -- 653
function normalizeMemoryEntryEvidence(value) -- 656
	local evidence = {} -- 657
	if not __TS__ArrayIsArray(value) then -- 657
		return evidence -- 658
	end -- 658
	do -- 658
		local i = 0 -- 659
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 659
			do -- 659
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1]))) -- 660
				if item == "" then -- 660
					goto __continue112 -- 661
				end -- 661
				if __TS__ArrayIndexOf(evidence, item) < 0 then -- 661
					evidence[#evidence + 1] = item -- 663
				end -- 663
			end -- 663
			::__continue112:: -- 663
			i = i + 1 -- 659
		end -- 659
	end -- 659
	return evidence -- 666
end -- 666
function decodeSubAgentMemoryEntry(value) -- 669
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then -- 669
		return nil -- 670
	end -- 670
	local row = value -- 671
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0 -- 672
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0 -- 673
	local content = takeUtf8Head( -- 674
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))), -- 674
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 674
	) -- 674
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then -- 674
		return nil -- 675
	end -- 675
	return { -- 676
		sourceSessionId = sourceSessionId, -- 677
		sourceTaskId = sourceTaskId, -- 678
		content = content, -- 679
		evidence = normalizeMemoryEntryEvidence(row.evidence), -- 680
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt))) -- 681
	} -- 681
end -- 681
function getTaskChangeSetSummary(taskId) -- 685
	local summary = Tools.summarizeTaskChangeSet(taskId) -- 686
	return summary.success and summary or nil -- 687
end -- 687
function summarizeHandoffResult(result) -- 690
	local candidates = {result.output, result.message, result.state, result.phase} -- 691
	do -- 691
		local i = 0 -- 692
		while i < #candidates do -- 692
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1]))) -- 693
			if text ~= "" then -- 693
				return takeUtf8Head(text, 600) -- 694
			end -- 694
			i = i + 1 -- 692
		end -- 692
	end -- 692
	local messages = result.messages -- 696
	if __TS__ArrayIsArray(messages) and #messages > 0 then -- 696
		local parts = {} -- 698
		do -- 698
			local i = 0 -- 699
			while i < #messages and #parts < 4 do -- 699
				do -- 699
					local row = messages[i + 1] -- 700
					if not row or type(row) ~= "table" then -- 700
						goto __continue125 -- 701
					end -- 701
					local item = row -- 702
					local ____sanitizeUTF8_33 = sanitizeUTF8 -- 703
					local ____toStr_32 = toStr -- 703
					local ____item_message_30 = item.message -- 703
					if ____item_message_30 == nil then -- 703
						____item_message_30 = item.error -- 703
					end -- 703
					local ____item_message_30_31 = ____item_message_30 -- 703
					if ____item_message_30_31 == nil then -- 703
						____item_message_30_31 = item.file -- 703
					end -- 703
					local text = __TS__StringTrim(____sanitizeUTF8_33(____toStr_32(____item_message_30_31))) -- 703
					if text ~= "" then -- 703
						parts[#parts + 1] = text -- 704
					end -- 704
				end -- 704
				::__continue125:: -- 704
				i = i + 1 -- 699
			end -- 699
		end -- 699
		if #parts > 0 then -- 699
			return takeUtf8Head( -- 706
				table.concat(parts, "; "), -- 706
				600 -- 706
			) -- 706
		end -- 706
	end -- 706
	return result.success == true and "tool result success=true" or "tool result success=false" -- 708
end -- 708
function getTaskHandoffEvidence(taskId, changeSet) -- 711
	local ____opt_34 = changeSet -- 711
	local evidence = { -- 712
		modifiedFiles = ____opt_34 and __TS__ArrayMap( -- 713
			changeSet and changeSet.files, -- 713
			function(____, item) return item.path end -- 713
		) or ({}), -- 713
		commands = {}, -- 714
		authoritativeSources = {} -- 715
	} -- 715
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({}) -- 717
	do -- 717
		local i = 0 -- 722
		while i < #rows do -- 722
			local tool = toStr(rows[i + 1][1]) -- 723
			local status = toStr(rows[i + 1][2]) -- 724
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({}) -- 725
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({}) -- 726
			local passed = status == "DONE" and result.success == true -- 727
			if tool == "build" then -- 727
				evidence.lastBuild = { -- 729
					result = passed and "passed" or "failed", -- 730
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))), -- 731
					evidence = summarizeHandoffResult(result) -- 732
				} -- 732
			elseif tool == "execute_command" and #evidence.commands < 8 then -- 732
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode))) -- 735
				local command = mode == "git" and toStr(params.command) or toStr(params.code) -- 736
				local ____evidence_commands_38 = evidence.commands -- 736
				____evidence_commands_38[#____evidence_commands_38 + 1] = { -- 737
					mode = mode, -- 738
					command = takeUtf8Head( -- 739
						__TS__StringTrim(sanitizeUTF8(command)), -- 739
						600 -- 739
					), -- 739
					result = passed and "passed" or "failed", -- 740
					evidence = summarizeHandoffResult(result) -- 741
				} -- 741
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then -- 741
				local ____evidence_authoritativeSources_39 = evidence.authoritativeSources -- 741
				____evidence_authoritativeSources_39[#____evidence_authoritativeSources_39 + 1] = { -- 744
					tool = "search_dora_doc", -- 745
					query = takeUtf8Head( -- 746
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))), -- 746
						300 -- 746
					), -- 746
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))), -- 747
					result = passed and "passed" or "failed" -- 748
				} -- 748
			end -- 748
			i = i + 1 -- 722
		end -- 722
	end -- 722
	return evidence -- 752
end -- 752
function reconcileCompletionWithHandoffEvidence(completion, evidence) -- 755
	local lastBuild = evidence.lastBuild -- 759
	if not lastBuild or lastBuild.result ~= "failed" then -- 759
		return completion -- 760
	end -- 760
	local validation = __TS__ArraySlice(completion.validation) -- 761
	local foundBuild = false -- 762
	do -- 762
		local i = 0 -- 763
		while i < #validation do -- 763
			do -- 763
				if validation[i + 1].kind ~= "build" then -- 763
					goto __continue139 -- 764
				end -- 764
				foundBuild = true -- 765
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 766
			end -- 766
			::__continue139:: -- 766
			i = i + 1 -- 763
		end -- 763
	end -- 763
	if not foundBuild then -- 763
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}} -- 773
	end -- 773
	local knownIssues = __TS__ArraySlice(completion.knownIssues) -- 775
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence -- 776
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then -- 776
		knownIssues[#knownIssues + 1] = issue -- 777
	end -- 777
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues}) -- 778
end -- 778
function isValidProjectRoot(path) -- 786
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path) -- 787
end -- 787
function rowToSession(row) -- 790
	return { -- 791
		id = row[1], -- 792
		projectRoot = toStr(row[2]), -- 793
		title = toStr(row[3]), -- 794
		kind = toStr(row[4]) == "sub" and "sub" or "main", -- 795
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1], -- 796
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil, -- 797
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main", -- 798
		status = toStr(row[8]), -- 799
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil, -- 800
		currentTaskStatus = toStr(row[10]), -- 801
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true, -- 802
		createdAt = row[11], -- 803
		updatedAt = row[12], -- 804
		metrics = decodeSessionMetrics(toStr(row[13])), -- 805
		workMode = toStr(row[14]) == "plan" and "plan" or "code" -- 806
	} -- 806
end -- 806
function rowToMessage(row) -- 810
	local message = { -- 811
		id = row[1], -- 812
		sessionId = row[2], -- 813
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil, -- 814
		role = toStr(row[4]), -- 815
		content = toStr(row[5]), -- 816
		createdAt = row[7], -- 817
		updatedAt = row[8] -- 818
	} -- 818
	local displayContent = toStr(row[6]) -- 820
	if displayContent ~= "" then -- 820
		message.displayContent = displayContent -- 821
	end -- 821
	local receipt = queryOne("SELECT delivery,delivered_step FROM agent.AgentSessionInput WHERE message_id=? AND status='delivered'", {message.id}) -- 822
	if (receipt and receipt[1]) == "steer" then -- 822
		message.inputKind = "steer" -- 823
		message.afterStep = type(receipt[2]) == "number" and receipt[2] or 0 -- 823
	end -- 823
	return message -- 824
end -- 824
function rowToStep(row) -- 827
	return { -- 828
		id = row[1], -- 829
		sessionId = row[2], -- 830
		taskId = row[3], -- 831
		step = row[4], -- 832
		tool = toStr(row[5]), -- 833
		status = toStr(row[6]), -- 834
		reason = toStr(row[7]), -- 835
		reasoningContent = toStr(row[8]), -- 836
		params = decodeJsonObject(toStr(row[9])), -- 837
		result = decodeJsonObject(toStr(row[10])), -- 838
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil, -- 839
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil, -- 840
		files = decodeJsonFiles(toStr(row[13])), -- 841
		createdAt = row[14], -- 842
		updatedAt = row[15] -- 843
	} -- 843
end -- 843
function getQuestionnairePath(projectRoot) -- 847
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE) -- 848
end -- 848
function decodeQuestionnaireFile(text) -- 851
	local value = decodeJsonObject(text) -- 852
	if not value then -- 852
		return nil -- 853
	end -- 853
	local schema = value.schema -- 854
	local id = type(value.id) == "number" and value.id or 0 -- 855
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0 -- 856
	local taskId = type(value.taskId) == "number" and value.taskId or 0 -- 857
	local step = type(value.step) == "number" and value.step or 0 -- 858
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0 -- 859
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then -- 859
		return nil -- 861
	end -- 861
	return { -- 863
		id = id, -- 863
		sessionId = sessionId, -- 863
		taskId = taskId, -- 863
		step = step, -- 863
		status = "PENDING", -- 863
		schema = schema, -- 863
		createdAt = createdAt -- 863
	} -- 863
end -- 863
function getPendingQuestionnaire(sessionId) -- 866
	local session = getSessionItem(sessionId) -- 867
	if not session or session.kind ~= "main" then -- 867
		return nil -- 868
	end -- 868
	local path = getQuestionnairePath(session.projectRoot) -- 869
	if not Content:exist(path) then -- 869
		return nil -- 870
	end -- 870
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 871
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil -- 872
end -- 872
function restorePendingQuestionnaireState(session) -- 875
	local questionnaire = getPendingQuestionnaire(session.id) -- 876
	if not questionnaire then -- 876
		return {session = session} -- 877
	end -- 877
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then -- 877
		local t = now() -- 884
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id}) -- 885
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 891
		local restored = getSessionItem(session.id) -- 892
		if restored then -- 892
			session = restored -- 893
		end -- 893
	end -- 893
	return {session = session, questionnaire = questionnaire} -- 895
end -- 895
function savePendingQuestionnaire(projectRoot, questionnaire) -- 898
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR) -- 899
	if not Content:exist(dir) and not Content:mkdir(dir) then -- 899
		return false -- 900
	end -- 900
	local path = getQuestionnairePath(projectRoot) -- 901
	local tempPath = path .. ".tmp" -- 902
	local backupPath = path .. ".bak" -- 903
	Content:remove(tempPath) -- 904
	Content:remove(backupPath) -- 905
	if not Content:save( -- 905
		tempPath, -- 906
		encodeJson(questionnaire) -- 906
	) then -- 906
		return false -- 906
	end -- 906
	local hadOriginal = Content:exist(path) -- 907
	if hadOriginal and not Content:move(path, backupPath) then -- 907
		Content:remove(tempPath) -- 909
		return false -- 910
	end -- 910
	if Content:move(tempPath, path) then -- 910
		Content:remove(backupPath) -- 913
		Tools.sendWebIDEFileUpdate( -- 914
			path, -- 914
			true, -- 914
			encodeJson(questionnaire) -- 914
		) -- 914
		return true -- 915
	end -- 915
	Content:remove(tempPath) -- 917
	if hadOriginal and Content:exist(backupPath) then -- 917
		Content:move(backupPath, path) -- 919
	end -- 919
	return false -- 921
end -- 921
function removePendingQuestionnaire(session) -- 924
	local path = getQuestionnairePath(session.projectRoot) -- 925
	if not Content:exist(path) then -- 925
		return true -- 926
	end -- 926
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path))) -- 927
	if questionnaire and questionnaire.sessionId ~= session.id then -- 927
		return false -- 928
	end -- 928
	if not Content:remove(path) then -- 928
		return false -- 929
	end -- 929
	Tools.sendWebIDEFileUpdate(path, false, "") -- 930
	return true -- 931
end -- 931
function publishQuestionnaire(request) -- 934
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 934
		local session = getSessionItem(request.sessionId) -- 940
		if not session or session.kind ~= "main" then -- 940
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"}) -- 940
		end -- 940
		local pendingPath = getQuestionnairePath(session.projectRoot) -- 942
		if Content:exist(pendingPath) then -- 942
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"}) -- 942
		end -- 942
		local questionnaire = { -- 944
			id = request.taskId, -- 945
			sessionId = request.sessionId, -- 946
			taskId = request.taskId, -- 947
			step = request.step, -- 948
			status = "PENDING", -- 949
			schema = request.schema, -- 950
			createdAt = now() -- 951
		} -- 951
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then -- 951
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"}) -- 951
		end -- 951
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id}) -- 951
	end) -- 951
end -- 951
function getMessageItem(messageId) -- 959
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId}) -- 960
	return row and rowToMessage(row) or nil -- 966
end -- 966
function getStepItem(sessionId, taskId, step) -- 969
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 970
	return row and rowToStep(row) or nil -- 976
end -- 976
function deleteMessageSteps(sessionId, taskId) -- 979
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({}) -- 980
	local ids = {} -- 985
	do -- 985
		local i = 0 -- 986
		while i < #rows do -- 986
			local row = rows[i + 1] -- 987
			if type(row[1]) == "number" then -- 987
				ids[#ids + 1] = row[1] -- 989
			end -- 989
			i = i + 1 -- 986
		end -- 986
	end -- 986
	if #ids > 0 then -- 986
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) -- 993
	end -- 993
	return ids -- 999
end -- 999
function normalizeDisabledAgentTools(value) -- 1002
	if not __TS__ArrayIsArray(value) then -- 1002
		return {} -- 1003
	end -- 1003
	local tools = {} -- 1004
	do -- 1004
		local i = 0 -- 1005
		while i < #value do -- 1005
			do -- 1005
				local name = value[i + 1] -- 1006
				if name == "edit_file" and __TS__ArrayIndexOf(tools, "write_file") < 0 then -- 1006
					tools[#tools + 1] = "write_file" -- 1007
				end -- 1007
				if name == "delete_file" then -- 1007
					name = "edit_file" -- 1008
				end -- 1008
				if name == "glob_files" then -- 1008
					name = "grep_files" -- 1009
				end -- 1009
				if name == "spawn_sub_agent" or name == "list_sub_agents" then -- 1009
					name = "spawn_agent" -- 1010
				end -- 1010
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then -- 1010
					goto __continue184 -- 1011
				end -- 1011
				if __TS__ArrayIndexOf(tools, name) < 0 then -- 1011
					tools[#tools + 1] = name -- 1012
				end -- 1012
			end -- 1012
			::__continue184:: -- 1012
			i = i + 1 -- 1005
		end -- 1005
	end -- 1005
	return tools -- 1014
end -- 1014
function normalizeWorkMode(value, fallback) -- 1017
	if fallback == nil then -- 1017
		fallback = "code" -- 1017
	end -- 1017
	return value == "plan" and "plan" or (value == "code" and "code" or fallback) -- 1018
end -- 1018
function getSessionRow(sessionId) -- 1021
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId}) -- 1022
end -- 1022
function getPendingSessionInputs(sessionId) -- 1030
	return __TS__ArrayMap( -- 1033
		__TS__ArrayFilter( -- 1033
			InputInbox.listInputs(sessionId), -- 1033
			function(____, item) return item.status ~= "delivering" end -- 1033
		), -- 1033
		function(____, item) return { -- 1034
			id = item.id, -- 1034
			content = item.content, -- 1034
			delivery = item.delivery, -- 1034
			held = item.held, -- 1034
			status = item.status -- 1034
		} end -- 1034
	) -- 1034
end -- 1034
function getSessionItem(sessionId) -- 1037
	local row = getSessionRow(sessionId) -- 1038
	if not row then -- 1038
		return nil -- 1039
	end -- 1039
	local session = rowToSession(row) -- 1040
	session.pendingInputs = getPendingSessionInputs(session.id) -- 1041
	return session -- 1042
end -- 1042
function getLatestMainSessionByProjectRoot(projectRoot) -- 1051
	if not isValidProjectRoot(projectRoot) then -- 1051
		return nil -- 1052
	end -- 1052
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 1053
	if not row then -- 1053
		return nil -- 1061
	end -- 1061
	local session = rowToSession(row) -- 1062
	session.pendingInputs = getPendingSessionInputs(session.id) -- 1063
	return session -- 1064
end -- 1064
function countRunningSubSessions(rootSessionId) -- 1067
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({}) -- 1068
	local count = 0 -- 1075
	do -- 1075
		local i = 0 -- 1076
		while i < #rows do -- 1076
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 1077
			if session.currentTaskStatus == "RUNNING" then -- 1077
				count = count + 1 -- 1079
			end -- 1079
			i = i + 1 -- 1076
		end -- 1076
	end -- 1076
	return count -- 1082
end -- 1082
function deleteSessionRecords(sessionId, preserveArtifacts) -- 1085
	if preserveArtifacts == nil then -- 1085
		preserveArtifacts = false -- 1085
	end -- 1085
	for ____, input in ipairs(InputInbox.listInputs(sessionId, true)) do -- 1086
		__TS__Delete(followup.configs, input.id) -- 1086
	end -- 1086
	DB:exec("DELETE FROM agent.AgentSessionInput WHERE session_id=?", {sessionId}) -- 1087
	__TS__Delete(followup.bindings, sessionId) -- 1088
	__TS__Delete(followup.recovered, sessionId) -- 1089
	streamUpdates:clear(sessionId) -- 1090
	local session = getSessionItem(sessionId) -- 1091
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({}) -- 1092
	local taskIds = {} -- 1100
	do -- 1100
		local i = 0 -- 1101
		while i < #taskRows do -- 1101
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0 -- 1102
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then -- 1102
				taskIds[#taskIds + 1] = taskId -- 1104
				local stopToken = activeStopTokens[taskId] -- 1105
				if stopToken ~= nil then -- 1105
					stopToken.stopped = true -- 1107
					stopToken.reason = "session deleted" -- 1108
				end -- 1108
			end -- 1108
			i = i + 1 -- 1101
		end -- 1101
	end -- 1101
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({}) -- 1112
	do -- 1112
		local i = 0 -- 1113
		while i < #children do -- 1113
			local row = children[i + 1] -- 1114
			if type(row[1]) == "number" and row[1] > 0 then -- 1114
				deleteSessionRecords(row[1], preserveArtifacts) -- 1116
			end -- 1116
			i = i + 1 -- 1113
		end -- 1113
	end -- 1113
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) -- 1119
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId}) -- 1120
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId}) -- 1121
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId}) -- 1122
	if session and session.kind == "main" then -- 1122
		removePendingQuestionnaire(session) -- 1124
	end -- 1124
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then -- 1124
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then -- 1124
			Tools.sendWebIDERefreshTree() -- 1128
		end -- 1128
	end -- 1128
	do -- 1128
		local i = 0 -- 1131
		while i < #taskIds do -- 1131
			cleanupTaskHeavyData(taskIds[i + 1]) -- 1132
			i = i + 1 -- 1131
		end -- 1131
	end -- 1131
end -- 1131
function getSessionRootId(session) -- 1136
	return session.rootSessionId > 0 and session.rootSessionId or session.id -- 1137
end -- 1137
function getRootSessionItem(sessionId) -- 1140
	local session = getSessionItem(sessionId) -- 1141
	if not session then -- 1141
		return nil -- 1142
	end -- 1142
	return getSessionItem(getSessionRootId(session)) or session -- 1143
end -- 1143
function listRelatedSessions(sessionId) -- 1146
	local root = getRootSessionItem(sessionId) -- 1147
	if not root then -- 1147
		return {} -- 1148
	end -- 1148
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({}) -- 1149
	return __TS__ArrayMap( -- 1158
		rows, -- 1158
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end -- 1158
	) -- 1158
end -- 1158
function getSessionSpawnInfo(session) -- 1161
	local info = readSpawnInfo(session.projectRoot, session.memoryScope) -- 1162
	if not info then -- 1162
		return nil -- 1163
	end -- 1163
	local ____temp_47 = type(info.sessionId) == "number" and info.sessionId or nil -- 1165
	local ____temp_48 = type(info.rootSessionId) == "number" and info.rootSessionId or nil -- 1166
	local ____temp_49 = type(info.parentSessionId) == "number" and info.parentSessionId or nil -- 1167
	local ____temp_50 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil -- 1168
	local ____temp_51 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or "" -- 1169
	local ____temp_52 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or "" -- 1170
	local ____temp_53 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil -- 1171
	local ____temp_54 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1172
		__TS__ArrayFilter( -- 1173
			info.filesHint, -- 1173
			function(____, item) return type(item) == "string" end -- 1173
		), -- 1173
		function(____, item) return sanitizeUTF8(item) end -- 1173
	) or nil -- 1173
	local ____temp_55 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil))) -- 1175
	local ____temp_45 -- 1178
	if info.success == true then -- 1178
		____temp_45 = true -- 1178
	else -- 1178
		local ____temp_44 -- 1178
		if info.success == false then -- 1178
			____temp_44 = false -- 1178
		else -- 1178
			____temp_44 = nil -- 1178
		end -- 1178
		____temp_45 = ____temp_44 -- 1178
	end -- 1178
	local ____temp_46 -- 1179
	if info.cleared == true then -- 1179
		____temp_46 = true -- 1179
	else -- 1179
		____temp_46 = nil -- 1179
	end -- 1179
	return { -- 1164
		sessionId = ____temp_47, -- 1165
		rootSessionId = ____temp_48, -- 1166
		parentSessionId = ____temp_49, -- 1167
		title = ____temp_50, -- 1168
		prompt = ____temp_51, -- 1169
		goal = ____temp_52, -- 1170
		expectedOutput = ____temp_53, -- 1171
		filesHint = ____temp_54, -- 1172
		status = ____temp_55, -- 1175
		success = ____temp_45, -- 1178
		cleared = ____temp_46, -- 1179
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil, -- 1180
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil, -- 1181
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil, -- 1182
		changeSet = decodeChangeSetSummary(info.changeSet), -- 1183
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1184
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1185
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil, -- 1186
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil, -- 1187
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil, -- 1190
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil, -- 1191
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil, -- 1192
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil -- 1193
	} -- 1193
end -- 1193
function ensureDirRecursive(dir) -- 1210
	if dir == "" then -- 1210
		return false -- 1211
	end -- 1211
	if Content:exist(dir) then -- 1211
		return Content:isdir(dir) -- 1212
	end -- 1212
	local parent = Path:getPath(dir) -- 1213
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then -- 1213
		if not ensureDirRecursive(parent) then -- 1213
			return false -- 1216
		end -- 1216
	end -- 1216
	return Content:mkdir(dir) -- 1219
end -- 1219
function writeSpawnInfo(projectRoot, memoryScope, value) -- 1222
	local dir = Path(projectRoot, ".agent", memoryScope) -- 1223
	if not Content:exist(dir) then -- 1223
		ensureDirRecursive(dir) -- 1225
	end -- 1225
	local path = Path(dir, SPAWN_INFO_FILE) -- 1227
	local text = safeJsonEncode(value) -- 1228
	if not text then -- 1228
		return false -- 1229
	end -- 1229
	local content = text .. "\n" -- 1230
	if not Content:save(path, content) then -- 1230
		return false -- 1232
	end -- 1232
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1234
	return true -- 1235
end -- 1235
function readSpawnInfo(projectRoot, memoryScope) -- 1238
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE) -- 1239
	if not Content:exist(path) then -- 1239
		return nil -- 1240
	end -- 1240
	local text = Content:load(path) -- 1241
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1241
		return nil -- 1242
	end -- 1242
	local value = safeJsonDecode(text) -- 1243
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then -- 1243
		return value -- 1245
	end -- 1245
	return nil -- 1247
end -- 1247
function getArtifactRelativeDir(memoryScope) -- 1250
	return Path(".agent", memoryScope) -- 1251
end -- 1251
function getArtifactDir(projectRoot, memoryScope) -- 1254
	return Path( -- 1255
		projectRoot, -- 1255
		getArtifactRelativeDir(memoryScope) -- 1255
	) -- 1255
end -- 1255
function readSubAgentResultSummary(projectRoot, resultFilePath) -- 1258
	if resultFilePath == "" then -- 1258
		return "" -- 1259
	end -- 1259
	local path = Path(projectRoot, resultFilePath) -- 1260
	if not Content:exist(path) then -- 1260
		return "" -- 1261
	end -- 1261
	local text = sanitizeUTF8(Content:load(path)) -- 1262
	if __TS__StringTrim(text) == "" then -- 1262
		return "" -- 1263
	end -- 1263
	local marker = "\n## Summary\n" -- 1264
	local start = string.find(text, marker, 1, true) -- 1265
	if start ~= nil then -- 1265
		return __TS__StringTrim(string.sub(text, start + #marker)) -- 1267
	end -- 1267
	return __TS__StringTrim(text) -- 1269
end -- 1269
function buildStructuredSubAgentMemoryEntry(record) -- 1272
	local hasPassedValidation = false -- 1273
	do -- 1273
		local i = 0 -- 1274
		while i < #record.completion.validation do -- 1274
			local result = record.completion.validation[i + 1].result -- 1275
			if result == "failed" then -- 1275
				return nil -- 1280
			end -- 1280
			if result == "passed" then -- 1280
				hasPassedValidation = true -- 1282
			end -- 1282
			i = i + 1 -- 1274
		end -- 1274
	end -- 1274
	if not hasPassedValidation then -- 1274
		return nil -- 1285
	end -- 1285
	local candidates = record.completion.learningCandidates -- 1286
	local claims = {} -- 1287
	local evidence = {} -- 1288
	do -- 1288
		local i = 0 -- 1289
		while i < #candidates do -- 1289
			do -- 1289
				local candidate = candidates[i + 1] -- 1290
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then -- 1290
					goto __continue264 -- 1291
				end -- 1291
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim -- 1292
				do -- 1292
					local j = 0 -- 1293
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do -- 1293
						local item = candidate.evidence[j + 1] -- 1294
						if __TS__ArrayIndexOf(evidence, item) < 0 then -- 1294
							evidence[#evidence + 1] = item -- 1295
						end -- 1295
						j = j + 1 -- 1293
					end -- 1293
				end -- 1293
			end -- 1293
			::__continue264:: -- 1293
			i = i + 1 -- 1289
		end -- 1289
	end -- 1289
	local content = takeUtf8Head( -- 1298
		table.concat(claims, "\n"), -- 1298
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS -- 1298
	) -- 1298
	if content == "" then -- 1298
		return nil -- 1299
	end -- 1299
	return { -- 1300
		sourceSessionId = record.sessionId, -- 1301
		sourceTaskId = record.sourceTaskId, -- 1302
		content = content, -- 1303
		evidence = evidence, -- 1304
		createdAt = record.finishedAt -- 1305
	} -- 1305
end -- 1305
function containsNormalizedText(text, query) -- 1309
	local normalizedText = string.lower(sanitizeUTF8(text or "")) -- 1310
	local normalizedQuery = string.lower(sanitizeUTF8(query or "")) -- 1311
	if normalizedQuery == "" then -- 1311
		return true -- 1312
	end -- 1312
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil -- 1313
end -- 1313
function getSubAgentDisplayKey(item) -- 1316
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or ""))) -- 1322
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or ""))) -- 1323
	local label = goal ~= "" and goal or title -- 1324
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label -- 1325
end -- 1325
function writeSubAgentResultFile(session, record, resultText) -- 1328
	local dir = getArtifactDir(session.projectRoot, session.memoryScope) -- 1329
	if not Content:exist(dir) then -- 1329
		ensureDirRecursive(dir) -- 1331
	end -- 1331
	local ____array_64 = __TS__SparseArrayNew( -- 1331
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)), -- 1334
		"- Status: " .. record.status, -- 1335
		"- Success: " .. (record.success and "true" or "false"), -- 1336
		"- Outcome: " .. record.completion.outcome, -- 1337
		"- Session ID: " .. tostring(record.sessionId), -- 1338
		"- Source Task ID: " .. tostring(record.sourceTaskId), -- 1339
		"- Goal: " .. record.goal, -- 1340
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({})) -- 1341
	) -- 1341
	__TS__SparseArrayPush( -- 1341
		____array_64, -- 1341
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({})) -- 1342
	) -- 1342
	__TS__SparseArrayPush( -- 1342
		____array_64, -- 1342
		"- Finished At: " .. record.finishedAt, -- 1343
		"", -- 1344
		"## Validation", -- 1345
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap( -- 1346
			record.completion.validation, -- 1347
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end -- 1347
		) or ({"- Not reported"})) -- 1347
	) -- 1347
	__TS__SparseArrayPush(____array_64, "", "## Recorded Evidence") -- 1347
	local ____opt_56 = record.handoffEvidence -- 1347
	__TS__SparseArrayPush( -- 1347
		____array_64, -- 1347
		table.unpack(____opt_56 and #____opt_56.modifiedFiles and __TS__ArrayMap( -- 1351
			record.handoffEvidence.modifiedFiles, -- 1352
			function(____, item) return "- modified: " .. item end -- 1352
		) or ({"- modified: none recorded"})) -- 1352
	) -- 1352
	local ____opt_58 = record.handoffEvidence -- 1352
	__TS__SparseArrayPush( -- 1352
		____array_64, -- 1352
		table.unpack(____opt_58 and ____opt_58.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"})) -- 1354
	) -- 1354
	local ____opt_60 = record.handoffEvidence -- 1354
	__TS__SparseArrayPush( -- 1354
		____array_64, -- 1354
		table.unpack(__TS__ArrayMap( -- 1357
			____opt_60 and ____opt_60.commands or ({}), -- 1357
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end -- 1357
		)) -- 1357
	) -- 1357
	local ____opt_62 = record.handoffEvidence -- 1357
	__TS__SparseArrayPush( -- 1357
		____array_64, -- 1357
		table.unpack(__TS__ArrayMap( -- 1358
			____opt_62 and ____opt_62.authoritativeSources or ({}), -- 1358
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end -- 1358
		)) -- 1358
	) -- 1358
	__TS__SparseArrayPush( -- 1358
		____array_64, -- 1358
		"", -- 1359
		"## Known Issues", -- 1360
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap( -- 1361
			record.completion.knownIssues, -- 1361
			function(____, item) return "- " .. item end -- 1361
		) or ({"- None reported"})) -- 1361
	) -- 1361
	__TS__SparseArrayPush( -- 1361
		____array_64, -- 1361
		"", -- 1362
		"## Assumptions", -- 1363
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap( -- 1364
			record.completion.assumptions, -- 1364
			function(____, item) return "- " .. item end -- 1364
		) or ({"- None reported"})) -- 1364
	) -- 1364
	__TS__SparseArrayPush(____array_64, "", "## Summary", resultText ~= "" and resultText or "(empty)") -- 1364
	local lines = {__TS__SparseArraySpread(____array_64)} -- 1333
	local path = Path(session.projectRoot, record.resultFilePath) -- 1369
	local content = table.concat(lines, "\n") .. "\n" -- 1370
	if not Content:save(path, content) then -- 1370
		return false -- 1372
	end -- 1372
	Tools.sendWebIDEFileUpdate(path, true, content) -- 1374
	return true -- 1375
end -- 1375
function listSubAgentResultRecords(projectRoot, rootSessionId) -- 1378
	local dir = Path(projectRoot, ".agent", "subagents") -- 1379
	if not Content:exist(dir) or not Content:isdir(dir) then -- 1379
		return {} -- 1380
	end -- 1380
	local items = {} -- 1381
	for ____, rawPath in ipairs(Content:getDirs(dir)) do -- 1382
		do -- 1382
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1383
			if not Content:exist(path) or not Content:isdir(path) then -- 1383
				goto __continue284 -- 1384
			end -- 1384
			local info = readSpawnInfo( -- 1385
				projectRoot, -- 1385
				Path( -- 1385
					"subagents", -- 1385
					Path:getFilename(path) -- 1385
				) -- 1385
			) -- 1385
			if not info then -- 1385
				goto __continue284 -- 1386
			end -- 1386
			local sessionId = tonumber(info.sessionId) -- 1387
			local infoRootSessionId = tonumber(info.rootSessionId) -- 1388
			local sourceTaskId = tonumber(info.sourceTaskId) -- 1389
			local status = sanitizeUTF8(toStr(info.status)) -- 1390
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then -- 1390
				goto __continue284 -- 1391
			end -- 1391
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then -- 1391
				goto __continue284 -- 1392
			end -- 1392
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir)) -- 1393
			items[#items + 1] = { -- 1394
				sessionId = sessionId, -- 1395
				rootSessionId = infoRootSessionId, -- 1396
				parentSessionId = tonumber(info.parentSessionId) or nil, -- 1397
				title = sanitizeUTF8(toStr(info.title)), -- 1398
				prompt = sanitizeUTF8(toStr(info.prompt)), -- 1399
				goal = sanitizeUTF8(toStr(info.goal)), -- 1400
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)), -- 1401
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap( -- 1402
					__TS__ArrayFilter( -- 1403
						info.filesHint, -- 1403
						function(____, item) return type(item) == "string" end -- 1403
					), -- 1403
					function(____, item) return sanitizeUTF8(item) end -- 1403
				) or ({}), -- 1403
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"), -- 1405
				success = info.success == true, -- 1406
				cleared = info.cleared == true, -- 1407
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)), -- 1408
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path( -- 1409
					"subagents", -- 1409
					Path:getFilename(path) -- 1409
				)), -- 1409
				sourceTaskId = sourceTaskId or 0, -- 1410
				changeSet = decodeChangeSetSummary(info.changeSet), -- 1411
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence), -- 1412
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry), -- 1413
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)), -- 1414
				completion = normalizeAgentCompletionReport(info.completion), -- 1415
				createdAt = sanitizeUTF8(toStr(info.createdAt)), -- 1416
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)), -- 1417
				createdAtTs = tonumber(info.createdAtTs) or 0, -- 1418
				finishedAtTs = tonumber(info.finishedAtTs) or 0 -- 1419
			} -- 1419
		end -- 1419
		::__continue284:: -- 1419
	end -- 1419
	__TS__ArraySort( -- 1422
		items, -- 1422
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end -- 1422
	) -- 1422
	return items -- 1423
end -- 1423
function normalizePromptText(prompt) -- 1587
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or "")) -- 1588
end -- 1588
function normalizePromptTextSafe(prompt) -- 1591
	if type(prompt) == "string" then -- 1591
		local normalized = normalizePromptText(prompt) -- 1593
		if normalized ~= "" then -- 1593
			return normalized -- 1594
		end -- 1594
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt)) -- 1595
		if sanitized ~= "" then -- 1595
			return truncateAgentUserPrompt(sanitized) -- 1597
		end -- 1597
		return "" -- 1599
	end -- 1599
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt))) -- 1601
	if text == "" then -- 1601
		return "" -- 1602
	end -- 1602
	return truncateAgentUserPrompt(text) -- 1603
end -- 1603
function buildSubAgentPromptFallback(title, expectedOutput, filesHint) -- 1606
	local sections = {} -- 1607
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or "")) -- 1608
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or "")) -- 1609
	local normalizedFiles = __TS__ArrayFilter( -- 1610
		__TS__ArrayMap( -- 1610
			__TS__ArrayFilter( -- 1610
				filesHint or ({}), -- 1610
				function(____, item) return type(item) == "string" end -- 1611
			), -- 1611
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end -- 1612
		), -- 1612
		function(____, item) return item ~= "" end -- 1613
	) -- 1613
	if normalizedTitle ~= "" then -- 1613
		sections[#sections + 1] = "Task: " .. normalizedTitle -- 1615
	end -- 1615
	if normalizedExpected ~= "" then -- 1615
		sections[#sections + 1] = "Expected output: " .. normalizedExpected -- 1618
	end -- 1618
	if #normalizedFiles > 0 then -- 1618
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ") -- 1621
	end -- 1621
	return __TS__StringTrim(table.concat(sections, "\n\n")) -- 1623
end -- 1623
function normalizeSessionRuntimeState(session) -- 1626
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then -- 1626
		return session -- 1628
	end -- 1628
	if activeStopTokens[session.currentTaskId] ~= nil then -- 1628
		return session -- 1631
	end -- 1631
	if activeLocalAgentControls[session.currentTaskId] ~= nil then -- 1631
		return session -- 1634
	end -- 1634
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?) AND status IN ('PENDING', 'RUNNING')", { -- 1636
		session.id, -- 1639
		session.currentTaskId, -- 1639
		"fetch_url", -- 1639
		"execute_command", -- 1639
		"analyze_image" -- 1639
	}) or ({}) -- 1639
	if #pendingToolRows > 0 then -- 1639
		local t = now() -- 1642
		do -- 1642
			local i = 0 -- 1643
			while i < #pendingToolRows do -- 1643
				local row = pendingToolRows[i + 1] -- 1644
				local result = decodeJsonObject(toStr(row[2])) or ({}) -- 1645
				result.success = false -- 1646
				result.state = "failed" -- 1647
				result.interrupted = true -- 1648
				result.message = "tool call was interrupted because the program exited before it completed." -- 1649
				DB:exec( -- 1650
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?", -- 1650
					{ -- 1652
						encodeJson(result), -- 1652
						t, -- 1652
						row[1] -- 1652
					} -- 1652
				) -- 1652
				i = i + 1 -- 1643
			end -- 1643
		end -- 1643
		Tools.setTaskStatus(session.currentTaskId, "FAILED") -- 1655
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED") -- 1656
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t}) -- 1657
	end -- 1657
	Tools.setTaskStatus(session.currentTaskId, "STOPPED") -- 1664
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED") -- 1665
	return __TS__ObjectAssign( -- 1666
		{}, -- 1666
		session, -- 1667
		{ -- 1666
			status = "STOPPED", -- 1668
			currentTaskStatus = "STOPPED", -- 1669
			updatedAt = now() -- 1670
		} -- 1670
	) -- 1670
end -- 1670
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus) -- 1674
	DB:exec( -- 1675
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1675
		{ -- 1679
			status, -- 1680
			currentTaskId or 0, -- 1681
			currentTaskStatus or status, -- 1682
			now(), -- 1683
			sessionId -- 1684
		} -- 1684
	) -- 1684
end -- 1684
function decodeSessionMetrics(text) -- 1689
	local metrics = decodeJsonObject(text) -- 1690
	local context = metrics and metrics.context -- 1691
	if (context and context.source) == "llm_input_estimate" and type(context.maxTokens) == "number" and context.maxTokens > 0 and type(context.messagesTokens) == "number" then -- 1691
		local usedTokens = context.messagesTokens + (context.optionsTokens or 0) + (context.toolDefinitionsTokens or 0) + (context.structuralOverhead or 0) -- 1694
		return __TS__ObjectAssign( -- 1696
			{}, -- 1696
			metrics, -- 1697
			{context = __TS__ObjectAssign( -- 1696
				{}, -- 1698
				context, -- 1699
				{ -- 1698
					usedTokens = usedTokens, -- 1700
					ratio = math.max( -- 1701
						0, -- 1701
						math.min(1, usedTokens / context.maxTokens) -- 1701
					), -- 1701
					source = "llm_input_only_estimate" -- 1702
				} -- 1702
			)} -- 1702
		) -- 1702
	end -- 1702
	return metrics -- 1706
end -- 1706
function mergeAgentMetrics(current, next) -- 1709
	return __TS__ObjectAssign({}, current or ({}), next) -- 1710
end -- 1710
function updateSessionMetrics(sessionId, metrics) -- 1716
	local session = getSessionItem(sessionId) -- 1717
	if not session then -- 1717
		return nil -- 1718
	end -- 1718
	local merged = mergeAgentMetrics(session.metrics, metrics) -- 1719
	DB:exec( -- 1720
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1720
		{ -- 1724
			encodeJson(merged), -- 1725
			now(), -- 1726
			sessionId -- 1727
		} -- 1727
	) -- 1727
	return merged -- 1730
end -- 1730
function clearSessionTokenUsage(sessionId) -- 1733
	local session = getSessionItem(sessionId) -- 1734
	if not session then -- 1734
		return nil -- 1735
	end -- 1735
	local metrics = __TS__ObjectAssign({}, session.metrics or ({})) -- 1736
	__TS__Delete(metrics, "usage") -- 1737
	__TS__Delete(metrics, "visionUsage") -- 1738
	DB:exec( -- 1739
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1739
		{ -- 1743
			encodeJson(metrics), -- 1744
			now(), -- 1745
			sessionId -- 1746
		} -- 1746
	) -- 1746
	return metrics -- 1749
end -- 1749
function getInitialTokenUsage(session) -- 1752
	local ____opt_115 = session.metrics -- 1752
	local usage = ____opt_115 and ____opt_115.usage -- 1753
	if not usage or (usage.requestCount or 0) <= 0 then -- 1753
		return nil -- 1754
	end -- 1754
	return { -- 1755
		inputTokens = usage.inputTokens or 0, -- 1756
		outputTokens = usage.outputTokens or 0, -- 1757
		totalTokens = usage.totalTokens, -- 1758
		cachedInputTokens = usage.cachedInputTokens, -- 1759
		cacheMissInputTokens = usage.cacheMissInputTokens, -- 1760
		reasoningOutputTokens = usage.reasoningOutputTokens, -- 1761
		requestCount = usage.requestCount or 0, -- 1762
		cacheReportedRequestCount = usage.cacheReportedRequestCount, -- 1763
		model = usage.model or "", -- 1764
		phase = usage.phase or "", -- 1765
		step = usage.step or 0, -- 1766
		updatedAt = usage.updatedAt or now() -- 1767
	} -- 1767
end -- 1767
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus) -- 1771
	if taskId == nil or taskId <= 0 then -- 1771
		setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1773
		return -- 1774
	end -- 1774
	local row = getSessionRow(sessionId) -- 1776
	if not row then -- 1776
		return -- 1777
	end -- 1777
	local session = rowToSession(row) -- 1778
	if session.currentTaskId ~= taskId then -- 1778
		Log( -- 1780
			"Info", -- 1780
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 1780
		) -- 1780
		return -- 1781
	end -- 1781
	setSessionState(sessionId, status, taskId, currentTaskStatus) -- 1783
end -- 1783
function insertMessage(sessionId, role, content, taskId, displayContent) -- 1786
	local t = now() -- 1787
	DB:exec( -- 1788
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)", -- 1788
		{ -- 1791
			sessionId, -- 1792
			taskId or 0, -- 1793
			role, -- 1794
			sanitizeUTF8(content), -- 1795
			displayContent and sanitizeUTF8(displayContent) or "", -- 1796
			t, -- 1797
			t -- 1798
		} -- 1798
	) -- 1798
	return getLastInsertRowId() -- 1801
end -- 1801
function updateMessage(messageId, content) -- 1804
	DB:exec( -- 1805
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?", -- 1805
		{ -- 1807
			sanitizeUTF8(content), -- 1807
			now(), -- 1807
			messageId -- 1807
		} -- 1807
	) -- 1807
end -- 1807
function updateUserMessageForTask(messageId, content, taskId) -- 1811
	DB:exec( -- 1812
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?", -- 1812
		{ -- 1816
			sanitizeUTF8(content), -- 1816
			taskId, -- 1816
			now(), -- 1816
			messageId -- 1816
		} -- 1816
	) -- 1816
end -- 1816
function removeContinuableTaskSummary(session) -- 1876
	local taskId = session.currentTaskId -- 1877
	if taskId == nil then -- 1877
		return -- 1878
	end -- 1878
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"}) -- 1879
end -- 1879
function upsertAssistantMessage(sessionId, taskId, content) -- 1891
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"}) -- 1892
	if row and type(row[1]) == "number" then -- 1892
		updateMessage(row[1], content) -- 1899
		return row[1] -- 1900
	end -- 1900
	return insertMessage(sessionId, "assistant", content, taskId) -- 1902
end -- 1902
function upsertStep(sessionId, taskId, step, tool, patch) -- 1905
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step}) -- 1915
	local reason = sanitizeUTF8(patch.reason or "") -- 1919
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "") -- 1920
	local paramsJson = patch.params and encodeJson(patch.params) or "" -- 1921
	local resultJson = patch.result and encodeJson(patch.result) or "" -- 1922
	local filesJson = patch.files and encodeJson(patch.files) or "" -- 1923
	local statusPatch = patch.status or "" -- 1924
	local status = patch.status or "PENDING" -- 1925
	if not row then -- 1925
		local t = now() -- 1927
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", { -- 1928
			sessionId, -- 1932
			taskId, -- 1933
			step, -- 1934
			tool, -- 1935
			status, -- 1936
			reason, -- 1937
			reasoningContent, -- 1938
			paramsJson, -- 1939
			resultJson, -- 1940
			patch.checkpointId or 0, -- 1941
			patch.checkpointSeq or 0, -- 1942
			filesJson, -- 1943
			t, -- 1944
			t -- 1945
		}) -- 1945
		return -- 1948
	end -- 1948
	DB:exec( -- 1950
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?", -- 1950
		{ -- 1962
			tool, -- 1963
			statusPatch, -- 1964
			status, -- 1965
			reason, -- 1966
			reason, -- 1967
			reasoningContent, -- 1968
			reasoningContent, -- 1969
			paramsJson, -- 1970
			paramsJson, -- 1971
			resultJson, -- 1972
			resultJson, -- 1973
			patch.checkpointId or 0, -- 1974
			patch.checkpointId or 0, -- 1975
			patch.checkpointSeq or 0, -- 1976
			patch.checkpointSeq or 0, -- 1977
			filesJson, -- 1978
			filesJson, -- 1979
			now(), -- 1980
			row[1] -- 1981
		} -- 1981
	) -- 1981
end -- 1981
function getNextStepNumber(sessionId, taskId) -- 1986
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId}) -- 1987
	local current = row and type(row[1]) == "number" and row[1] or 0 -- 1991
	return math.max(0, current) + 1 -- 1992
end -- 1992
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params) -- 2033
	local step = getNextStepNumber(sessionId, ownerTaskId) -- 2041
	local t = now() -- 2042
	local sqls = { -- 2043
		{ -- 2044
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)", -- 2044
			{{ -- 2047
				sessionId, -- 2048
				ownerTaskId, -- 2049
				step, -- 2050
				"sub_agent_handoff", -- 2051
				"DONE", -- 2052
				sanitizeUTF8(reason), -- 2053
				encodeJson(params), -- 2054
				encodeJson(result), -- 2055
				t, -- 2056
				t -- 2057
			}} -- 2057
		}, -- 2057
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}} -- 2060
	} -- 2060
	if not DB:transaction(sqls) then -- 2060
		return nil -- 2066
	end -- 2066
	return getStepItem(sessionId, ownerTaskId, step) -- 2067
end -- 2067
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus) -- 2070
	if taskId <= 0 then -- 2070
		return -- 2071
	end -- 2071
	if finalSteps ~= nil and finalSteps >= 0 then -- 2071
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps}) -- 2073
	end -- 2073
	if not finalStatus then -- 2073
		return -- 2079
	end -- 2079
	if finalSteps ~= nil and finalSteps >= 0 then -- 2079
		DB:exec( -- 2081
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')", -- 2081
			{ -- 2085
				finalStatus, -- 2085
				now(), -- 2085
				sessionId, -- 2085
				taskId, -- 2085
				finalSteps -- 2085
			} -- 2085
		) -- 2085
		return -- 2087
	end -- 2087
	DB:exec( -- 2089
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')", -- 2089
		{ -- 2093
			finalStatus, -- 2093
			now(), -- 2093
			sessionId, -- 2093
			taskId -- 2093
		} -- 2093
	) -- 2093
end -- 2093
function emitAgentSessionPatch(sessionId, patch) -- 2120
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch)) -- 2121
	if not text then -- 2121
		return -- 2126
	end -- 2126
	local failed = publishSessionPatch(sessionId, text) -- 2127
	if failed > 0 then -- 2127
		Log( -- 2128
			"Warn", -- 2128
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed" -- 2128
		) -- 2128
	end -- 2128
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then -- 2128
		emit("AppWS", "Send", text) -- 2129
	end -- 2129
end -- 2129
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot) -- 2132
	emitAgentSessionPatch( -- 2133
		sessionId, -- 2133
		{ -- 2133
			sessionDeleted = true, -- 2134
			relatedSessions = listRelatedSessions(rootSessionId) -- 2135
		} -- 2135
	) -- 2135
	local rootSession = getSessionItem(rootSessionId) -- 2137
	if rootSession then -- 2137
		emitAgentSessionPatch( -- 2139
			rootSessionId, -- 2139
			{ -- 2139
				session = rootSession, -- 2140
				relatedSessions = listRelatedSessions(rootSessionId) -- 2141
			} -- 2141
		) -- 2141
	end -- 2141
end -- 2141
function flushPendingSubAgentHandoffs(rootSession) -- 2146
	if rootSession.kind ~= "main" then -- 2146
		return -- 2147
	end -- 2147
	if rootSession.currentTaskStatus == "RUNNING" then -- 2147
		return -- 2149
	end -- 2149
	local items = __TS__ArrayFilter( -- 2151
		handoffs:list(rootSession.projectRoot, rootSession.memoryScope), -- 2151
		function(____, item) return not handoffs:timelinePublished(rootSession, item) end -- 2152
	) -- 2152
	if #items == 0 then -- 2152
		return -- 2153
	end -- 2153
	local ____temp_120 -- 2154
	if rootSession.currentTaskStatus == "DONE" then -- 2154
		____temp_120 = rootSession.currentTaskId -- 2154
	else -- 2154
		____temp_120 = nil -- 2154
	end -- 2154
	local handoffTaskId = ____temp_120 -- 2154
	if handoffTaskId == nil then -- 2154
		local taskRes = Tools.createTask( -- 2156
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)", -- 2156
			"code" -- 2156
		) -- 2156
		if not taskRes.success then -- 2156
			Log( -- 2158
				"Warn", -- 2158
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message -- 2158
			) -- 2158
			return -- 2159
		end -- 2159
		handoffTaskId = taskRes.taskId -- 2161
		Tools.setTaskStatus(handoffTaskId, "DONE") -- 2162
		if rootSession.currentTaskId == nil then -- 2162
			setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE") -- 2164
			emitAgentSessionPatch( -- 2165
				rootSession.id, -- 2165
				{session = getSessionItem(rootSession.id)} -- 2165
			) -- 2165
		end -- 2165
	end -- 2165
	do -- 2165
		local i = 0 -- 2168
		while i < #items do -- 2168
			local item = items[i + 1] -- 2169
			local step = appendHandoffSystemStep( -- 2170
				rootSession.id, -- 2171
				handoffTaskId, -- 2172
				item.sourceTaskId, -- 2173
				item.message, -- 2174
				{ -- 2175
					sourceSessionId = item.sourceSessionId, -- 2176
					sourceTitle = item.sourceTitle, -- 2177
					sourceTaskId = item.sourceTaskId, -- 2178
					success = item.success == true, -- 2179
					status = item.status, -- 2180
					summary = item.message, -- 2181
					resultFilePath = item.resultFilePath or "", -- 2182
					artifactDir = item.artifactDir or "", -- 2183
					finishedAt = item.finishedAt or "", -- 2184
					changeSet = item.changeSet, -- 2185
					handoffEvidence = item.handoffEvidence, -- 2186
					memoryEntry = item.memoryEntry, -- 2187
					completion = item.completion -- 2188
				}, -- 2188
				{ -- 2190
					sourceSessionId = item.sourceSessionId, -- 2191
					sourceTitle = item.sourceTitle, -- 2192
					sourceTaskId = item.sourceTaskId, -- 2193
					prompt = item.prompt, -- 2194
					goal = item.goal ~= "" and item.goal or item.sourceTitle, -- 2195
					expectedOutput = item.expectedOutput or "", -- 2196
					filesHint = item.filesHint or ({}), -- 2197
					resultFilePath = item.resultFilePath or "", -- 2198
					artifactDir = item.artifactDir or "", -- 2199
					changeSet = item.changeSet, -- 2200
					handoffEvidence = item.handoffEvidence, -- 2201
					memoryEntry = item.memoryEntry, -- 2202
					completion = item.completion -- 2203
				} -- 2203
			) -- 2203
			if step then -- 2203
				emitAgentSessionPatch(rootSession.id, {step = step}) -- 2207
				if not handoffs:mark(rootSession, item.id, "timeline") then -- 2207
					Log("Warn", "[AgentSession] failed to acknowledge sub-agent handoff timeline id=" .. item.id) -- 2209
				end -- 2209
			else -- 2209
				Log( -- 2212
					"Warn", -- 2212
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId) -- 2212
				) -- 2212
			end -- 2212
			i = i + 1 -- 2168
		end -- 2168
	end -- 2168
end -- 2168
function applyEvent(sessionId, event) -- 2225
	if not getSessionItem(sessionId) then -- 2225
		streamUpdates:clear(sessionId) -- 2227
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then -- 2227
			__TS__Delete(activeStopTokens, event.taskId) -- 2229
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId) -- 2230
		end -- 2230
		return -- 2232
	end -- 2232
	repeat -- 2232
		local ____switch419 = event.type -- 2232
		local metrics, startedSession -- 2232
		local ____cond419 = ____switch419 == "task_started" -- 2232
		if ____cond419 then -- 2232
			streamUpdates:clear(sessionId) -- 2236
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING") -- 2237
			local ____event_resumed_123 -- 2238
			if event.resumed then -- 2238
				local ____opt_121 = getSessionItem(sessionId) -- 2238
				____event_resumed_123 = ____opt_121 and ____opt_121.metrics -- 2239
			else -- 2239
				____event_resumed_123 = clearSessionTokenUsage(sessionId) -- 2240
			end -- 2240
			metrics = ____event_resumed_123 -- 2238
			startedSession = getSessionItem(sessionId) -- 2241
			emitAgentSessionPatch( -- 2242
				sessionId, -- 2242
				{ -- 2242
					session = startedSession, -- 2243
					metrics = metrics, -- 2244
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2245
				} -- 2245
			) -- 2245
			break -- 2249
		end -- 2249
		____cond419 = ____cond419 or ____switch419 == "decision_made" -- 2249
		if ____cond419 then -- 2249
			upsertStep( -- 2251
				sessionId, -- 2251
				event.taskId, -- 2251
				event.step, -- 2251
				event.tool, -- 2251
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params} -- 2251
			) -- 2251
			emitAgentSessionPatch( -- 2259
				sessionId, -- 2259
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2259
			) -- 2259
			break -- 2262
		end -- 2262
		____cond419 = ____cond419 or ____switch419 == "tool_started" -- 2262
		if ____cond419 then -- 2262
			upsertStep( -- 2264
				sessionId, -- 2264
				event.taskId, -- 2264
				event.step, -- 2264
				event.tool, -- 2264
				{status = "RUNNING"} -- 2264
			) -- 2264
			emitAgentSessionPatch( -- 2267
				sessionId, -- 2267
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2267
			) -- 2267
			break -- 2270
		end -- 2270
		____cond419 = ____cond419 or ____switch419 == "tool_finished" -- 2270
		if ____cond419 then -- 2270
			do -- 2270
				upsertStep( -- 2272
					sessionId, -- 2272
					event.taskId, -- 2272
					event.step, -- 2272
					event.tool, -- 2272
					{status = event.execution.status, reason = event.reason, result = event.result} -- 2272
				) -- 2272
				emitAgentSessionPatch( -- 2280
					sessionId, -- 2280
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2280
				) -- 2280
				break -- 2283
			end -- 2283
		end -- 2283
		____cond419 = ____cond419 or ____switch419 == "tool_progress" -- 2283
		if ____cond419 then -- 2283
			do -- 2283
				local currentStep = getStepItem(sessionId, event.taskId, event.step) -- 2287
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then -- 2287
					break -- 2289
				end -- 2289
			end -- 2289
			upsertStep( -- 2292
				sessionId, -- 2292
				event.taskId, -- 2292
				event.step, -- 2292
				event.tool, -- 2292
				{status = "RUNNING", result = event.result} -- 2292
			) -- 2292
			emitAgentSessionPatch( -- 2296
				sessionId, -- 2296
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2296
			) -- 2296
			break -- 2299
		end -- 2299
		____cond419 = ____cond419 or ____switch419 == "checkpoint_created" -- 2299
		if ____cond419 then -- 2299
			upsertStep( -- 2301
				sessionId, -- 2301
				event.taskId, -- 2301
				event.step, -- 2301
				event.tool, -- 2301
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files} -- 2301
			) -- 2301
			emitAgentSessionPatch( -- 2306
				sessionId, -- 2306
				{ -- 2306
					step = getStepItem(sessionId, event.taskId, event.step), -- 2307
					checkpoint = Tools.getCheckpoint(event.checkpointId) -- 2308
				} -- 2308
			) -- 2308
			break -- 2310
		end -- 2310
		____cond419 = ____cond419 or ____switch419 == "memory_compression_started" -- 2310
		if ____cond419 then -- 2310
			upsertStep( -- 2312
				sessionId, -- 2312
				event.taskId, -- 2312
				event.step, -- 2312
				event.tool, -- 2312
				{status = "RUNNING", reason = event.reason, params = event.params} -- 2312
			) -- 2312
			emitAgentSessionPatch( -- 2317
				sessionId, -- 2317
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2317
			) -- 2317
			break -- 2320
		end -- 2320
		____cond419 = ____cond419 or ____switch419 == "memory_compression_finished" -- 2320
		if ____cond419 then -- 2320
			upsertStep( -- 2322
				sessionId, -- 2322
				event.taskId, -- 2322
				event.step, -- 2322
				event.tool, -- 2322
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result} -- 2322
			) -- 2322
			emitAgentSessionPatch( -- 2327
				sessionId, -- 2327
				{step = getStepItem(sessionId, event.taskId, event.step)} -- 2327
			) -- 2327
			break -- 2330
		end -- 2330
		____cond419 = ____cond419 or ____switch419 == "metrics_updated" -- 2330
		if ____cond419 then -- 2330
			do -- 2330
				local metrics = updateSessionMetrics(sessionId, event.metrics) -- 2332
				emitAgentSessionPatch(sessionId, {metrics = metrics}) -- 2333
				break -- 2336
			end -- 2336
		end -- 2336
		____cond419 = ____cond419 or ____switch419 == "assistant_message_updated" -- 2336
		if ____cond419 then -- 2336
			do -- 2336
				local session = getSessionItem(sessionId) -- 2339
				if (session and session.currentTaskId) ~= event.taskId then -- 2339
					streamUpdates:clear(sessionId, event.taskId) -- 2341
					break -- 2341
				end -- 2341
				streamUpdates:update( -- 2343
					sessionId, -- 2343
					event.taskId, -- 2343
					event.step, -- 2343
					event, -- 2343
					App.runningTime -- 2343
				) -- 2343
				scheduleStreamFlush() -- 2344
				break -- 2345
			end -- 2345
		end -- 2345
		____cond419 = ____cond419 or ____switch419 == "assistant_message_finished" -- 2345
		if ____cond419 then -- 2345
			do -- 2345
				local ____opt_126 = getSessionItem(sessionId) -- 2345
				if (____opt_126 and ____opt_126.currentTaskId) ~= event.taskId then -- 2345
					streamUpdates:clear(sessionId, event.taskId) -- 2349
					break -- 2349
				end -- 2349
				streamUpdates:finish(sessionId, event.taskId, event.step) -- 2351
				upsertStep( -- 2352
					sessionId, -- 2352
					event.taskId, -- 2352
					event.step, -- 2352
					"message", -- 2352
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result} -- 2352
				) -- 2352
				emitAgentSessionPatch( -- 2358
					sessionId, -- 2358
					{step = getStepItem(sessionId, event.taskId, event.step)} -- 2358
				) -- 2358
				break -- 2361
			end -- 2361
		end -- 2361
		____cond419 = ____cond419 or ____switch419 == "task_waiting_for_user" -- 2361
		if ____cond419 then -- 2361
			do -- 2361
				local ____opt_128 = getSessionItem(sessionId) -- 2361
				if (____opt_128 and ____opt_128.currentTaskId) ~= event.taskId then -- 2361
					streamUpdates:clear(sessionId, event.taskId) -- 2365
					break -- 2365
				end -- 2365
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2367
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER") -- 2368
				__TS__Delete(activeStopTokens, event.taskId) -- 2369
				emitAgentSessionPatch( -- 2370
					sessionId, -- 2370
					{ -- 2370
						session = getSessionItem(sessionId), -- 2371
						pendingQuestionnaire = getPendingQuestionnaire(sessionId) -- 2372
					} -- 2372
				) -- 2372
				break -- 2374
			end -- 2374
		end -- 2374
		____cond419 = ____cond419 or ____switch419 == "task_finished" -- 2374
		if ____cond419 then -- 2374
			do -- 2374
				local session = getSessionItem(sessionId) -- 2377
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then -- 2377
					__TS__Delete(activeStopTokens, event.taskId) -- 2379
					streamUpdates:clear(sessionId, event.taskId) -- 2380
					Log( -- 2381
						"Info", -- 2381
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId) -- 2381
					) -- 2381
					break -- 2382
				end -- 2382
				streamUpdates:clear(sessionId, event.taskId, App.runningTime) -- 2384
				local ____opt_130 = activeStopTokens[event.taskId or -1] -- 2384
				local stopped = (____opt_130 and ____opt_130.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED" -- 2385
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 2387
				local isSubSession = (session and session.kind) == "sub" -- 2390
				local sessionStatus = isSubSession and "RUNNING" or finalStatus -- 2391
				if isSubSession and event.taskId ~= nil then -- 2391
					finalizingSubSessionTaskIds[event.taskId] = true -- 2393
				end -- 2393
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus) -- 2395
				if event.taskId ~= nil then -- 2395
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId) -- 2397
					local ____finalizeTaskSteps_136 = finalizeTaskSteps -- 2398
					local ____array_135 = __TS__SparseArrayNew( -- 2398
						sessionId, -- 2399
						event.taskId, -- 2400
						type(event.steps) == "number" and math.max( -- 2401
							0, -- 2401
							math.floor(event.steps) -- 2401
						) or nil -- 2401
					) -- 2401
					local ____event_success_134 -- 2402
					if event.success then -- 2402
						____event_success_134 = nil -- 2402
					else -- 2402
						____event_success_134 = stopped and "STOPPED" or "FAILED" -- 2402
					end -- 2402
					__TS__SparseArrayPush(____array_135, ____event_success_134) -- 2402
					____finalizeTaskSteps_136(__TS__SparseArraySpread(____array_135)) -- 2398
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message) -- 2404
					if not isSubSession then -- 2404
						__TS__Delete(activeStopTokens, event.taskId) -- 2406
					end -- 2406
					emitAgentSessionPatch( -- 2408
						sessionId, -- 2408
						{ -- 2408
							session = getSessionItem(sessionId), -- 2409
							message = getMessageItem(messageId), -- 2410
							removedStepIds = removedStepIds -- 2411
						} -- 2411
					) -- 2411
				end -- 2411
				local updatedSession = getSessionItem(sessionId) -- 2414
				if (updatedSession and updatedSession.kind) == "main" then -- 2414
					flushPendingSubAgentHandoffs(updatedSession) -- 2416
				end -- 2416
				break -- 2418
			end -- 2418
		end -- 2418
	until true -- 2418
end -- 2418
function ____exports.createSession(projectRoot, title) -- 2423
	if title == nil then -- 2423
		title = "" -- 2423
	end -- 2423
	local storage = requireAgentStorage() -- 2424
	if not storage.success then -- 2424
		return storage -- 2425
	end -- 2425
	if not isValidProjectRoot(projectRoot) then -- 2425
		return {success = false, message = "invalid projectRoot"} -- 2427
	end -- 2427
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot}) -- 2429
	if row then -- 2429
		return { -- 2438
			success = true, -- 2438
			session = restorePendingQuestionnaireState(rowToSession(row)).session -- 2438
		} -- 2438
	end -- 2438
	local t = now() -- 2440
	DB:exec( -- 2441
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')", -- 2441
		{ -- 2444
			projectRoot, -- 2444
			title ~= "" and title or Path:getFilename(projectRoot), -- 2444
			t, -- 2444
			t -- 2444
		} -- 2444
	) -- 2444
	local sessionId = getLastInsertRowId() -- 2446
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId}) -- 2447
	local session = getSessionItem(sessionId) -- 2448
	if not session then -- 2448
		return {success = false, message = "failed to create session"} -- 2450
	end -- 2450
	return {success = true, session = session} -- 2452
end -- 2423
function ____exports.createSubSession(parentSessionId, title) -- 2455
	if title == nil then -- 2455
		title = "" -- 2455
	end -- 2455
	local storage = requireAgentStorage() -- 2456
	if not storage.success then -- 2456
		return storage -- 2457
	end -- 2457
	local parent = getSessionItem(parentSessionId) -- 2458
	if not parent then -- 2458
		return {success = false, message = "parent session not found"} -- 2460
	end -- 2460
	local rootId = getSessionRootId(parent) -- 2462
	if isProjectTaskAdmissionClosed(parent.projectRoot) then -- 2462
		return {success = false, message = "project task admission is closed"} -- 2463
	end -- 2463
	local t = now() -- 2464
	DB:exec( -- 2465
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)", -- 2465
		{ -- 2468
			parent.projectRoot, -- 2468
			title ~= "" and title or "Sub " .. tostring(rootId), -- 2468
			rootId, -- 2468
			parent.id, -- 2468
			t, -- 2468
			t -- 2468
		} -- 2468
	) -- 2468
	local sessionId = getLastInsertRowId() -- 2470
	local memoryScope = "subagents/" .. tostring(sessionId) -- 2471
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId}) -- 2472
	local session = getSessionItem(sessionId) -- 2473
	if not session then -- 2473
		return {success = false, message = "failed to create sub session"} -- 2475
	end -- 2475
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope) -- 2477
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope) -- 2478
	subStorage:writeMemory(parentStorage:readMemory()) -- 2479
	return {success = true, session = session} -- 2480
end -- 2455
function spawnSubAgentSession(request) -- 2483
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2483
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or "")) -- 2497
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt) -- 2498
		local normalizedPrompt = normalizePromptTextSafe(request.prompt) -- 2499
		if normalizedPrompt == "" then -- 2499
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint) -- 2501
		end -- 2501
		if normalizedPrompt == "" then -- 2501
			local ____Log_144 = Log -- 2508
			local ____temp_141 = #normalizedTitle -- 2508
			local ____temp_142 = #rawPrompt -- 2508
			local ____temp_143 = #toStr(request.expectedOutput) -- 2508
			local ____opt_139 = request.filesHint -- 2508
			____Log_144( -- 2508
				"Warn", -- 2508
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_141)) .. " raw_prompt_len=") .. tostring(____temp_142)) .. " expected_len=") .. tostring(____temp_143)) .. " files_hint_count=") .. tostring(____opt_139 and #____opt_139 or 0) -- 2508
			) -- 2508
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"}) -- 2508
		end -- 2508
		Log( -- 2511
			"Info", -- 2511
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt) -- 2511
		) -- 2511
		local parentSessionId = request.parentSessionId -- 2512
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then -- 2512
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot) -- 2514
			if not fallbackParent then -- 2514
				local createdMain = ____exports.createSession(request.projectRoot) -- 2516
				if createdMain.success then -- 2516
					fallbackParent = createdMain.session -- 2518
				end -- 2518
			end -- 2518
			if fallbackParent then -- 2518
				Log( -- 2522
					"Warn", -- 2522
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot -- 2522
				) -- 2522
				parentSessionId = fallbackParent.id -- 2523
			end -- 2523
		end -- 2523
		local parentSession = getSessionItem(parentSessionId) -- 2526
		if not parentSession then -- 2526
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"}) -- 2526
		end -- 2526
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession)) -- 2530
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then -- 2530
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"}) -- 2530
		end -- 2530
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then -- 2530
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"}) -- 2530
		end -- 2530
		local agentType = type(request.agentType) == "string" and __TS__StringTrim(request.agentType) or "" -- 2535
		local subPrompt = normalizedPrompt -- 2536
		if agentType ~= "" and agentType ~= "general" then -- 2536
			local wakeContext = TeamWake.buildTeamWakeContext(parentSession.projectRoot, agentType) -- 2538
			if wakeContext ~= "" then -- 2538
				subPrompt = (wakeContext .. "\n\n---\n\n# Task\n") .. normalizedPrompt
				Log( -- 2541
					"Info", -- 2541
					(("[AgentSession] team wake context type=" .. agentType) .. " added_len=") .. tostring(#subPrompt - #normalizedPrompt) -- 2541
				) -- 2541
			else -- 2541
				Log("Info", ("[AgentSession] team wake context type=" .. agentType) .. " empty (no team files yet)") -- 2543
			end -- 2543
		end -- 2543
		local created = ____exports.createSubSession(parentSessionId, request.title) -- 2546
		if not created.success then -- 2546
			return ____awaiter_resolve(nil, created) -- 2546
		end -- 2546
		writeSpawnInfo( -- 2550
			created.session.projectRoot, -- 2550
			created.session.memoryScope, -- 2550
			{ -- 2550
				sessionId = created.session.id, -- 2551
				rootSessionId = created.session.rootSessionId, -- 2552
				parentSessionId = created.session.parentSessionId, -- 2553
				title = created.session.title, -- 2554
				prompt = normalizedPrompt, -- 2555
				goal = normalizedTitle ~= "" and normalizedTitle or request.title, -- 2556
				expectedOutput = request.expectedOutput or "", -- 2557
				filesHint = request.filesHint or ({}), -- 2558
				agentType = agentType, -- 2559
				status = "RUNNING", -- 2560
				success = false, -- 2561
				resultFilePath = "", -- 2562
				artifactDir = getArtifactRelativeDir(created.session.memoryScope), -- 2563
				sourceTaskId = 0, -- 2564
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 2565
				createdAtTs = created.session.createdAt, -- 2566
				finishedAt = "", -- 2567
				finishedAtTs = 0 -- 2568
			} -- 2568
		) -- 2568
		local sent = ____exports.sendPrompt( -- 2570
			created.session.id, -- 2570
			subPrompt, -- 2570
			request.disabledAgentTools, -- 2570
			nil, -- 2570
			nil, -- 2570
			request.llmConfig -- 2570
		) -- 2570
		if not sent.success then -- 2570
			return ____awaiter_resolve(nil, {success = false, message = sent.message}) -- 2570
		end -- 2570
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title}) -- 2570
	end) -- 2570
end -- 2570
function appendSubAgentHandoffStep(session, taskId, result, summary) -- 2694
	local rootSession = getRootSessionItem(session.id) -- 2695
	if not rootSession then -- 2695
		return false -- 2696
	end -- 2696
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId) -- 2697
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2698
	local queueResult = handoffs:write( -- 2699
		rootSession.projectRoot, -- 2699
		rootSession.memoryScope, -- 2699
		{ -- 2699
			id = (("sub_" .. tostring(session.id)) .. "_") .. tostring(taskId), -- 2700
			sourceSessionId = session.id, -- 2701
			sourceTitle = session.title, -- 2702
			sourceTaskId = taskId, -- 2703
			message = summary, -- 2704
			prompt = result.prompt, -- 2705
			goal = result.goal, -- 2706
			expectedOutput = result.expectedOutput or "", -- 2707
			filesHint = result.filesHint or ({}), -- 2708
			success = result.success, -- 2709
			status = result.status, -- 2710
			resultFilePath = result.resultFilePath, -- 2711
			artifactDir = result.artifactDir, -- 2712
			finishedAt = result.finishedAt, -- 2713
			changeSet = changeSet, -- 2714
			handoffEvidence = result.handoffEvidence, -- 2715
			memoryEntry = result.memoryEntry, -- 2716
			completion = result.completion, -- 2717
			createdAt = createdAt -- 2718
		} -- 2718
	) -- 2718
	if not queueResult then -- 2718
		Log( -- 2721
			"Warn", -- 2721
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id) -- 2721
		) -- 2721
		return false -- 2722
	end -- 2722
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then -- 2722
		addTaskReference(rootSession.currentTaskId, taskId) -- 2725
	end -- 2725
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then -- 2725
		flushPendingSubAgentHandoffs(rootSession) -- 2728
	end -- 2728
	return true -- 2730
end -- 2730
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff, stopped) -- 2733
	if forceHandoff == nil then -- 2733
		forceHandoff = false -- 2739
	end -- 2739
	if stopped == nil then -- 2739
		stopped = false -- 2740
	end -- 2740
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2740
		local rootSessionId = getSessionRootId(session) -- 2742
		local rootSession = getRootSessionItem(session.id) -- 2743
		if not rootSession then -- 2743
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 2743
		end -- 2743
		local spawnInfo = getSessionSpawnInfo(session) -- 2747
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2748
		local finishedAtTs = now() -- 2749
		local resultText = sanitizeUTF8(message) -- 2750
		local changeSet = getTaskChangeSetSummary(taskId) -- 2751
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet) -- 2752
		local ____completion_156 = completion -- 2754
		if ____completion_156 == nil then -- 2754
			local ____normalizeAgentCompletionReport_155 = normalizeAgentCompletionReport -- 2754
			local ____opt_153 = handoffEvidence.lastBuild -- 2754
			____completion_156 = ____normalizeAgentCompletionReport_155({outcome = (____opt_153 and ____opt_153.result) == "passed" and "completed" or "partial", knownIssues = {}}) -- 2754
		end -- 2754
		local completionReport = ____completion_156 -- 2754
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence) -- 2758
		if not success and completionReport.outcome == "completed" and not forceHandoff then -- 2758
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "blocked", knownIssues = {resultText ~= "" and resultText or "The sub-agent did not complete."}})) -- 2760
		end -- 2760
		if forceHandoff and not success and completionReport.outcome ~= "partial" then -- 2760
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})})) -- 2767
		end -- 2767
		local completed = success and completionReport.outcome == "completed" -- 2775
		local recordStatus = completed and "DONE" or ((stopped or completionReport.outcome == "partial") and "STOPPED" or "FAILED") -- 2776
		local record = { -- 2779
			sessionId = session.id, -- 2780
			rootSessionId = rootSessionId, -- 2781
			parentSessionId = session.parentSessionId, -- 2782
			title = session.title, -- 2783
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2784
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2785
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2786
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2787
			status = recordStatus, -- 2788
			success = completed, -- 2789
			resultFilePath = Path( -- 2790
				getArtifactRelativeDir(session.memoryScope), -- 2790
				("RESULT-" .. tostring(taskId)) .. ".md" -- 2790
			), -- 2790
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2791
			sourceTaskId = taskId, -- 2792
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2793
			finishedAt = finishedAt, -- 2794
			createdAtTs = session.createdAt, -- 2795
			finishedAtTs = finishedAtTs, -- 2796
			changeSet = changeSet, -- 2797
			handoffEvidence = handoffEvidence, -- 2798
			completion = completionReport -- 2799
		} -- 2799
		local ____record_success_167 -- 2801
		if record.success then -- 2801
			____record_success_167 = buildStructuredSubAgentMemoryEntry(record) -- 2801
		else -- 2801
			____record_success_167 = nil -- 2801
		end -- 2801
		record.memoryEntry = ____record_success_167 -- 2801
		if not writeSubAgentResultFile(session, record, resultText) then -- 2801
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"}) -- 2801
		end -- 2801
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, { -- 2801
			sessionId = record.sessionId, -- 2806
			rootSessionId = record.rootSessionId, -- 2807
			parentSessionId = record.parentSessionId, -- 2808
			title = record.title, -- 2809
			prompt = record.prompt, -- 2810
			goal = record.goal, -- 2811
			expectedOutput = record.expectedOutput or "", -- 2812
			filesHint = record.filesHint or ({}), -- 2813
			status = record.status, -- 2814
			success = record.success, -- 2815
			resultFilePath = record.resultFilePath, -- 2816
			artifactDir = record.artifactDir, -- 2817
			sourceTaskId = record.sourceTaskId, -- 2818
			createdAt = record.createdAt, -- 2819
			finishedAt = record.finishedAt, -- 2820
			createdAtTs = record.createdAtTs, -- 2821
			finishedAtTs = record.finishedAtTs, -- 2822
			changeSet = record.changeSet, -- 2823
			handoffEvidence = record.handoffEvidence, -- 2824
			memoryEntry = record.memoryEntry, -- 2825
			memoryEntryError = record.memoryEntryError, -- 2826
			completion = record.completion -- 2827
		}) then -- 2827
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"}) -- 2827
		end -- 2827
		if not appendSubAgentHandoffStep(session, taskId, record, resultText) then -- 2827
			return ____awaiter_resolve(nil, {success = false, message = "failed to queue sub-agent handoff"}) -- 2827
		end -- 2827
		if success or forceHandoff then -- 2827
			deleteSessionRecords(session.id, true) -- 2835
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot) -- 2836
		end -- 2836
		return ____awaiter_resolve(nil, {success = true}) -- 2836
	end) -- 2836
end -- 2836
function stopClearedSubSession(session, taskId) -- 2841
	local spawnInfo = getSessionSpawnInfo(session) -- 2842
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2843
	local rootSessionId = getSessionRootId(session) -- 2844
	Tools.setTaskStatus(taskId, "STOPPED") -- 2845
	setSessionState(session.id, "STOPPED", taskId, "STOPPED") -- 2846
	if not writeSpawnInfo( -- 2846
		session.projectRoot, -- 2847
		session.memoryScope, -- 2847
		{ -- 2847
			sessionId = session.id, -- 2848
			rootSessionId = rootSessionId, -- 2849
			parentSessionId = session.parentSessionId, -- 2850
			title = session.title, -- 2851
			prompt = spawnInfo and spawnInfo.prompt or "", -- 2852
			goal = spawnInfo and spawnInfo.goal or session.title, -- 2853
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "", -- 2854
			filesHint = spawnInfo and spawnInfo.filesHint or ({}), -- 2855
			status = "STOPPED", -- 2856
			success = false, -- 2857
			cleared = true, -- 2858
			resultFilePath = "", -- 2859
			artifactDir = getArtifactRelativeDir(session.memoryScope), -- 2860
			sourceTaskId = taskId, -- 2861
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt, -- 2862
			finishedAt = finishedAt, -- 2863
			createdAtTs = session.createdAt, -- 2864
			finishedAtTs = now() -- 2865
		} -- 2865
	) then -- 2865
		return {success = false, message = "failed to persist cleared sub session spawn info"} -- 2867
	end -- 2867
	deleteSessionRecords(session.id, true) -- 2869
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot) -- 2870
	return {success = true} -- 2871
end -- 2871
function startImmediatePrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps, inputId) -- 2874
	local session = getSessionItem(sessionId) -- 2875
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2875
		return {success = false, message = "project task admission is closed"} -- 2876
	end -- 2876
	if not session then -- 2876
		return {success = false, message = "session not found"} -- 2878
	end -- 2878
	if getPendingQuestionnaire(sessionId) then -- 2878
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2880
	end -- 2880
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2880
		return {success = false, message = "session task is finalizing"} -- 2882
	end -- 2882
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 2882
		return {success = false, message = "session task is still running"} -- 2885
	end -- 2885
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2887
	if normalizedPrompt == "" and session.kind == "sub" then -- 2887
		local spawnInfo = getSessionSpawnInfo(session) -- 2889
		if spawnInfo then -- 2889
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt) -- 2891
			if normalizedPrompt == "" then -- 2891
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint) -- 2893
			end -- 2893
		end -- 2893
	end -- 2893
	if normalizedPrompt == "" then -- 2893
		return {success = false, message = "prompt is empty"} -- 2902
	end -- 2902
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 2904
	if session.workMode ~= nextWorkMode then -- 2904
		DB:exec( -- 2906
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2906
			{ -- 2906
				nextWorkMode, -- 2906
				now(), -- 2906
				session.id -- 2906
			} -- 2906
		) -- 2906
		session.workMode = nextWorkMode -- 2907
	end -- 2907
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil -- 2909
	return startPromptTask( -- 2910
		session, -- 2910
		normalizedPrompt, -- 2910
		nil, -- 2910
		normalizeDisabledAgentTools(disabledAgentTools), -- 2910
		{ -- 2910
			workMode = nextWorkMode, -- 2910
			llmConfigId = llmConfigId, -- 2910
			llmConfig = llmConfig, -- 2910
			maxSteps = boundedMaxSteps, -- 2910
			inputId = inputId -- 2910
		} -- 2910
	) -- 2910
end -- 2910
function startLocalPrompt(sessionId, prompt, localAgentConfigId, inputId) -- 2913
	local session = getSessionItem(sessionId) -- 2914
	if not session then -- 2914
		return {success = false, message = "session not found"} -- 2915
	end -- 2915
	if session.kind ~= "main" then -- 2915
		return {success = false, message = "local Agent only supports main sessions"} -- 2916
	end -- 2916
	if getPendingQuestionnaire(sessionId) then -- 2916
		return {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 2917
	end -- 2917
	if session.currentTaskStatus == "RUNNING" then -- 2917
		return {success = false, message = "session task is still running"} -- 2918
	end -- 2918
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 2919
	if normalizedPrompt == "" then -- 2919
		return {success = false, message = "prompt is empty"} -- 2920
	end -- 2920
	local config = LocalAgent.getConfig(localAgentConfigId) -- 2921
	if not config then -- 2921
		return {success = false, message = "local Agent config not found"} -- 2922
	end -- 2922
	if not config.verifiedAt then -- 2922
		return {success = false, message = "local Agent config is not verified"} -- 2923
	end -- 2923
	local taskRes = Tools.createTask(normalizedPrompt, "code") -- 2924
	if not taskRes.success then -- 2924
		return taskRes -- 2925
	end -- 2925
	local taskId = taskRes.taskId -- 2926
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId) -- 2927
	if inputId ~= nil then -- 2927
		InputInbox.markDelivering(inputId, taskId) -- 2928
		InputInbox.markDelivered(inputId, messageId) -- 2928
	end -- 2928
	followup.activeRuns[sessionId] = taskId -- 2929
	Tools.setTaskStatus(taskId, "RUNNING") -- 2930
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 2931
	upsertStep( -- 2932
		session.id, -- 2932
		taskId, -- 2932
		1, -- 2932
		"local_agent_message", -- 2932
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}} -- 2932
	) -- 2932
	emitAgentSessionPatch( -- 2938
		session.id, -- 2938
		{ -- 2938
			session = getSessionItem(session.id), -- 2939
			message = getMessageItem(messageId), -- 2940
			step = getStepItem(session.id, taskId, 1) -- 2941
		} -- 2941
	) -- 2941
	local events = {} -- 2943
	local transcript = "" -- 2944
	local assistant = "" -- 2945
	local lastFlush = 0 -- 2946
	local function flush(force) -- 2947
		if force == nil then -- 2947
			force = false -- 2947
		end -- 2947
		if not force and App.runningTime - lastFlush < 0.075 then -- 2947
			return -- 2948
		end -- 2948
		lastFlush = App.runningTime -- 2949
		if #events > 400 then -- 2949
			events = __TS__ArraySlice(events, #events - 400) -- 2950
		end -- 2950
		if #transcript > 1024 * 1024 then -- 2950
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024) -- 2951
		end -- 2951
		upsertStep( -- 2952
			session.id, -- 2952
			taskId, -- 2952
			1, -- 2952
			"local_agent_message", -- 2952
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}} -- 2952
		) -- 2952
		local message -- 2957
		if assistant ~= "" then -- 2957
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant) -- 2959
			message = getMessageItem(assistantId) -- 2960
		end -- 2960
		emitAgentSessionPatch( -- 2962
			session.id, -- 2962
			__TS__ObjectAssign( -- 2962
				{step = getStepItem(session.id, taskId, 1)}, -- 2962
				message and ({message = message}) or ({}) -- 2962
			) -- 2962
		) -- 2962
	end -- 2947
	local completedSynchronously = false -- 2964
	local control = LocalAgent.run( -- 2965
		session.id, -- 2965
		config, -- 2965
		session.projectRoot, -- 2965
		normalizedPrompt, -- 2965
		function(event) -- 2965
			local text = sanitizeUTF8(event.text) -- 2966
			if text == "" then -- 2966
				return -- 2967
			end -- 2967
			local previous = #events > 0 and events[#events] or nil -- 2968
			if previous and previous.kind == event.kind and previous.text == text then -- 2968
				return -- 2969
			end -- 2969
			events[#events + 1] = {kind = event.kind, text = text} -- 2970
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n" -- 2971
			if event.kind == "assistant" then -- 2971
				assistant = text -- 2972
			end -- 2972
			flush(false) -- 2973
		end, -- 2965
		function(result) -- 2974
			completedSynchronously = true -- 2975
			flush(true) -- 2976
			__TS__Delete(activeLocalAgentControls, taskId) -- 2977
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED") -- 2978
			Tools.setTaskStatus(taskId, status) -- 2979
			setSessionState(session.id, status, taskId, status) -- 2980
			upsertStep( -- 2981
				session.id, -- 2981
				taskId, -- 2981
				1, -- 2981
				"local_agent_message", -- 2981
				{status = status, reason = config.name .. " · full permissions", result = { -- 2981
					provider = config.provider, -- 2984
					events = events, -- 2984
					transcript = transcript, -- 2984
					exitCode = result.exitCode, -- 2984
					resumeId = result.resumeId, -- 2984
					message = result.message -- 2984
				}} -- 2984
			) -- 2984
			emitAgentSessionPatch( -- 2986
				session.id, -- 2986
				{ -- 2986
					session = getSessionItem(session.id), -- 2986
					step = getStepItem(session.id, taskId, 1) -- 2986
				} -- 2986
			) -- 2986
			followup.settle(sessionId, taskId, result.success and not result.stopped) -- 2987
		end -- 2974
	) -- 2974
	if not completedSynchronously then -- 2974
		activeLocalAgentControls[taskId] = control -- 2989
	end -- 2989
	return {success = true, sessionId = session.id, taskId = taskId} -- 2990
end -- 2990
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options) -- 3063
	if disabledAgentTools == nil then -- 3063
		disabledAgentTools = {} -- 3067
	end -- 3067
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code" -- 3070
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 3070
		return {success = false, message = "project task admission is closed"} -- 3071
	end -- 3071
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId) -- 3072
	if not llmConfigRes.success then -- 3072
		return {success = false, message = llmConfigRes.message} -- 3076
	end -- 3076
	local llmConfig = llmConfigRes.config -- 3078
	local llmConfigValidation = validateAgentLLMConfig(llmConfig) -- 3079
	if not llmConfigValidation.success then -- 3079
		return llmConfigValidation -- 3081
	end -- 3081
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode) -- 3083
	if not taskRes.success then -- 3083
		return {success = false, message = taskRes.message} -- 3086
	end -- 3086
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then -- 3086
		removeContinuableTaskSummary(session) -- 3088
	end -- 3088
	local taskId = taskRes.taskId -- 3090
	if (options and options.inputId) ~= nil then -- 3090
		InputInbox.markDelivering(options.inputId, taskId) -- 3091
	end -- 3091
	followup.activeRuns[session.id] = taskId -- 3092
	local ____temp_190 -- 3093
	if (options and options.existingTaskId) == nil then -- 3093
		____temp_190 = session.currentTaskId -- 3093
	else -- 3093
		____temp_190 = nil -- 3093
	end -- 3093
	local previousTaskId = ____temp_190 -- 3093
	local useChineseResponse = getDefaultUseChineseResponse() -- 3094
	local promptMessageId -- 3095
	if existingUserMessageId ~= nil then -- 3095
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId) -- 3097
		promptMessageId = existingUserMessageId -- 3098
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then -- 3098
		promptMessageId = insertMessage( -- 3100
			session.id, -- 3100
			"user", -- 3100
			normalizedPrompt, -- 3100
			taskId, -- 3100
			options and options.displayContent -- 3100
		) -- 3100
	end -- 3100
	if (options and options.inputId) ~= nil and promptMessageId ~= nil then -- 3100
		if DB:exec("UPDATE agent.AgentSessionInput SET message_id=? WHERE id=?", {promptMessageId, options.inputId}) < 0 then -- 3100
			error( -- 3103
				__TS__New(Error, "failed to link input display"), -- 3103
				0 -- 3103
			) -- 3103
		end -- 3103
		if normalizedPrompt == "/clear" or normalizedPrompt == "/compact" then -- 3103
			InputInbox.markDelivered(options.inputId, promptMessageId) -- 3104
		end -- 3104
	end -- 3104
	local stopToken = {stopped = false} -- 3106
	activeStopTokens[taskId] = stopToken -- 3107
	setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3108
	emitAgentSessionPatch( -- 3112
		session.id, -- 3112
		__TS__ObjectAssign( -- 3112
			{session = getSessionItem(session.id)}, -- 3112
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({}) -- 3114
		) -- 3114
	) -- 3114
	if previousTaskId and previousTaskId ~= taskId then -- 3114
		if session.kind == "main" then -- 3114
			for ____, item in ipairs(handoffs:list(session.projectRoot, session.memoryScope)) do -- 3119
				handoffs:timelinePublished(session, item) -- 3120
			end -- 3120
		end -- 3120
		cleanupTaskHeavyData(previousTaskId) -- 3123
	end -- 3123
	activePromptRuns = activePromptRuns + 1 -- 3125
	local ____runCodingAgent_226 = runCodingAgent -- 3126
	local ____normalizedPrompt_216 = normalizedPrompt -- 3127
	local ____temp_217 = options and options.inputId -- 3128
	local ____temp_218 = { -- 3129
		pending = function() return __TS__ArrayMap( -- 3130
			__TS__ArrayFilter( -- 3130
				InputInbox.listInputs(session.id), -- 3130
				function(____, item) return item.delivery == "steer" and not item.held and item.status == "pending" end -- 3130
			), -- 3130
			function(____, item) return {id = item.id, content = item.content} end -- 3130
		) end, -- 3130
		delivered = function(id, step) return followup.delivered(session.id, taskId, id, step) end -- 3131
	} -- 3131
	local ____temp_219 = session.kind == "main" and ({ -- 3133
		pending = function() return handoffs:pending(session) end, -- 3134
		delivered = function(____, id) -- 3135
			if not handoffs:mark(session, id, "model") then -- 3135
				error( -- 3136
					__TS__New(Error, "failed to acknowledge sub-agent handoff"), -- 3136
					0 -- 3136
				) -- 3136
			end -- 3136
		end -- 3135
	}) or nil -- 3135
	local ____temp_220 = options and options.resumeConversation -- 3139
	local ____temp_221 = (options and options.existingTaskId) ~= nil -- 3140
	local ____temp_222 = options and options.initialStep -- 3141
	local ____temp_223 = options and options.initialAgentStepCount -- 3142
	local ____temp_211 -- 3143
	if (options and options.existingTaskId) ~= nil then -- 3143
		____temp_211 = getInitialTokenUsage(session) -- 3143
	else -- 3143
		____temp_211 = nil -- 3143
	end -- 3143
	____runCodingAgent_226( -- 3126
		{ -- 3126
			prompt = ____normalizedPrompt_216, -- 3127
			inputId = ____temp_217, -- 3128
			inputSource = ____temp_218, -- 3129
			handoffSource = ____temp_219, -- 3133
			resumeConversation = ____temp_220, -- 3139
			resumeTask = ____temp_221, -- 3140
			initialStep = ____temp_222, -- 3141
			initialAgentStepCount = ____temp_223, -- 3142
			initialTokenUsage = ____temp_211, -- 3143
			workDir = session.projectRoot, -- 3144
			useChineseResponse = useChineseResponse, -- 3145
			taskId = taskId, -- 3146
			sessionId = session.id, -- 3147
			memoryScope = session.memoryScope, -- 3148
			role = session.kind, -- 3149
			maxSteps = options and options.maxSteps, -- 3150
			disabledAgentTools = disabledAgentTools, -- 3151
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code", -- 3152
			llmConfig = llmConfig, -- 3153
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil, -- 3154
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil, -- 3157
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil, -- 3160
			stopToken = stopToken, -- 3161
			onEvent = function(____, event) return applyEvent(session.id, event) end -- 3162
		}, -- 3162
		function(result) -- 3163
			return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3163
				local ____hasReturned, ____returnValue -- 3163
				local ____try = __TS__AsyncAwaiter(function() -- 3163
					local nextSession = getSessionItem(session.id) -- 3165
					if nextSession and nextSession.kind == "sub" then -- 3165
						if __TS__StringTrim(normalizedPrompt) == "/clear" then -- 3165
							local stopped = stopClearedSubSession(nextSession, taskId) -- 3168
							if not stopped.success then -- 3168
								Log( -- 3170
									"Warn", -- 3170
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message -- 3170
								) -- 3170
								emitAgentSessionPatch( -- 3171
									session.id, -- 3171
									{session = getSessionItem(session.id)} -- 3171
								) -- 3171
							end -- 3171
							__TS__Delete(activeStopTokens, taskId) -- 3175
							____hasReturned = true -- 3176
							return -- 3176
						end -- 3176
						setSessionState(session.id, "RUNNING", taskId, "RUNNING") -- 3178
						emitAgentSessionPatch( -- 3179
							session.id, -- 3179
							{session = getSessionItem(session.id)} -- 3179
						) -- 3179
						local finalized = __TS__Await(finalizeSubSession( -- 3182
							nextSession, -- 3183
							taskId, -- 3184
							result.success, -- 3185
							result.message, -- 3186
							result.completion, -- 3187
							(options and options.forceSubAgentHandoff) == true, -- 3188
							stopToken.stopped == true -- 3189
						)) -- 3189
						if not finalized.success then -- 3189
							Log( -- 3192
								"Warn", -- 3192
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message -- 3192
							) -- 3192
						end -- 3192
						local finalizedSession = getSessionItem(session.id) -- 3194
						if finalizedSession then -- 3194
							local stopped = stopToken.stopped == true -- 3196
							local finalStatus = result.success and finalized.success and "DONE" or (stopped and "STOPPED" or "FAILED") -- 3197
							setSessionState(session.id, finalStatus, taskId, finalStatus) -- 3200
							emitAgentSessionPatch( -- 3201
								session.id, -- 3201
								{session = getSessionItem(session.id)} -- 3201
							) -- 3201
						end -- 3201
						__TS__Delete(activeStopTokens, taskId) -- 3205
						__TS__Delete(finalizingSubSessionTaskIds, taskId) -- 3206
					end -- 3206
					local fallbackSession = getSessionItem(session.id) -- 3208
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then -- 3208
						applyEvent(session.id, { -- 3214
							type = "task_finished", -- 3215
							sessionId = session.id, -- 3216
							taskId = result.taskId, -- 3217
							success = false, -- 3218
							message = result.message, -- 3219
							steps = result.steps -- 3220
						}) -- 3220
					end -- 3220
				end) -- 3220
				____try = ____try.finally( -- 3220
					____try, -- 3220
					function() -- 3220
						return __TS__AsyncAwaiter(function() -- 3220
							activePromptRuns = activePromptRuns - 1 -- 3224
							followup.settle(session.id, taskId, result.success and not result.waitingForUser and not stopToken.stopped) -- 3225
						end) -- 3225
					end -- 3225
				) -- 3225
				__TS__Await(____try) -- 3164
				if ____hasReturned then -- 3164
					return ____awaiter_resolve(nil, ____returnValue) -- 3164
				end -- 3164
			end) -- 3164
		end -- 3163
	) -- 3163
	return {success = true, sessionId = session.id, taskId = taskId} -- 3228
end -- 3228
function buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3382
	local lines = {} -- 3383
	do -- 3383
		local i = 0 -- 3384
		while i < #questionnaire.schema.questions do -- 3384
			local question = questionnaire.schema.questions[i + 1] -- 3385
			local answer = __TS__ArrayFind( -- 3386
				answers, -- 3386
				function(____, item) return item.questionId == question.id end -- 3386
			) -- 3386
			local answerText = "已跳过" -- 3387
			if answer and answer.status == "answered" then -- 3387
				local parts = {} -- 3389
				do -- 3389
					local j = 0 -- 3390
					while j < #(answer.selectedOptionIds or ({})) do -- 3390
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3391
						local option = __TS__ArrayFind( -- 3392
							question.options or ({}), -- 3392
							function(____, item) return item.id == optionId end -- 3392
						) -- 3392
						if option then -- 3392
							parts[#parts + 1] = option.label -- 3393
						end -- 3393
						j = j + 1 -- 3390
					end -- 3390
				end -- 3390
				if answer.otherText then -- 3390
					parts[#parts + 1] = answer.otherText -- 3395
				end -- 3395
				if answer.text then -- 3395
					parts[#parts + 1] = answer.text -- 3396
				end -- 3396
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写" -- 3397
			end -- 3397
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText -- 3399
			i = i + 1 -- 3384
		end -- 3384
	end -- 3384
	return table.concat(lines, "\n\n") -- 3401
end -- 3401
function ____exports.listRunningSubAgents(request) -- 3688
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3688
		local session = getSessionItem(request.sessionId) -- 3696
		if not session and request.projectRoot and request.projectRoot ~= "" then -- 3696
			session = getLatestMainSessionByProjectRoot(request.projectRoot) -- 3698
		end -- 3698
		if not session then -- 3698
			return ____awaiter_resolve(nil, {success = false, message = "session not found"}) -- 3698
		end -- 3698
		local rootSession = getRootSessionItem(session.id) -- 3703
		if not rootSession then -- 3703
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"}) -- 3703
		end -- 3703
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status))) -- 3707
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent" -- 3708
		local limit = math.max( -- 3709
			1, -- 3709
			math.floor(tonumber(request.limit) or 5) -- 3709
		) -- 3709
		local offset = math.max( -- 3710
			0, -- 3710
			math.floor(tonumber(request.offset) or 0) -- 3710
		) -- 3710
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query))) -- 3711
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({}) -- 3712
		local runningSessions = {} -- 3719
		do -- 3719
			local i = 0 -- 3720
			while i < #rows do -- 3720
				do -- 3720
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3721
					if current.currentTaskStatus ~= "RUNNING" then -- 3721
						goto __continue690 -- 3723
					end -- 3723
					local spawnInfo = getSessionSpawnInfo(current) -- 3725
					runningSessions[#runningSessions + 1] = { -- 3726
						sessionId = current.id, -- 3727
						title = current.title, -- 3728
						parentSessionId = current.parentSessionId, -- 3729
						rootSessionId = current.rootSessionId, -- 3730
						status = "RUNNING", -- 3731
						currentTaskId = current.currentTaskId, -- 3732
						currentTaskStatus = current.currentTaskStatus or current.status, -- 3733
						goal = spawnInfo and spawnInfo.goal, -- 3734
						expectedOutput = spawnInfo and spawnInfo.expectedOutput, -- 3735
						filesHint = spawnInfo and spawnInfo.filesHint, -- 3736
						createdAt = current.createdAt, -- 3737
						updatedAt = current.updatedAt -- 3738
					} -- 3738
				end -- 3738
				::__continue690:: -- 3738
				i = i + 1 -- 3720
			end -- 3720
		end -- 3720
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id) -- 3741
		local completedSessions = __TS__ArrayMap( -- 3742
			completedRecords, -- 3742
			function(____, record) return { -- 3742
				sessionId = record.sessionId, -- 3743
				title = record.title, -- 3744
				parentSessionId = record.parentSessionId, -- 3745
				rootSessionId = record.rootSessionId, -- 3746
				status = record.status, -- 3747
				goal = record.goal, -- 3748
				expectedOutput = record.expectedOutput, -- 3749
				filesHint = record.filesHint, -- 3750
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath), -- 3751
				success = record.success, -- 3752
				cleared = record.cleared, -- 3753
				resultFilePath = record.resultFilePath, -- 3754
				artifactDir = record.artifactDir, -- 3755
				finishedAt = record.finishedAt, -- 3756
				createdAt = record.createdAtTs, -- 3757
				updatedAt = record.finishedAtTs -- 3758
			} end -- 3758
		) -- 3758
		local merged = {} -- 3760
		if status == "running" then -- 3760
			merged = runningSessions -- 3762
		elseif status == "done" then -- 3762
			merged = __TS__ArrayFilter( -- 3764
				completedSessions, -- 3764
				function(____, item) return item.status == "DONE" end -- 3764
			) -- 3764
		elseif status == "failed" then -- 3764
			merged = __TS__ArrayFilter( -- 3766
				completedSessions, -- 3766
				function(____, item) return item.status == "FAILED" end -- 3766
			) -- 3766
		elseif status == "stopped" then -- 3766
			merged = __TS__ArrayFilter( -- 3768
				completedSessions, -- 3768
				function(____, item) return item.status == "STOPPED" end -- 3768
			) -- 3768
		elseif status == "all" then -- 3768
			merged = __TS__ArrayConcat(runningSessions, completedSessions) -- 3770
		else -- 3770
			local runningKeys = {} -- 3772
			do -- 3772
				local i = 0 -- 3773
				while i < #runningSessions do -- 3773
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true -- 3774
					i = i + 1 -- 3773
				end -- 3773
			end -- 3773
			local latestCompletedByKey = {} -- 3776
			do -- 3776
				local i = 0 -- 3777
				while i < #completedSessions do -- 3777
					do -- 3777
						local item = completedSessions[i + 1] -- 3778
						local key = getSubAgentDisplayKey(item) -- 3779
						if runningKeys[key] then -- 3779
							goto __continue705 -- 3781
						end -- 3781
						local current = latestCompletedByKey[key] -- 3783
						if current == nil or item.updatedAt > current.updatedAt then -- 3783
							latestCompletedByKey[key] = item -- 3785
						end -- 3785
					end -- 3785
					::__continue705:: -- 3785
					i = i + 1 -- 3777
				end -- 3777
			end -- 3777
			local latestCompleted = {} -- 3788
			for ____, item in pairs(latestCompletedByKey) do -- 3789
				latestCompleted[#latestCompleted + 1] = item -- 3790
			end -- 3790
			merged = __TS__ArrayConcat(runningSessions, latestCompleted) -- 3792
		end -- 3792
		if query ~= "" then -- 3792
			merged = __TS__ArrayFilter( -- 3795
				merged, -- 3795
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end -- 3795
			) -- 3795
		end -- 3795
		__TS__ArraySort( -- 3801
			merged, -- 3801
			function(____, a, b) -- 3801
				if a.status == "RUNNING" and b.status ~= "RUNNING" then -- 3801
					return -1 -- 3802
				end -- 3802
				if a.status ~= "RUNNING" and b.status == "RUNNING" then -- 3802
					return 1 -- 3803
				end -- 3803
				if a.status == "RUNNING" or b.status == "RUNNING" then -- 3803
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3805
				end -- 3805
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0) -- 3807
			end -- 3801
		) -- 3801
		local paged = __TS__ArraySlice(merged, offset, offset + limit) -- 3809
		return ____awaiter_resolve(nil, { -- 3809
			success = true, -- 3811
			rootSessionId = rootSession.id, -- 3812
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS, -- 3813
			status = status, -- 3814
			limit = limit, -- 3815
			offset = offset, -- 3816
			hasMore = offset + limit < #merged, -- 3817
			sessions = paged -- 3818
		}) -- 3818
	end) -- 3818
end -- 3688
QUESTIONNAIRE_DIR = ".agent/questionnaire" -- 284
PENDING_QUESTIONNAIRE_FILE = "pending.json" -- 285
SPAWN_INFO_FILE = "SPAWN.json" -- 286
local PENDING_HANDOFF_DIR = "pending-handoffs" -- 287
MAX_CONCURRENT_SUB_AGENTS = 4 -- 288
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200 -- 289
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5 -- 290
activeStopTokens = {} -- 342
followup = { -- 345
	activeRuns = {}, -- 346
	pendingWakes = 0, -- 347
	configs = {}, -- 348
	recovered = {}, -- 349
	bindings = {}, -- 350
	publish = nil, -- 351
	recover = nil, -- 352
	delivered = nil, -- 353
	dispatch = nil, -- 354
	settle = nil, -- 355
	submit = nil -- 356
} -- 356
followup.publish = function(sessionId) -- 361
	emitAgentSessionPatch( -- 362
		sessionId, -- 362
		{session = getSessionItem(sessionId)} -- 362
	) -- 362
end -- 361
followup.recover = function(session) -- 364
	if followup.recovered[session.id] or followup.activeRuns[session.id] then -- 364
		return -- 365
	end -- 365
	followup.recovered[session.id] = true -- 366
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 367
	local history = storage:readSessionState().messages -- 368
	for ____, input in ipairs(InputInbox.listInputs(session.id)) do -- 369
		local message = __TS__ArrayFind( -- 370
			history, -- 370
			function(____, item) return item.inputId == input.id end -- 370
		) -- 370
		if message then -- 370
			followup.delivered(session.id, message.taskId or session.currentTaskId or 0, input.id, message.afterStep or 0) -- 371
		end -- 371
	end -- 371
	InputInbox.recoverInputs(session.id) -- 373
end -- 364
followup.delivered = function(sessionId, taskId, inputId, step) -- 375
	local input = InputInbox.getInput(sessionId, inputId) -- 376
	if not input or input.status == "delivered" then -- 376
		return -- 377
	end -- 377
	local receipt = queryOne("SELECT message_id FROM agent.AgentSessionInput WHERE id=?", {inputId}) -- 378
	local messageId = type(receipt and receipt[1]) == "number" and receipt[1] > 0 and receipt[1] or nil -- 379
	if not messageId then -- 379
		if not DB:transaction({ -- 379
			{ -- 382
				("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id,task_id,role,content,display_content,created_at,updated_at) VALUES(?,?,'user',?,'',?,?)", -- 382
				{{ -- 382
					sessionId, -- 382
					taskId, -- 382
					input.content, -- 382
					now(), -- 382
					now() -- 382
				}} -- 382
			}, -- 382
			{"UPDATE agent.AgentSessionInput SET message_id=last_insert_rowid(),delivered_step=?,status='delivered' WHERE id=?", {{step, inputId}}} -- 383
		}) then -- 383
			error( -- 384
				__TS__New(Error, "failed to commit input display"), -- 384
				0 -- 384
			) -- 384
		end -- 384
		local saved = queryOne("SELECT message_id FROM agent.AgentSessionInput WHERE id=?", {inputId}) -- 385
		messageId = saved and saved[1] -- 386
	else -- 386
		InputInbox.markDelivered(inputId, messageId, step) -- 387
	end -- 387
	__TS__Delete(followup.configs, inputId) -- 388
	emitAgentSessionPatch( -- 389
		sessionId, -- 389
		{ -- 389
			session = getSessionItem(sessionId), -- 389
			message = getMessageItem(messageId) -- 389
		} -- 389
	) -- 389
end -- 375
followup.dispatch = function(sessionId) -- 391
	local session = getSessionItem(sessionId) -- 392
	if not session or followup.activeRuns[sessionId] ~= nil or session.currentTaskFinalizing or getPendingQuestionnaire(sessionId) or isProjectTaskAdmissionClosed(session.projectRoot) or session.currentTaskStatus == "RUNNING" then -- 392
		return nil -- 394
	end -- 394
	local input = InputInbox.listInputs(sessionId)[1] -- 395
	if input == nil then -- 395
		__TS__Delete(followup.bindings, sessionId) -- 396
		return nil -- 396
	end -- 396
	if input.held or input.status ~= "pending" then -- 396
		return nil -- 397
	end -- 397
	local binding = followup.bindings[sessionId] -- 398
	if binding == nil then -- 398
		InputInbox.holdInputs(sessionId) -- 399
		followup.publish(sessionId) -- 399
		return nil -- 399
	end -- 399
	local options = input.options -- 400
	local result -- 401
	if type(options.localAgentConfigId) == "number" then -- 401
		result = startLocalPrompt(sessionId, input.content, options.localAgentConfigId, input.id) -- 403
	else -- 403
		local ____startImmediatePrompt_6 = startImmediatePrompt -- 405
		local ____array_5 = __TS__SparseArrayNew(sessionId, input.content, options.disabledAgentTools, options.workMode) -- 405
		local ____options_llmConfigId_4 = options.llmConfigId -- 406
		if ____options_llmConfigId_4 == nil then -- 406
			____options_llmConfigId_4 = binding.llmConfigId -- 406
		end -- 406
		__TS__SparseArrayPush( -- 406
			____array_5, -- 406
			____options_llmConfigId_4, -- 406
			followup.configs[input.id] or binding.llmConfig, -- 406
			options.maxSteps, -- 406
			input.id -- 406
		) -- 406
		result = ____startImmediatePrompt_6(__TS__SparseArraySpread(____array_5)) -- 405
	end -- 405
	if not result.success then -- 405
		InputInbox.holdInputs(sessionId) -- 408
		followup.publish(sessionId) -- 408
	end -- 408
	return result -- 409
end -- 391
followup.settle = function(sessionId, taskId, succeeded) -- 411
	if followup.activeRuns[sessionId] ~= taskId then -- 411
		return -- 412
	end -- 412
	__TS__Delete(followup.activeRuns, sessionId) -- 413
	if not succeeded then -- 413
		InputInbox.holdInputs(sessionId) -- 414
	else -- 414
		DB:exec("UPDATE agent.AgentSessionInput SET delivery='queue' WHERE session_id=? AND status='pending'", {sessionId}) -- 417
	end -- 417
	followup.publish(sessionId) -- 419
	if succeeded then -- 419
		followup.pendingWakes = followup.pendingWakes + 1 -- 421
		Director.systemScheduler:schedule(function() -- 422
			do -- 422
				local ____try, ____error = pcall(function() -- 422
					followup.dispatch(sessionId) -- 422
				end) -- 422
				do -- 422
					followup.pendingWakes = followup.pendingWakes - 1 -- 422
				end -- 422
				if not ____try then -- 422
					error(____error, 0) -- 422
				end -- 422
			end -- 422
			return true -- 422
		end) -- 422
	end -- 422
end -- 411
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId, submission) -- 430
	local ____opt_7 = getSessionItem(sessionId) -- 430
	if (____opt_7 and ____opt_7.kind) ~= "main" then -- 430
		return {success = false, message = "local Agent only supports main sessions"} -- 431
	end -- 431
	local id = tonumber(localAgentConfigId) -- 432
	if not id then -- 432
		return {success = false, message = "invalid local Agent config"} -- 433
	end -- 433
	return followup.submit( -- 434
		sessionId, -- 434
		prompt, -- 434
		{localAgentConfigId = id}, -- 434
		{localAgentConfigId = id}, -- 434
		submission -- 434
	) -- 434
end -- 430
followup.submit = function(sessionId, prompt, options, binding, submission) -- 436
	if submission ~= nil and type(submission) ~= "table" then -- 436
		return {success = false, message = "invalid input submission"} -- 437
	end -- 437
	local session = getSessionItem(sessionId) -- 438
	if not session then -- 438
		return {success = false, message = "session not found"} -- 439
	end -- 439
	if isProjectTaskAdmissionClosed(session.projectRoot) then -- 439
		return {success = false, message = "project task admission is closed"} -- 440
	end -- 440
	if session.kind ~= "main" then -- 440
		return startImmediatePrompt( -- 441
			sessionId, -- 441
			prompt, -- 441
			options.disabledAgentTools, -- 441
			options.workMode, -- 441
			options.llmConfigId, -- 441
			binding.llmConfig, -- 441
			options.maxSteps -- 441
		) -- 441
	end -- 441
	if (submission and submission.delivery) ~= nil and submission.delivery ~= "steer" and submission.delivery ~= "queue" then -- 441
		return {success = false, message = "invalid input delivery"} -- 442
	end -- 442
	if (submission and submission.requestId) ~= nil and (type(submission.requestId) ~= "string" or #submission.requestId > 128 or submission.requestId == "") then -- 442
		return {success = false, message = "invalid input request ID"} -- 443
	end -- 443
	do -- 443
		local function ____catch(____error) -- 443
			return true, { -- 492
				success = false, -- 492
				message = tostring(____error) -- 492
			} -- 492
		end -- 492
		local ____try, ____hasReturned, ____returnValue = pcall(function() -- 492
			followup.recover(session) -- 445
			followup.bindings[sessionId] = binding -- 446
			if submission and submission.action then -- 446
				if submission.action == "resume" and binding.llmConfig then -- 446
					for ____, item in ipairs(InputInbox.listInputs(sessionId)) do -- 449
						followup.configs[item.id] = binding.llmConfig -- 449
					end -- 449
				end -- 449
				InputInbox.mutateInput( -- 451
					sessionId, -- 451
					submission, -- 451
					normalizePromptTextSafe(prompt) -- 451
				) -- 451
				if submission.action == "cancel" and submission.inputId ~= nil then -- 451
					__TS__Delete(followup.configs, submission.inputId) -- 452
				end -- 452
				followup.publish(sessionId) -- 453
				local next = followup.dispatch(sessionId) -- 454
				return true, next or ({success = true, sessionId = sessionId, taskId = session.currentTaskId or 0}) -- 455
			end -- 455
			if getPendingQuestionnaire(sessionId) then -- 455
				return true, {success = false, message = "complete the pending questionnaire before sending another prompt"} -- 457
			end -- 457
			if binding.localAgentConfigId ~= nil then -- 457
				local config = LocalAgent.getConfig(binding.localAgentConfigId) -- 459
				if not (config and config.verifiedAt) then -- 459
					return true, {success = false, message = "local Agent config is not verified"} -- 460
				end -- 460
			else -- 460
				local resolved = binding.llmConfig and ({success = true, config = binding.llmConfig}) or getLLMConfig(binding.llmConfigId) -- 462
				if not resolved.success then -- 462
					return true, {success = false, message = resolved.message} -- 463
				end -- 463
				local valid = validateAgentLLMConfig(resolved.config) -- 464
				if not valid.success then -- 464
					return true, valid -- 465
				end -- 465
			end -- 465
			local content = normalizePromptTextSafe(prompt) -- 467
			if content == "" then -- 467
				return true, {success = false, message = "prompt is empty"} -- 468
			end -- 468
			local pending = InputInbox.listInputs(sessionId) -- 469
			if followup.activeRuns[sessionId] == nil and session.currentTaskStatus ~= "RUNNING" and not session.currentTaskFinalizing and #pending == 0 then -- 469
				return true, binding.localAgentConfigId ~= nil and startLocalPrompt(sessionId, content, binding.localAgentConfigId) or startImmediatePrompt( -- 474
					sessionId, -- 476
					content, -- 476
					options.disabledAgentTools, -- 476
					options.workMode, -- 476
					options.llmConfigId, -- 477
					binding.llmConfig, -- 477
					options.maxSteps -- 477
				) -- 477
			end -- 477
			local requestId = submission and submission.requestId or (((("input-" .. tostring(sessionId)) .. "-") .. tostring(os.time())) .. "-") .. tostring(math.random(1, 1000000000)) -- 479
			local ____temp_21 = followup.activeRuns[sessionId] ~= nil -- 480
			if ____temp_21 then -- 480
				local ____opt_19 = activeStopTokens[session.currentTaskId or -1] -- 480
				____temp_21 = not (____opt_19 and ____opt_19.stopped) -- 480
			end -- 480
			local isActive = ____temp_21 -- 480
			local delivery = content ~= "/clear" and content ~= "/compact" and isActive and not binding.localAgentConfigId and (submission and submission.delivery) == "steer" and "steer" or "queue" -- 481
			local wasPaused = __TS__ArraySome( -- 482
				pending, -- 482
				function(____, item) return item.held end -- 482
			) -- 482
			local ____InputInbox_admitInput_27 = InputInbox.admitInput -- 483
			local ____sessionId_25 = sessionId -- 483
			local ____options_26 = options -- 483
			local ____temp_24 -- 483
			if delivery == "steer" then -- 483
				____temp_24 = session.currentTaskId -- 483
			else -- 483
				____temp_24 = nil -- 483
			end -- 483
			local input = ____InputInbox_admitInput_27( -- 483
				____sessionId_25, -- 483
				content, -- 483
				delivery, -- 483
				requestId, -- 483
				____options_26, -- 483
				____temp_24 -- 483
			) -- 483
			if wasPaused and delivery == "queue" then -- 483
				InputInbox.holdInputs(sessionId) -- 484
			end -- 484
			if input.status == "delivered" or input.status == "cancelled" then -- 484
				return true, {success = true, sessionId = sessionId, taskId = input.taskId or session.currentTaskId or 0} -- 485
			end -- 485
			if binding.llmConfig then -- 485
				followup.configs[input.id] = binding.llmConfig -- 486
			end -- 486
			local next = followup.dispatch(sessionId) -- 487
			if not next then -- 487
				followup.publish(sessionId) -- 490
			end -- 490
			return true, next or ({success = true, sessionId = sessionId, taskId = session.currentTaskId or 0}) -- 491
		end) -- 491
		if not ____try then -- 491
			____hasReturned, ____returnValue = ____catch(____hasReturned) -- 491
		end -- 491
		if ____hasReturned then -- 491
			return ____returnValue -- 444
		end -- 444
	end -- 444
end -- 436
activeLocalAgentControls = {} -- 494
finalizingSubSessionTaskIds = {} -- 495
activePromptRuns = 0 -- 496
streamUpdates = __TS__New( -- 498
	StreamUpdates, -- 498
	function(sessionId, taskId, step, value) -- 498
		local ____opt_28 = getSessionItem(sessionId) -- 498
		if (____opt_28 and ____opt_28.currentTaskId) ~= taskId then -- 498
			return -- 499
		end -- 499
		upsertStep( -- 500
			sessionId, -- 500
			taskId, -- 500
			step, -- 500
			"message", -- 500
			{status = "RUNNING", reason = value.content, reasoningContent = value.reasoningContent} -- 500
		) -- 500
		emitAgentSessionPatch( -- 503
			sessionId, -- 503
			{step = getStepItem(sessionId, taskId, step)} -- 503
		) -- 503
	end -- 498
) -- 498
streamFlushScheduled = false -- 505
--- Runtime ownership, including asynchronous completion after task status changes.
function ____exports.isRuntimeIdle() -- 518
	return followup.pendingWakes == 0 and activePromptRuns == 0 and #__TS__ObjectKeys(activeStopTokens) == 0 and #__TS__ObjectKeys(activeLocalAgentControls) == 0 and #__TS__ObjectKeys(finalizingSubSessionTaskIds) == 0 -- 519
end -- 518
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode" -- 524
now = function() return os.time() end -- 525
local function getTaskPrompt(taskId) -- 1045
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId}) -- 1046
	if not row or type(row[1]) ~= "string" then -- 1046
		return nil -- 1047
	end -- 1047
	return toStr(row[1]) -- 1048
end -- 1045
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 1197
	if projectRoot == oldRoot then -- 1197
		return newRoot -- 1199
	end -- 1199
	for ____, separator in ipairs({"/", "\\"}) do -- 1201
		local prefix = oldRoot .. separator -- 1202
		if __TS__StringStartsWith(projectRoot, prefix) then -- 1202
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot) -- 1204
		end -- 1204
	end -- 1204
	return nil -- 1207
end -- 1197
handoffs = { -- 1427
	dir = function(self, projectRoot, memoryScope) -- 1428
		return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR) -- 1429
	end, -- 1428
	write = function(self, projectRoot, memoryScope, value) -- 1431
		local dir = handoffs:dir(projectRoot, memoryScope) -- 1432
		if not Content:exist(dir) then -- 1432
			ensureDirRecursive(dir) -- 1434
		end -- 1434
		local path = Path(dir, value.id .. ".json") -- 1436
		if Content:exist(path) then -- 1436
			return true -- 1437
		end -- 1437
		local sequence = 1 -- 1438
		for ____, pending in ipairs(handoffs:list(projectRoot, memoryScope)) do -- 1439
			sequence = math.max(sequence, (pending.sequence or 0) + 1) -- 1440
		end -- 1440
		local text = safeJsonEncode(__TS__ObjectAssign({}, value, {sequence = sequence})) -- 1442
		if not text then -- 1442
			return false -- 1443
		end -- 1443
		local content = text .. "\n" -- 1444
		local tempPath = path .. ".tmp" -- 1445
		if not Content:save(tempPath, content) or not Content:move(tempPath, path) then -- 1445
			Content:remove(tempPath) -- 1447
			return false -- 1448
		end -- 1448
		Tools.sendWebIDEFileUpdate(path, true, content) -- 1450
		return true -- 1451
	end, -- 1431
	list = function(self, projectRoot, memoryScope) -- 1453
		local dir = handoffs:dir(projectRoot, memoryScope) -- 1454
		if not Content:exist(dir) or not Content:isdir(dir) then -- 1454
			return {} -- 1455
		end -- 1455
		local items = {} -- 1456
		for ____, rawPath in ipairs(Content:getFiles(dir)) do -- 1457
			do -- 1457
				local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath) -- 1458
				if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then -- 1458
					goto __continue303 -- 1459
				end -- 1459
				local text = Content:load(path) -- 1460
				if type(text) ~= "string" or __TS__StringTrim(text) == "" then -- 1460
					goto __continue303 -- 1461
				end -- 1461
				local obj = safeJsonDecode(text) -- 1462
				if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then -- 1462
					goto __continue303 -- 1463
				end -- 1463
				local value = obj -- 1464
				local sourceTaskId = tonumber(value.sourceTaskId) -- 1465
				local sourceSessionId = tonumber(value.sourceSessionId) -- 1466
				local id = sanitizeUTF8(toStr(value.id)) -- 1467
				local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle)) -- 1468
				local message = sanitizeUTF8(toStr(value.message)) -- 1469
				local prompt = sanitizeUTF8(toStr(value.prompt)) -- 1470
				local goal = sanitizeUTF8(toStr(value.goal)) -- 1471
				local createdAt = sanitizeUTF8(toStr(value.createdAt)) -- 1472
				if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or Path:getFilename(path) ~= id .. ".json" or createdAt == "" then -- 1472
					goto __continue303 -- 1475
				end -- 1475
				local ____id_66 = id -- 1478
				local ____sourceSessionId_67 = sourceSessionId -- 1479
				local ____sourceTitle_68 = sourceTitle -- 1480
				local ____sourceTaskId_69 = sourceTaskId -- 1481
				local ____message_70 = message -- 1482
				local ____prompt_71 = prompt -- 1483
				local ____goal_72 = goal -- 1484
				local ____sanitizeUTF8_result_73 = sanitizeUTF8(toStr(value.expectedOutput)) -- 1485
				local ____temp_74 = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap( -- 1486
					__TS__ArrayFilter( -- 1487
						value.filesHint, -- 1487
						function(____, item) return type(item) == "string" end -- 1487
					), -- 1487
					function(____, item) return sanitizeUTF8(item) end -- 1487
				) or ({}) -- 1487
				local ____temp_75 = value.success == true -- 1489
				local ____temp_65 -- 1490
				if value.status == "DONE" or value.status == "STOPPED" or value.status == "FAILED" then -- 1490
					____temp_65 = value.status -- 1490
				else -- 1490
					____temp_65 = nil -- 1490
				end -- 1490
				items[#items + 1] = { -- 1477
					id = ____id_66, -- 1478
					sourceSessionId = ____sourceSessionId_67, -- 1479
					sourceTitle = ____sourceTitle_68, -- 1480
					sourceTaskId = ____sourceTaskId_69, -- 1481
					message = ____message_70, -- 1482
					prompt = ____prompt_71, -- 1483
					goal = ____goal_72, -- 1484
					expectedOutput = ____sanitizeUTF8_result_73, -- 1485
					filesHint = ____temp_74, -- 1486
					success = ____temp_75, -- 1489
					status = ____temp_65, -- 1490
					resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)), -- 1491
					artifactDir = sanitizeUTF8(toStr(value.artifactDir)), -- 1492
					finishedAt = sanitizeUTF8(toStr(value.finishedAt)), -- 1493
					changeSet = decodeChangeSetSummary(value.changeSet), -- 1494
					handoffEvidence = decodeHandoffEvidence(value.handoffEvidence), -- 1495
					memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry), -- 1496
					completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil, -- 1497
					createdAt = createdAt, -- 1500
					sequence = type(value.sequence) == "number" and value.sequence or nil -- 1501
				} -- 1501
			end -- 1501
			::__continue303:: -- 1501
		end -- 1501
		__TS__ArraySort( -- 1504
			items, -- 1504
			function(____, a, b) -- 1504
				local bySequence = (a.sequence or 0) - (b.sequence or 0) -- 1505
				if bySequence ~= 0 then -- 1505
					return bySequence -- 1506
				end -- 1506
				local left = (a.createdAt .. ":") .. a.id -- 1507
				local right = (b.createdAt .. ":") .. b.id -- 1508
				return left < right and -1 or (left > right and 1 or 0) -- 1509
			end -- 1504
		) -- 1504
		return items -- 1511
	end, -- 1453
	remove = function(self, projectRoot, memoryScope, id) -- 1513
		local path = Path( -- 1514
			handoffs:dir(projectRoot, memoryScope), -- 1514
			id .. ".json" -- 1514
		) -- 1514
		if Content:exist(path) then -- 1514
			if Content:remove(path) then -- 1514
				Tools.sendWebIDEFileUpdate(path, false, "") -- 1517
			end -- 1517
		end -- 1517
	end, -- 1513
	receipt = function(self, session, id, sink) -- 1521
		return Path( -- 1522
			handoffs:dir(session.projectRoot, session.memoryScope), -- 1522
			(id .. ".") .. sink -- 1522
		) -- 1522
	end, -- 1521
	mark = function(self, session, id, sink) -- 1524
		local receipt = handoffs:receipt(session, id, sink) -- 1525
		if not Content:exist(receipt) and not Content:save(receipt, "delivered") then -- 1525
			return false -- 1526
		end -- 1526
		local model = handoffs:receipt(session, id, "model") -- 1527
		local timeline = handoffs:receipt(session, id, "timeline") -- 1528
		if Content:exist(model) and Content:exist(timeline) then -- 1528
			handoffs:remove(session.projectRoot, session.memoryScope, id) -- 1530
			local path = Path( -- 1531
				handoffs:dir(session.projectRoot, session.memoryScope), -- 1531
				id .. ".json" -- 1531
			) -- 1531
			if not Content:exist(path) then -- 1531
				Content:remove(model) -- 1533
				Content:remove(timeline) -- 1534
			end -- 1534
		end -- 1534
		return true -- 1537
	end, -- 1524
	pending = function(self, session) -- 1539
		return __TS__ArrayMap( -- 1540
			__TS__ArrayFilter( -- 1540
				handoffs:list(session.projectRoot, session.memoryScope), -- 1540
				function(____, item) return not Content:exist(handoffs:receipt(session, item.id, "model")) end -- 1541
			), -- 1541
			function(____, item) -- 1542
				local ____encodeJson_110 = encodeJson -- 1543
				local ____item_sourceSessionId_104 = item.sourceSessionId -- 1544
				local ____item_sourceTaskId_105 = item.sourceTaskId -- 1545
				local ____clipTextToTokenBudget_result_106 = clipTextToTokenBudget(item.sourceTitle, 64) -- 1546
				local ____item_status_79 = item.status -- 1547
				if ____item_status_79 == nil then -- 1547
					local ____temp_78 -- 1547
					if item.success == true then -- 1547
						____temp_78 = "DONE" -- 1547
					else -- 1547
						local ____opt_76 = item.completion -- 1547
						____temp_78 = (____opt_76 and ____opt_76.outcome) == "partial" and "STOPPED" or "FAILED" -- 1547
					end -- 1547
					____item_status_79 = ____temp_78 -- 1547
				end -- 1547
				local ____opt_80 = item.completion -- 1547
				local ____temp_107 = ____opt_80 and ____opt_80.outcome -- 1548
				local ____clipTextToTokenBudget_result_108 = clipTextToTokenBudget(item.message, 450) -- 1549
				local ____opt_82 = item.handoffEvidence -- 1549
				if ____opt_82 ~= nil then -- 1549
					local ____opt_83 = item.handoffEvidence -- 1549
					if ____opt_83 ~= nil then -- 1549
						local ____opt_84 = item.handoffEvidence -- 1549
						____opt_83 = __TS__ArraySlice(____opt_84 and ____opt_84.modifiedFiles, 0, 8) -- 1549
					end -- 1549
					____opt_82 = __TS__ArrayMap( -- 1549
						____opt_83, -- 1549
						function(____, path) return clipTextToTokenBudget(path, 64) end -- 1551
					) -- 1551
				end -- 1551
				local ____opt_90 = item.handoffEvidence -- 1551
				local ____opt_88 = ____opt_90 and ____opt_90.lastBuild -- 1551
				local ____temp_109 = ____opt_88 and ____opt_88.result -- 1552
				local ____opt_92 = item.completion -- 1552
				if ____opt_92 ~= nil then -- 1552
					local ____opt_93 = item.completion -- 1552
					if ____opt_93 ~= nil then -- 1552
						local ____opt_94 = item.completion -- 1552
						____opt_93 = __TS__ArraySlice(____opt_94 and ____opt_94.validation, 0, 5) -- 1552
					end -- 1552
					____opt_92 = __TS__ArrayMap( -- 1552
						____opt_93, -- 1552
						function(____, entry) return { -- 1553
							kind = entry.kind, -- 1554
							result = entry.result, -- 1555
							evidence = __TS__ArrayMap( -- 1556
								__TS__ArraySlice(entry.evidence, 0, 2), -- 1556
								function(____, text) return clipTextToTokenBudget(text, 64) end -- 1556
							) -- 1556
						} end -- 1556
					) -- 1556
				end -- 1556
				local ____opt_98 = item.completion -- 1556
				if ____opt_98 ~= nil then -- 1556
					local ____opt_99 = item.completion -- 1556
					if ____opt_99 ~= nil then -- 1556
						local ____opt_100 = item.completion -- 1556
						____opt_99 = __TS__ArraySlice(____opt_100 and ____opt_100.knownIssues, 0, 4) -- 1556
					end -- 1556
					____opt_98 = __TS__ArrayMap( -- 1556
						____opt_99, -- 1556
						function(____, text) return clipTextToTokenBudget(text, 80) end -- 1558
					) -- 1558
				end -- 1558
				local result = table.concat( -- 1543
					__TS__StringSplit( -- 1543
						____encodeJson_110({ -- 1543
							sourceSessionId = ____item_sourceSessionId_104, -- 1544
							sourceTaskId = ____item_sourceTaskId_105, -- 1545
							title = ____clipTextToTokenBudget_result_106, -- 1546
							status = ____item_status_79, -- 1547
							outcome = ____temp_107, -- 1548
							summary = ____clipTextToTokenBudget_result_108, -- 1549
							changedFiles = ____opt_82, -- 1550
							lastBuild = ____temp_109, -- 1552
							validation = ____opt_92, -- 1553
							openIssues = ____opt_98, -- 1558
							resultFilePath = item.resultFilePath -- 1559
						}), -- 1559
						"<" -- 1560
					), -- 1560
					"\\u003c" -- 1560
				) -- 1560
				return { -- 1561
					id = (("sub_" .. tostring(item.sourceSessionId)) .. "_") .. tostring(item.sourceTaskId), -- 1562
					queueId = item.id, -- 1563
					content = ("<sub-agent-handoff>\n" .. result) .. "\n</sub-agent-handoff>" -- 1564
				} -- 1564
			end -- 1542
		) -- 1542
	end, -- 1539
	timelinePublished = function(self, session, item) -- 1568
		if not Content:exist(handoffs:receipt(session, item.id, "timeline")) and not handoffs:hasTimelineStep(session.id, item.sourceTaskId) then -- 1568
			return false -- 1570
		end -- 1570
		if not handoffs:mark(session, item.id, "timeline") then -- 1570
			Log("Warn", "[AgentSession] failed to acknowledge sub-agent handoff timeline id=" .. item.id) -- 1572
		end -- 1572
		return true -- 1574
	end, -- 1568
	hasTimelineStep = function(self, sessionId, sourceTaskId) -- 1576
		return queryOne(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND tool = 'sub_agent_handoff'\n\t\t\t\tAND json_extract(result_json, '$.sourceTaskId') = ?\n\t\t\tLIMIT 1", {sessionId, sourceTaskId}) ~= nil -- 1577
	end -- 1576
} -- 1576
local function clearSessionAfterMessage(sessionId, message) -- 1820
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({}) -- 1821
	local removedStepIds = {} -- 1829
	do -- 1829
		local i = 0 -- 1830
		while i < #removedStepRows do -- 1830
			local row = removedStepRows[i + 1] -- 1831
			if type(row[1]) == "number" then -- 1831
				removedStepIds[#removedStepIds + 1] = row[1] -- 1833
			end -- 1833
			i = i + 1 -- 1830
		end -- 1830
	end -- 1830
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) -- 1836
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id}) -- 1844
	return removedStepIds -- 1849
end -- 1820
local function truncatePersistedSessionBeforeLatestUserPrompt(session) -- 1852
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 1853
	local persisted = storage:readSessionState() -- 1854
	local userIndex = -1 -- 1855
	do -- 1855
		local i = #persisted.messages - 1 -- 1856
		while i >= 0 do -- 1856
			if isTaskInstruction(persisted.messages[i + 1]) then -- 1856
				userIndex = i -- 1858
				break -- 1859
			end -- 1859
			i = i - 1 -- 1856
		end -- 1856
	end -- 1856
	if userIndex < 0 then -- 1856
		return -- 1862
	end -- 1862
	local ____array_117 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(persisted.messages, 0, userIndex))) -- 1862
	__TS__SparseArrayPush( -- 1862
		____array_117, -- 1862
		table.unpack(__TS__ArrayFilter( -- 1865
			__TS__ArraySlice(persisted.messages, userIndex + 1), -- 1865
			function(____, message) return message.handoffId ~= nil end -- 1865
		)) -- 1865
	) -- 1865
	local messages = {__TS__SparseArraySpread(____array_117)} -- 1863
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, userIndex) -- 1867
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 1868
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 1873
end -- 1852
local function listCurrentTaskCheckpoints(sessionId) -- 1885
	local session = getSessionItem(sessionId) -- 1886
	local taskId = session and session.currentTaskId -- 1887
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({}) -- 1888
end -- 1885
local function getAgentStepCount(sessionId, taskId) -- 1995
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", { -- 1996
		sessionId, -- 2001
		taskId, -- 2002
		"compress_memory", -- 2003
		"merge_memory", -- 2004
		"sub_agent_handoff", -- 2005
		"questionnaire_answer", -- 2006
		"message" -- 2007
	}) -- 2007
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0 -- 2010
end -- 1995
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status) -- 2013
	if status == nil then -- 2013
		status = "DONE" -- 2021
	end -- 2021
	local step = getNextStepNumber(sessionId, taskId) -- 2023
	upsertStep( -- 2024
		sessionId, -- 2024
		taskId, -- 2024
		step, -- 2024
		tool, -- 2024
		{status = status, reason = reason, params = params, result = result} -- 2024
	) -- 2024
	return getStepItem(sessionId, taskId, step) -- 2030
end -- 2013
local function sanitizeStoredSteps(sessionId) -- 2097
	DB:exec( -- 2098
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'", -- 2098
		{ -- 2116
			now(), -- 2116
			sessionId -- 2116
		} -- 2116
	) -- 2116
end -- 2097
function ____exports.deleteSessionsByProjectRoot(projectRoot) -- 2582
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then -- 2582
		return {success = false, message = "invalid projectRoot"} -- 2584
	end -- 2584
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({}) -- 2586
	for ____, row in ipairs(rows) do -- 2587
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2588
		if sessionId > 0 then -- 2588
			deleteSessionRecords(sessionId) -- 2590
		end -- 2590
	end -- 2590
	return {success = true, deleted = #rows} -- 2593
end -- 2582
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot) -- 2596
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then -- 2596
		return {success = false, message = "invalid projectRoot"} -- 2598
	end -- 2598
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({}) -- 2600
	local renamed = 0 -- 2601
	for ____, row in ipairs(rows) do -- 2602
		local sessionId = type(row[1]) == "number" and row[1] or 0 -- 2603
		local projectRoot = toStr(row[2]) -- 2604
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot) -- 2605
		if sessionId > 0 and nextProjectRoot then -- 2605
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId -- 2607
			DB:exec( -- 2608
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?", -- 2608
				{ -- 2610
					nextProjectRoot, -- 2610
					Path:getFilename(nextProjectRoot), -- 2610
					now(), -- 2610
					sessionId -- 2610
				} -- 2610
			) -- 2610
			renamed = renamed + 1 -- 2612
		end -- 2612
	end -- 2612
	return {success = true, renamed = renamed} -- 2615
end -- 2596
function ____exports.getSession(sessionId, view) -- 2618
	local session = getSessionItem(sessionId) -- 2619
	if not session then -- 2619
		return {success = false, message = "session not found"} -- 2621
	end -- 2621
	if followup.activeRuns[sessionId] == nil then -- 2621
		followup.recover(session) -- 2623
	end -- 2623
	local restored = restorePendingQuestionnaireState(session) -- 2624
	local normalizedSession = normalizeSessionRuntimeState(restored.session) -- 2625
	local ____opt_145 = getSessionItem(sessionId) -- 2625
	normalizedSession.pendingInputs = ____opt_145 and ____opt_145.pendingInputs -- 2626
	local relatedSessions = listRelatedSessions(sessionId) -- 2627
	sanitizeStoredSteps(sessionId) -- 2628
	local firstMessageId = 0 -- 2629
	local hasEarlierMessages = false -- 2630
	if view then -- 2630
		local limit = math.max( -- 2632
			1, -- 2632
			math.min( -- 2632
				1000, -- 2632
				math.floor(view.recentRounds) -- 2632
			) -- 2632
		) -- 2632
		local requests = queryRows(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m WHERE m.session_id = ? AND m.role = 'user'\n    AND NOT EXISTS (SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n\t\t\tORDER BY m.id DESC LIMIT ?", {sessionId, limit + 1}) or ({}) -- 2633
		if #requests > limit then -- 2633
			firstMessageId = requests[limit][1] -- 2639
			hasEarlierMessages = true -- 2640
		end -- 2640
	end -- 2640
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({}) -- 2643
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({}) -- 2650
	local ____relatedSessions_152 = relatedSessions -- 2662
	local ____temp_151 -- 2663
	if normalizedSession.kind == "sub" then -- 2663
		____temp_151 = getSessionSpawnInfo(normalizedSession) -- 2663
	else -- 2663
		____temp_151 = nil -- 2663
	end -- 2663
	return { -- 2659
		success = true, -- 2660
		session = normalizedSession, -- 2661
		relatedSessions = ____relatedSessions_152, -- 2662
		spawnInfo = ____temp_151, -- 2663
		messages = __TS__ArrayMap( -- 2664
			messages, -- 2664
			function(____, row) return rowToMessage(row) end -- 2664
		), -- 2664
		hasEarlierMessages = hasEarlierMessages, -- 2665
		steps = __TS__ArrayMap( -- 2666
			steps, -- 2666
			function(____, row) return rowToStep(row) end -- 2666
		), -- 2666
		checkpoints = listCurrentTaskCheckpoints(sessionId), -- 2667
		pendingQuestionnaire = restored.questionnaire, -- 2668
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE)) -- 2669
	} -- 2669
end -- 2618
function ____exports.setWorkMode(sessionId, workMode) -- 2674
	local session = getSessionItem(sessionId) -- 2675
	if not session then -- 2675
		return {success = false, message = "session not found"} -- 2676
	end -- 2676
	if session.kind ~= "main" then -- 2676
		return {success = false, message = "Plan mode is only available for main sessions"} -- 2677
	end -- 2677
	if workMode ~= "code" and workMode ~= "plan" then -- 2677
		return {success = false, message = "invalid work mode"} -- 2678
	end -- 2678
	local normalizedSession = normalizeSessionRuntimeState(session) -- 2679
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then -- 2679
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"} -- 2681
	end -- 2681
	if getPendingQuestionnaire(sessionId) then -- 2681
		return {success = false, message = "complete the pending questionnaire before changing work mode"} -- 2684
	end -- 2684
	if normalizedSession.workMode ~= workMode then -- 2684
		DB:exec( -- 2687
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 2687
			{ -- 2687
				workMode, -- 2687
				now(), -- 2687
				sessionId -- 2687
			} -- 2687
		) -- 2687
	end -- 2687
	local updated = getSessionItem(sessionId) -- 2689
	emitAgentSessionPatch(sessionId, {session = updated}) -- 2690
	return { -- 2691
		success = true, -- 2691
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode}) -- 2691
	} -- 2691
end -- 2674
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId, llmConfig) -- 2993
	local session = getSessionItem(sessionId) -- 2994
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 2994
		return {success = false, message = "project task admission is closed"} -- 2995
	end -- 2995
	if not session then -- 2995
		return {success = false, message = "session not found"} -- 2997
	end -- 2997
	if getPendingQuestionnaire(sessionId) then -- 2997
		return {success = false, message = "complete the pending questionnaire before continuing"} -- 2999
	end -- 2999
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 2999
		return {success = false, message = "session task is finalizing"} -- 3001
	end -- 3001
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 3001
		return {success = false, message = "session task is still stopping"} -- 3004
	end -- 3004
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then -- 3004
		return {success = false, message = "session task is not continuable"} -- 3007
	end -- 3007
	if session.currentTaskId == nil then -- 3007
		return {success = false, message = "session task not found"} -- 3010
	end -- 3010
	local resolved = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3012
	if not resolved.success then -- 3012
		return {success = false, message = resolved.message} -- 3013
	end -- 3013
	followup.recover(session) -- 3014
	local previousBinding = followup.bindings[sessionId] -- 3015
	followup.bindings[sessionId] = {llmConfig = resolved.config, llmConfigId = llmConfigId} -- 3016
	local taskId = session.currentTaskId -- 3017
	local result = startPromptTask( -- 3018
		session, -- 3019
		"", -- 3020
		nil, -- 3021
		normalizeDisabledAgentTools(disabledAgentTools), -- 3022
		{ -- 3023
			workMode = session.workMode, -- 3024
			persistUserMessage = false, -- 3025
			resumeConversation = true, -- 3026
			existingTaskId = taskId, -- 3027
			initialStep = math.max( -- 3028
				0, -- 3028
				getNextStepNumber(session.id, taskId) - 1 -- 3028
			), -- 3028
			initialAgentStepCount = 0, -- 3032
			llmConfigId = llmConfigId, -- 3033
			llmConfig = resolved.config -- 3034
		} -- 3034
	) -- 3034
	if result.success then -- 3034
		for ____, input in ipairs(InputInbox.listInputs(sessionId)) do -- 3040
			followup.configs[input.id] = resolved.config -- 3040
		end -- 3040
		InputInbox.mutateInput(sessionId, {action = "resume"}, "") -- 3041
		followup.publish(sessionId) -- 3042
	elseif previousBinding ~= nil then -- 3042
		followup.bindings[sessionId] = previousBinding -- 3043
	else -- 3043
		__TS__Delete(followup.bindings, sessionId) -- 3044
	end -- 3044
	return result -- 3045
end -- 2993
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId) -- 3231
	local session = getSessionItem(sessionId) -- 3232
	if not session then -- 3232
		return {success = false, message = "session not found"} -- 3234
	end -- 3234
	if session.kind ~= "sub" then -- 3234
		return {success = false, message = "only sub-agent sessions can be ended with handoff"} -- 3237
	end -- 3237
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3237
		return {success = false, message = "session task is finalizing"} -- 3240
	end -- 3240
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3242
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then -- 3242
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"} -- 3247
	end -- 3247
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then -- 3247
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"} -- 3250
	end -- 3250
	local disabledAgentTools = AgentToolRegistry.getAllowedToolsForRole("sub") -- 3252
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并给出最终总结。不要再调用任何工具；用纯文本如实总结已完成内容、文件变更、验证状态和剩余问题。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Use plain text only, without tools, to summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete." -- 3253
	return startPromptTask( -- 3256
		session, -- 3256
		prompt, -- 3256
		nil, -- 3256
		disabledAgentTools, -- 3256
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId} -- 3256
	) -- 3256
end -- 3231
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId) -- 3263
	local session = getSessionItem(sessionId) -- 3264
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3264
		return {success = false, message = "project task admission is closed"} -- 3265
	end -- 3265
	if not session then -- 3265
		return {success = false, message = "session not found"} -- 3267
	end -- 3267
	if #InputInbox.listInputs(sessionId) > 0 then -- 3267
		return {success = false, message = "finish or remove pending messages before editing task history"} -- 3269
	end -- 3269
	if getPendingQuestionnaire(sessionId) then -- 3269
		return {success = false, message = "complete the pending questionnaire before resending a prompt"} -- 3270
	end -- 3270
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3270
		return {success = false, message = "session task is finalizing"} -- 3272
	end -- 3272
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then -- 3272
		return {success = false, message = "session task is still running"} -- 3275
	end -- 3275
	local message = getMessageItem(messageId) -- 3277
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then -- 3277
		return {success = false, message = "message not found"} -- 3279
	end -- 3279
	local latestUserRow = queryOne(("SELECT m.id FROM " .. TABLE_MESSAGE) .. " AS m\n  WHERE m.session_id = ? AND m.role = ? AND NOT EXISTS (\n   SELECT 1 FROM agent.AgentSessionInput i WHERE i.message_id=m.id AND i.delivery='steer')\n  ORDER BY m.id DESC LIMIT 1", {sessionId, "user"}) -- 3281
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0 -- 3288
	if latestUserMessageId ~= messageId then -- 3288
		return {success = false, message = "only the latest user prompt can be edited"} -- 3290
	end -- 3290
	local normalizedPrompt = normalizePromptTextSafe(prompt) -- 3292
	if normalizedPrompt == "" then -- 3292
		return {success = false, message = "prompt is empty"} -- 3294
	end -- 3294
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code" -- 3296
	if session.workMode ~= nextWorkMode then -- 3296
		DB:exec( -- 3298
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?", -- 3298
			{ -- 3298
				nextWorkMode, -- 3298
				now(), -- 3298
				session.id -- 3298
			} -- 3298
		) -- 3298
		session.workMode = nextWorkMode -- 3299
	end -- 3299
	local removedStepIds = clearSessionAfterMessage(sessionId, message) -- 3301
	truncatePersistedSessionBeforeLatestUserPrompt(session) -- 3302
	local result = startPromptTask( -- 3303
		session, -- 3303
		normalizedPrompt, -- 3303
		messageId, -- 3303
		normalizeDisabledAgentTools(disabledAgentTools), -- 3303
		{workMode = nextWorkMode, llmConfigId = llmConfigId} -- 3303
	) -- 3303
	if result.success and #removedStepIds > 0 then -- 3303
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds}) -- 3305
	end -- 3305
	return result -- 3307
end -- 3263
local function buildQuestionnaireResumeQuery(questionnaire, answers, status) -- 3312
	if status == "dismissed" then -- 3312
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。" -- 3318
	end -- 3318
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers) -- 3320
end -- 3312
local function buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3323
	if status == "dismissed" then -- 3323
		return { -- 3329
			success = true, -- 3330
			status = "dismissed", -- 3331
			source = "user", -- 3332
			questionnaireId = questionnaire.id, -- 3333
			title = questionnaire.schema.title, -- 3334
			answers = {}, -- 3335
			responses = {}, -- 3336
			displayText = "用户关闭了调查问卷，未作答。", -- 3337
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress." -- 3338
		} -- 3338
	end -- 3338
	local responses = {} -- 3341
	do -- 3341
		local i = 0 -- 3342
		while i < #questionnaire.schema.questions do -- 3342
			do -- 3342
				local question = questionnaire.schema.questions[i + 1] -- 3343
				local answer = __TS__ArrayFind( -- 3344
					answers, -- 3344
					function(____, item) return item.questionId == question.id end -- 3344
				) -- 3344
				if not answer or answer.status == "skipped" then -- 3344
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"} -- 3346
					goto __continue602 -- 3351
				end -- 3351
				local selectedOptionLabels = {} -- 3353
				do -- 3353
					local j = 0 -- 3354
					while j < #(answer.selectedOptionIds or ({})) do -- 3354
						local optionId = (answer.selectedOptionIds or ({}))[j + 1] -- 3355
						local option = __TS__ArrayFind( -- 3356
							question.options or ({}), -- 3356
							function(____, item) return item.id == optionId end -- 3356
						) -- 3356
						if option then -- 3356
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label -- 3357
						end -- 3357
						j = j + 1 -- 3354
					end -- 3354
				end -- 3354
				responses[#responses + 1] = { -- 3359
					questionId = question.id, -- 3360
					prompt = question.prompt, -- 3361
					status = "answered", -- 3362
					selectedOptionIds = answer.selectedOptionIds or ({}), -- 3363
					selectedOptionLabels = selectedOptionLabels, -- 3364
					otherText = answer.otherText, -- 3365
					text = answer.text -- 3366
				} -- 3366
			end -- 3366
			::__continue602:: -- 3366
			i = i + 1 -- 3342
		end -- 3342
	end -- 3342
	return { -- 3369
		success = true, -- 3370
		status = "answered", -- 3371
		source = "user", -- 3372
		questionnaireId = questionnaire.id, -- 3373
		title = questionnaire.schema.title, -- 3374
		answers = answers, -- 3375
		responses = responses, -- 3376
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers), -- 3377
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved." -- 3378
	} -- 3378
end -- 3323
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status) -- 3404
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope) -- 3410
	local persisted = storage:readSessionState() -- 3411
	local messages = __TS__ArraySlice(persisted.messages) -- 3412
	local toolResultIndex = -1 -- 3413
	local existingResult -- 3414
	do -- 3414
		local i = #messages - 1 -- 3415
		while i >= 0 do -- 3415
			do -- 3415
				local message = messages[i + 1] -- 3416
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then -- 3416
					goto __continue622 -- 3417
				end -- 3417
				local decoded = safeJsonDecode(message.content) -- 3418
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then -- 3418
					goto __continue622 -- 3419
				end -- 3419
				local row = decoded -- 3420
				if row.questionnaireId ~= questionnaire.id then -- 3420
					goto __continue622 -- 3421
				end -- 3421
				toolResultIndex = i -- 3422
				existingResult = row -- 3423
				break -- 3424
			end -- 3424
			::__continue622:: -- 3424
			i = i - 1 -- 3415
		end -- 3415
	end -- 3415
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status) -- 3426
	local guidance = {} -- 3427
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then -- 3427
		guidance[#guidance + 1] = existingResult.guidance -- 3429
	end -- 3429
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then -- 3429
		guidance[#guidance + 1] = result.guidance -- 3432
	end -- 3432
	result.guidance = table.concat(guidance, "\n") -- 3434
	if toolResultIndex < 0 then -- 3434
		messages[#messages + 1] = { -- 3436
			role = "user", -- 3437
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result) -- 3438
		} -- 3438
		toolResultIndex = #messages - 1 -- 3440
	else -- 3440
		messages[toolResultIndex + 1] = __TS__ObjectAssign( -- 3442
			{}, -- 3442
			messages[toolResultIndex + 1], -- 3443
			{content = encodeJson(result)} -- 3442
		) -- 3442
	end -- 3442
	local pairStartIndex = toolResultIndex -- 3448
	local toolCallId = messages[toolResultIndex + 1].tool_call_id -- 3449
	if toolCallId and toolCallId ~= "" then -- 3449
		do -- 3449
			local i = toolResultIndex - 1 -- 3451
			while i >= 0 do -- 3451
				do -- 3451
					local message = messages[i + 1] -- 3452
					if message.role ~= "assistant" or not message.tool_calls then -- 3452
						goto __continue632 -- 3453
					end -- 3453
					if __TS__ArraySome( -- 3453
						message.tool_calls, -- 3454
						function(____, call) return call.id == toolCallId end -- 3454
					) then -- 3454
						pairStartIndex = i -- 3455
						break -- 3456
					end -- 3456
				end -- 3456
				::__continue632:: -- 3456
				i = i - 1 -- 3451
			end -- 3451
		end -- 3451
	end -- 3451
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex -- 3460
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil -- 3463
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex) -- 3467
	upsertStep( -- 3469
		session.id, -- 3469
		questionnaire.taskId, -- 3469
		questionnaire.step, -- 3469
		"ask_user", -- 3469
		{status = "DONE", result = result} -- 3469
	) -- 3469
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId) -- 3473
	upsertStep( -- 3474
		session.id, -- 3474
		questionnaire.taskId, -- 3474
		answerStep, -- 3474
		"questionnaire_answer", -- 3474
		{status = "DONE", result = result} -- 3474
	) -- 3474
	return {success = true, answerStep = answerStep, result = result} -- 3478
end -- 3404
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig) -- 3481
	local session = getSessionItem(sessionId) -- 3482
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3482
		return {success = false, message = "project task admission is closed"} -- 3483
	end -- 3483
	if not session then -- 3483
		return {success = false, message = "session not found"} -- 3484
	end -- 3484
	if session.kind ~= "main" then -- 3484
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3485
	end -- 3485
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3486
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3486
		return {success = false, message = "pending questionnaire not found or already handled"} -- 3488
	end -- 3488
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3490
	if not llmConfigRes.success then -- 3490
		return {success = false, message = llmConfigRes.message} -- 3491
	end -- 3491
	if not removePendingQuestionnaire(session) then -- 3491
		return {success = false, message = "failed to consume questionnaire file"} -- 3492
	end -- 3492
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed") -- 3493
	if not replaced.success then -- 3493
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3495
		return replaced -- 3496
	end -- 3496
	local t = now() -- 3498
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3499
	session.workMode = "plan" -- 3500
	local result = startPromptTask( -- 3501
		session, -- 3501
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"), -- 3501
		nil, -- 3501
		{}, -- 3501
		{ -- 3501
			workMode = "plan", -- 3502
			persistUserMessage = false, -- 3503
			resumeConversation = true, -- 3504
			existingTaskId = questionnaire.taskId, -- 3505
			initialStep = replaced.answerStep, -- 3506
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3507
			llmConfig = llmConfigRes.config -- 3508
		} -- 3508
	) -- 3508
	if not result.success then -- 3508
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3511
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3512
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3513
		emitAgentSessionPatch( -- 3514
			session.id, -- 3514
			{ -- 3514
				session = getSessionItem(session.id), -- 3515
				pendingQuestionnaire = questionnaire -- 3516
			} -- 3516
		) -- 3516
		return result -- 3518
	end -- 3518
	emitAgentSessionPatch( -- 3520
		sessionId, -- 3520
		{ -- 3520
			session = getSessionItem(sessionId), -- 3521
			pendingQuestionnaire = false -- 3522
		} -- 3522
	) -- 3522
	return result -- 3524
end -- 3481
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig) -- 3527
	local session = getSessionItem(sessionId) -- 3528
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then -- 3528
		return {success = false, message = "project task admission is closed"} -- 3529
	end -- 3529
	if not session then -- 3529
		return {success = false, message = "session not found"} -- 3530
	end -- 3530
	if session.kind ~= "main" then -- 3530
		return {success = false, message = "questionnaires are only available for main sessions"} -- 3531
	end -- 3531
	local questionnaire = getPendingQuestionnaire(sessionId) -- 3532
	if not questionnaire or questionnaire.id ~= questionnaireId then -- 3532
		return {success = false, message = "pending questionnaire not found"} -- 3533
	end -- 3533
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers) -- 3534
	if not validated.success then -- 3534
		return validated -- 3535
	end -- 3535
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId) -- 3536
	if not llmConfigRes.success then -- 3536
		return {success = false, message = llmConfigRes.message} -- 3537
	end -- 3537
	local t = now() -- 3538
	if not removePendingQuestionnaire(session) then -- 3538
		return {success = false, message = "failed to consume questionnaire file"} -- 3539
	end -- 3539
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered") -- 3540
	if not replaced.success then -- 3540
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3542
		return replaced -- 3543
	end -- 3543
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId}) -- 3545
	session.workMode = "plan" -- 3546
	local result = startPromptTask( -- 3547
		session, -- 3547
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"), -- 3547
		nil, -- 3547
		{}, -- 3547
		{ -- 3547
			workMode = "plan", -- 3548
			persistUserMessage = false, -- 3549
			resumeConversation = true, -- 3550
			existingTaskId = questionnaire.taskId, -- 3551
			initialStep = replaced.answerStep, -- 3552
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId), -- 3553
			llmConfig = llmConfigRes.config -- 3554
		} -- 3554
	) -- 3554
	if not result.success then -- 3554
		savePendingQuestionnaire(session.projectRoot, questionnaire) -- 3557
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER") -- 3558
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER") -- 3559
		emitAgentSessionPatch( -- 3560
			session.id, -- 3560
			{ -- 3560
				session = getSessionItem(session.id), -- 3561
				pendingQuestionnaire = questionnaire -- 3562
			} -- 3562
		) -- 3562
		return result -- 3564
	end -- 3564
	emitAgentSessionPatch( -- 3566
		sessionId, -- 3566
		{ -- 3566
			session = getSessionItem(sessionId), -- 3567
			pendingQuestionnaire = false -- 3568
		} -- 3568
	) -- 3568
	return result -- 3570
end -- 3527
function ____exports.stopSessionTask(sessionId) -- 3573
	InputInbox.holdInputs(sessionId) -- 3574
	followup.publish(sessionId) -- 3575
	local session = getSessionItem(sessionId) -- 3576
	if not session or session.currentTaskId == nil then -- 3576
		return {success = false, message = "session task not found"} -- 3578
	end -- 3578
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then -- 3578
		return {success = false, message = "session task is finalizing"} -- 3581
	end -- 3581
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime) -- 3583
	local normalizedSession = normalizeSessionRuntimeState(session) -- 3584
	local localControl = activeLocalAgentControls[session.currentTaskId] -- 3585
	if localControl ~= nil then -- 3585
		localControl:stop() -- 3587
		return {success = true, stopping = true} -- 3588
	end -- 3588
	local stopToken = activeStopTokens[session.currentTaskId] -- 3590
	if stopToken == nil then -- 3590
		if normalizedSession.currentTaskStatus == "STOPPED" then -- 3590
			return {success = true, recovered = true} -- 3593
		end -- 3593
		return {success = false, message = "task is not running"} -- 3595
	end -- 3595
	if stopToken.stopped then -- 3595
		return {success = true, stopping = true} -- 3598
	end -- 3598
	stopToken.stopped = true -- 3600
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user" -- 3601
	return {success = true, stopping = true} -- 3605
end -- 3573
function ____exports.getCurrentTaskId(sessionId) -- 3608
	local ____opt_229 = getSessionItem(sessionId) -- 3608
	return ____opt_229 and ____opt_229.currentTaskId -- 3609
end -- 3608
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId) -- 3613
	local owner = getSessionItem(sessionId) -- 3614
	if not owner then -- 3614
		return {success = false, message = "session not found"} -- 3615
	end -- 3615
	local projectRoot = owner.projectRoot -- 3616
	local release = holdProjectTaskAdmission(projectRoot) -- 3617
	local closed = false -- 3618
	return { -- 3619
		success = true, -- 3620
		projectRoot = projectRoot, -- 3621
		close = function() -- 3622
			if not closed then -- 3622
				closed = true -- 3622
				release() -- 3622
			end -- 3622
		end, -- 3622
		poll = function() -- 3623
			if closed then -- 3623
				return {success = false, message = "quiescence handle closed"} -- 3624
			end -- 3624
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot}) -- 3625
			if not rows then -- 3625
				return {success = false, message = "failed to inspect project tasks"} -- 3626
			end -- 3626
			local pending = {} -- 3627
			for ____, row in ipairs(rows) do -- 3628
				do -- 3628
					local session = rowToSession(row) -- 3629
					local taskId = session.currentTaskId -- 3630
					if taskId == nil then -- 3630
						goto __continue670 -- 3631
					end -- 3631
					local finalizing = finalizingSubSessionTaskIds[taskId] == true -- 3632
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then -- 3632
						goto __continue670 -- 3633
					end -- 3633
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id) -- 3635
					local ____session_id_232 = session.id -- 3636
					local ____taskId_233 = taskId -- 3636
					local ____finalizing_234 = finalizing -- 3636
					local ____result_success_235 = result.success -- 3636
					local ____result_success_231 -- 3636
					if result.success then -- 3636
						____result_success_231 = nil -- 3636
					else -- 3636
						____result_success_231 = result.message -- 3636
					end -- 3636
					pending[#pending + 1] = { -- 3636
						sessionId = ____session_id_232, -- 3636
						taskId = ____taskId_233, -- 3636
						finalizing = ____finalizing_234, -- 3636
						stopRequested = ____result_success_235, -- 3636
						message = ____result_success_231 -- 3636
					} -- 3636
				end -- 3636
				::__continue670:: -- 3636
			end -- 3636
			return {success = true, quiescent = #pending == 0, pending = pending} -- 3640
		end -- 3623
	} -- 3623
end -- 3613
function ____exports.validateTaskAccess(sessionId, taskId) -- 3645
	local session = getSessionItem(sessionId) -- 3646
	if not session then -- 3646
		return {success = false, message = "session not found"} -- 3647
	end -- 3647
	if taskId <= 0 or __TS__ArrayIndexOf( -- 3647
		getSessionOperableTaskIds(sessionId), -- 3648
		taskId -- 3648
	) < 0 then -- 3648
		return {success = false, message = "task is not operable for this session"} -- 3649
	end -- 3649
	return {success = true, session = session} -- 3651
end -- 3645
function ____exports.validateCheckpointAccess(sessionId, checkpointId) -- 3654
	if checkpointId <= 0 then -- 3654
		return {success = false, message = "invalid checkpointId"} -- 3656
	end -- 3656
	local checkpoint = Tools.getCheckpoint(checkpointId) -- 3658
	if not checkpoint then -- 3658
		return {success = false, message = "checkpoint not found"} -- 3660
	end -- 3660
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId) -- 3662
	if not taskAccess.success then -- 3662
		return taskAccess -- 3663
	end -- 3663
	return {success = true, session = taskAccess.session, checkpoint = checkpoint} -- 3664
end -- 3654
function ____exports.listRunningSessions() -- 3667
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({}) -- 3668
	local sessions = {} -- 3675
	do -- 3675
		local i = 0 -- 3676
		while i < #rows do -- 3676
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1])) -- 3677
			if session.currentTaskStatus == "RUNNING" then -- 3677
				sessions[#sessions + 1] = session -- 3679
			end -- 3679
			i = i + 1 -- 3676
		end -- 3676
	end -- 3676
	return {success = true, sessions = sessions} -- 3682
end -- 3667
return ____exports -- 3667