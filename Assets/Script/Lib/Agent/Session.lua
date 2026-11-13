local ____lualib = require("lualib_bundle")
local __TS__New = ____lualib.__TS__New
local __TS__ObjectKeys = ____lualib.__TS__ObjectKeys
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter
local __TS__ArrayMap = ____lualib.__TS__ArrayMap
local __TS__StringTrim = ____lualib.__TS__StringTrim
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf
local __TS__ArraySlice = ____lualib.__TS__ArraySlice
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter
local __TS__Await = ____lualib.__TS__Await
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith
local __TS__StringSlice = ____lualib.__TS__StringSlice
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread
local __TS__ArraySort = ____lualib.__TS__ArraySort
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith
local __TS__Delete = ____lualib.__TS__Delete
local __TS__ArrayFind = ____lualib.__TS__ArrayFind
local __TS__ArraySome = ____lualib.__TS__ArraySome
local __TS__ArrayConcat = ____lualib.__TS__ArrayConcat
local ____exports = {}
local scheduleStreamFlush, getDefaultUseChineseResponse, encodeJson, decodeJsonObject, decodeJsonFiles, decodeChangeSetSummary, decodeHandoffEvidence, takeUtf8Head, normalizeMemoryEntryEvidence, decodeSubAgentMemoryEntry, getTaskChangeSetSummary, summarizeHandoffResult, getTaskHandoffEvidence, reconcileCompletionWithHandoffEvidence, isValidProjectRoot, rowToSession, rowToMessage, rowToStep, getQuestionnairePath, decodeQuestionnaireFile, getPendingQuestionnaire, restorePendingQuestionnaireState, savePendingQuestionnaire, removePendingQuestionnaire, publishQuestionnaire, getMessageItem, getStepItem, deleteMessageSteps, normalizeDisabledAgentTools, normalizeWorkMode, getSessionRow, getSessionItem, getTaskPrompt, getLatestMainSessionByProjectRoot, countRunningSubSessions, deleteSessionRecords, getSessionRootId, getRootSessionItem, listRelatedSessions, getSessionSpawnInfo, ensureDirRecursive, writeSpawnInfo, readSpawnInfo, getArtifactRelativeDir, getArtifactDir, getResultRelativePath, getResultPath, readSubAgentResultSummary, buildStructuredSubAgentMemoryEntry, containsNormalizedText, getSubAgentDisplayKey, writeSubAgentResultFile, listSubAgentResultRecords, getPendingHandoffDir, writePendingHandoff, listPendingHandoffs, deletePendingHandoff, normalizePromptText, normalizePromptTextSafe, buildSubAgentPromptFallback, normalizeSessionRuntimeState, setSessionState, mergeAgentMetrics, updateSessionMetrics, clearSessionTokenUsage, getInitialTokenUsage, setSessionStateForTaskEvent, insertMessage, updateMessage, updateUserMessageForTask, removeContinuableTaskSummary, upsertAssistantMessage, upsertStep, getNextStepNumber, appendHandoffSystemStep, finalizeTaskSteps, emitAgentSessionPatch, emitSessionDeletedPatch, flushPendingSubAgentHandoffs, applyEvent, spawnSubAgentSession, appendSubAgentHandoffStep, finalizeSubSession, stopClearedSubSession, startPromptTask, buildQuestionnaireFeedbackDisplay, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE, SPAWN_INFO_FILE, RESULT_FILE, PENDING_HANDOFF_DIR, MAX_CONCURRENT_SUB_AGENTS, SUB_AGENT_MEMORY_ENTRY_MAX_CHARS, SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS, activeStopTokens, activeLocalAgentControls, finalizingSubSessionTaskIds, activePromptRuns, streamUpdates, streamFlushScheduled, SESSION_SELECT_COLUMNS, now
local ____Dora = require("Dora")
local App = ____Dora.App
local Content = ____Dora.Content
local DB = ____Dora.DB
local Director = ____Dora.Director
local Path = ____Dora.Path
local HttpServer = ____Dora.HttpServer
local emit = ____Dora.emit
local ____StreamUpdates = require("Agent.Runtime.StreamUpdates")
local StreamUpdates = ____StreamUpdates.StreamUpdates
local ____SessionEvents = require("Agent.Runtime.SessionEvents")
local publishSessionPatch = ____SessionEvents.publishSessionPatch
local ____TaskAdmission = require("Agent.Runtime.TaskAdmission")
local holdProjectTaskAdmission = ____TaskAdmission.holdProjectTaskAdmission
local isProjectTaskAdmissionClosed = ____TaskAdmission.isProjectTaskAdmissionClosed
local ____DoraAgent = require("Agent.DoraAgent")
local runCodingAgent = ____DoraAgent.runCodingAgent
local truncateAgentUserPrompt = ____DoraAgent.truncateAgentUserPrompt
local AgentConfig = require("Agent.Config.Defaults")
local AgentToolRegistry = require("Agent.Tool.Registry")
local AgentRuntimePolicy = require("Agent.Runtime.Policy")
local LocalAgent = require("Agent.Runtime.LocalAgent")
local Tools = require("Agent.Tools")
local ____Database = require("Agent.Storage.Database")
local TABLE_SESSION = ____Database.TABLE_SESSION
local TABLE_MESSAGE = ____Database.TABLE_MESSAGE
local TABLE_STEP = ____Database.TABLE_STEP
local TABLE_TASK = ____Database.TABLE_TASK
local TABLE_TASK_REFERENCE = ____Database.TABLE_TASK_REFERENCE
local addTaskReference = ____Database.addTaskReference
local cleanupTaskHeavyData = ____Database.cleanupTaskHeavyData
local getSessionOperableTaskIds = ____Database.getSessionOperableTaskIds
local requireAgentStorage = ____Database.requireAgentStorage
local ____Memory = require("Agent.Runtime.Memory")
local DualLayerStorage = ____Memory.DualLayerStorage
local ____Utils = require("Agent.Utils")
local Log = ____Utils.Log
local getLLMConfig = ____Utils.getLLMConfig
local normalizeAgentCompletionReport = ____Utils.normalizeAgentCompletionReport
local safeJsonDecode = ____Utils.safeJsonDecode
local safeJsonEncode = ____Utils.safeJsonEncode
local sanitizeUTF8 = ____Utils.sanitizeUTF8
local validateAgentLLMConfig = ____Utils.validateAgentLLMConfig
local ____Questionnaire = require("Agent.Runtime.Questionnaire")
local validateQuestionnaireAnswers = ____Questionnaire.validateQuestionnaireAnswers
local ____Support = require("Agent.Storage.Support")
local getLastInsertRowId = ____Support.getLastInsertRowId
local queryOne = ____Support.queryOne
local queryRows = ____Support.queryRows
local toStr = ____Support.toStr
function scheduleStreamFlush()
	if streamFlushScheduled or not streamUpdates:hasPending() then
		return
	end
	streamFlushScheduled = true
	Director.systemScheduler:schedule(function()
		streamUpdates:flushDue(App.runningTime)
		if streamUpdates:hasPending() then
			return false
		end
		streamFlushScheduled = false
		return true
	end)
end
function getDefaultUseChineseResponse()
	local zh = string.match(App.locale, "^zh")
	return zh ~= nil
end
function encodeJson(value)
	local text = safeJsonEncode(value)
	return text or ""
end
function decodeJsonObject(text)
	if text == "" then
		return nil
	end
	local value = safeJsonDecode(text)
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then
		return value
	end
	return nil
end
function decodeJsonFiles(text)
	if text == "" then
		return nil
	end
	local value = safeJsonDecode(text)
	if not value or not __TS__ArrayIsArray(value) then
		return nil
	end
	local files = {}
	do
		local i = 0
		while i < #value do
			do
				local item = value[i + 1]
				if type(item) ~= "table" then
					goto __continue19
				end
				files[#files + 1] = {
					path = sanitizeUTF8(toStr(item.path)),
					op = sanitizeUTF8(toStr(item.op))
				}
			end
			::__continue19::
			i = i + 1
		end
	end
	return files
end
function decodeChangeSetSummary(value)
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then
		return nil
	end
	local row = value
	if row.success ~= true then
		return nil
	end
	local taskId = type(row.taskId) == "number" and row.taskId or 0
	if taskId <= 0 then
		return nil
	end
	local files = {}
	if __TS__ArrayIsArray(row.files) then
		do
			local i = 0
			while i < #row.files do
				do
					local file = row.files[i + 1]
					if not file or __TS__ArrayIsArray(file) or type(file) ~= "table" then
						goto __continue27
					end
					local fileRow = file
					local path = sanitizeUTF8(toStr(fileRow.path))
					if path == "" then
						goto __continue27
					end
					local checkpointIds = {}
					if __TS__ArrayIsArray(fileRow.checkpointIds) then
						do
							local j = 0
							while j < #fileRow.checkpointIds do
								local checkpointId = type(fileRow.checkpointIds[j + 1]) == "number" and fileRow.checkpointIds[j + 1] or 0
								if checkpointId > 0 then
									checkpointIds[#checkpointIds + 1] = checkpointId
								end
								j = j + 1
							end
						end
					end
					local op = toStr(fileRow.op)
					files[#files + 1] = {
						path = path,
						op = (op == "create" or op == "delete" or op == "write") and op or "write",
						checkpointCount = type(fileRow.checkpointCount) == "number" and fileRow.checkpointCount or #checkpointIds,
						checkpointIds = checkpointIds
					}
				end
				::__continue27::
				i = i + 1
			end
		end
	end
	return {
		success = true,
		taskId = taskId,
		checkpointCount = type(row.checkpointCount) == "number" and row.checkpointCount or 0,
		filesChanged = type(row.filesChanged) == "number" and row.filesChanged or #files,
		files = files,
		latestCheckpointId = type(row.latestCheckpointId) == "number" and row.latestCheckpointId or nil,
		latestCheckpointSeq = type(row.latestCheckpointSeq) == "number" and row.latestCheckpointSeq or nil
	}
end
function decodeHandoffEvidence(value)
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then
		return nil
	end
	local row = value
	local modifiedFiles = __TS__ArrayIsArray(row.modifiedFiles) and __TS__ArrayMap(
		__TS__ArrayFilter(
			row.modifiedFiles,
			function(____, item) return type(item) == "string" end
		),
		function(____, item) return sanitizeUTF8(item) end
	) or ({})
	local lastBuild = nil
	if row.lastBuild and not __TS__ArrayIsArray(row.lastBuild) and type(row.lastBuild) == "table" then
		local build = row.lastBuild
		lastBuild = {
			result = build.result == "passed" and "passed" or "failed",
			path = sanitizeUTF8(toStr(build.path)),
			evidence = takeUtf8Head(
				sanitizeUTF8(toStr(build.evidence)),
				600
			)
		}
	end
	local commands = {}
	if __TS__ArrayIsArray(row.commands) then
		do
			local i = 0
			while i < #row.commands and #commands < 8 do
				do
					local raw = row.commands[i + 1]
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then
						goto __continue41
					end
					local item = raw
					commands[#commands + 1] = {
						mode = sanitizeUTF8(toStr(item.mode)),
						command = takeUtf8Head(
							sanitizeUTF8(toStr(item.command)),
							600
						),
						result = item.result == "passed" and "passed" or "failed",
						evidence = takeUtf8Head(
							sanitizeUTF8(toStr(item.evidence)),
							600
						)
					}
				end
				::__continue41::
				i = i + 1
			end
		end
	end
	local authoritativeSources = {}
	if __TS__ArrayIsArray(row.authoritativeSources) then
		do
			local i = 0
			while i < #row.authoritativeSources and #authoritativeSources < 8 do
				do
					local raw = row.authoritativeSources[i + 1]
					if not raw or __TS__ArrayIsArray(raw) or type(raw) ~= "table" then
						goto __continue45
					end
					local item = raw
					authoritativeSources[#authoritativeSources + 1] = {
						tool = "search_dora_doc",
						query = takeUtf8Head(
							sanitizeUTF8(toStr(item.query)),
							300
						),
						source = sanitizeUTF8(toStr(item.source)),
						result = item.result == "passed" and "passed" or "failed"
					}
				end
				::__continue45::
				i = i + 1
			end
		end
	end
	return {modifiedFiles = modifiedFiles, lastBuild = lastBuild, commands = commands, authoritativeSources = authoritativeSources}
end
function takeUtf8Head(text, maxChars)
	if maxChars <= 0 or text == "" then
		return ""
	end
	local nextPos = utf8.offset(text, maxChars + 1)
	if nextPos == nil then
		return text
	end
	return string.sub(text, 1, nextPos - 1)
end
function normalizeMemoryEntryEvidence(value)
	local evidence = {}
	if not __TS__ArrayIsArray(value) then
		return evidence
	end
	do
		local i = 0
		while i < #value and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do
			do
				local item = __TS__StringTrim(sanitizeUTF8(toStr(value[i + 1])))
				if item == "" then
					goto __continue53
				end
				if __TS__ArrayIndexOf(evidence, item) < 0 then
					evidence[#evidence + 1] = item
				end
			end
			::__continue53::
			i = i + 1
		end
	end
	return evidence
end
function decodeSubAgentMemoryEntry(value)
	if not value or __TS__ArrayIsArray(value) or type(value) ~= "table" then
		return nil
	end
	local row = value
	local sourceSessionId = type(row.sourceSessionId) == "number" and row.sourceSessionId or 0
	local sourceTaskId = type(row.sourceTaskId) == "number" and row.sourceTaskId or 0
	local content = takeUtf8Head(
		__TS__StringTrim(sanitizeUTF8(toStr(row.content))),
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS
	)
	if sourceSessionId <= 0 or sourceTaskId <= 0 or content == "" then
		return nil
	end
	return {
		sourceSessionId = sourceSessionId,
		sourceTaskId = sourceTaskId,
		content = content,
		evidence = normalizeMemoryEntryEvidence(row.evidence),
		createdAt = __TS__StringTrim(sanitizeUTF8(toStr(row.createdAt)))
	}
end
function getTaskChangeSetSummary(taskId)
	local summary = Tools.summarizeTaskChangeSet(taskId)
	return summary.success and summary or nil
end
function summarizeHandoffResult(result)
	local candidates = {result.output, result.message, result.state, result.phase}
	do
		local i = 0
		while i < #candidates do
			local text = __TS__StringTrim(sanitizeUTF8(toStr(candidates[i + 1])))
			if text ~= "" then
				return takeUtf8Head(text, 600)
			end
			i = i + 1
		end
	end
	local messages = result.messages
	if __TS__ArrayIsArray(messages) and #messages > 0 then
		local parts = {}
		do
			local i = 0
			while i < #messages and #parts < 4 do
				do
					local row = messages[i + 1]
					if not row or type(row) ~= "table" then
						goto __continue66
					end
					local item = row
					local ____sanitizeUTF8_5 = sanitizeUTF8
					local ____toStr_4 = toStr
					local ____item_message_2 = item.message
					if ____item_message_2 == nil then
						____item_message_2 = item.error
					end
					local ____item_message_2_3 = ____item_message_2
					if ____item_message_2_3 == nil then
						____item_message_2_3 = item.file
					end
					local text = __TS__StringTrim(____sanitizeUTF8_5(____toStr_4(____item_message_2_3)))
					if text ~= "" then
						parts[#parts + 1] = text
					end
				end
				::__continue66::
				i = i + 1
			end
		end
		if #parts > 0 then
			return takeUtf8Head(
				table.concat(parts, "; "),
				600
			)
		end
	end
	return result.success == true and "tool result success=true" or "tool result success=false"
end
function getTaskHandoffEvidence(taskId, changeSet)
	local ____opt_6 = changeSet
	local evidence = {
		modifiedFiles = ____opt_6 and __TS__ArrayMap(
			changeSet and changeSet.files,
			function(____, item) return item.path end
		) or ({}),
		commands = {},
		authoritativeSources = {}
	}
	local rows = queryRows(("SELECT tool, status, params_json, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE task_id = ? AND tool IN (?, ?, ?) ORDER BY step ASC", {taskId, "build", "execute_command", "search_dora_doc"}) or ({})
	do
		local i = 0
		while i < #rows do
			local tool = toStr(rows[i + 1][1])
			local status = toStr(rows[i + 1][2])
			local params = decodeJsonObject(toStr(rows[i + 1][3])) or ({})
			local result = decodeJsonObject(toStr(rows[i + 1][4])) or ({})
			local passed = status == "DONE" and result.success == true
			if tool == "build" then
				evidence.lastBuild = {
					result = passed and "passed" or "failed",
					path = __TS__StringTrim(sanitizeUTF8(toStr(params.path))),
					evidence = summarizeHandoffResult(result)
				}
			elseif tool == "execute_command" and #evidence.commands < 8 then
				local mode = __TS__StringTrim(sanitizeUTF8(toStr(params.mode)))
				local command = mode == "git" and toStr(params.command) or toStr(params.code)
				local ____evidence_commands_10 = evidence.commands
				____evidence_commands_10[#____evidence_commands_10 + 1] = {
					mode = mode,
					command = takeUtf8Head(
						__TS__StringTrim(sanitizeUTF8(command)),
						600
					),
					result = passed and "passed" or "failed",
					evidence = summarizeHandoffResult(result)
				}
			elseif tool == "search_dora_doc" and #evidence.authoritativeSources < 8 then
				local ____evidence_authoritativeSources_11 = evidence.authoritativeSources
				____evidence_authoritativeSources_11[#____evidence_authoritativeSources_11 + 1] = {
					tool = "search_dora_doc",
					query = takeUtf8Head(
						__TS__StringTrim(sanitizeUTF8(toStr(params.pattern))),
						300
					),
					source = __TS__StringTrim(sanitizeUTF8(toStr(params.docType or "dora-api"))),
					result = passed and "passed" or "failed"
				}
			end
			i = i + 1
		end
	end
	return evidence
end
function reconcileCompletionWithHandoffEvidence(completion, evidence)
	local lastBuild = evidence.lastBuild
	if not lastBuild or lastBuild.result ~= "failed" then
		return completion
	end
	local validation = __TS__ArraySlice(completion.validation)
	local foundBuild = false
	do
		local i = 0
		while i < #validation do
			do
				if validation[i + 1].kind ~= "build" then
					goto __continue80
				end
				foundBuild = true
				validation[i + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}}
			end
			::__continue80::
			i = i + 1
		end
	end
	if not foundBuild then
		validation[#validation + 1] = {kind = "build", result = "failed", evidence = {lastBuild.evidence}}
	end
	local knownIssues = __TS__ArraySlice(completion.knownIssues)
	local issue = (("Latest recorded build failed" .. (lastBuild.path ~= "" and " for " .. lastBuild.path or "")) .. ": ") .. lastBuild.evidence
	if __TS__ArrayIndexOf(knownIssues, issue) < 0 then
		knownIssues[#knownIssues + 1] = issue
	end
	return __TS__ObjectAssign({}, completion, {outcome = completion.outcome == "completed" and "partial" or completion.outcome, validation = validation, knownIssues = knownIssues})
end
function isValidProjectRoot(path)
	return path ~= "" and Content:isAbsolutePath(path) and Content:exist(path) and Content:isdir(path)
end
function rowToSession(row)
	return {
		id = row[1],
		projectRoot = toStr(row[2]),
		title = toStr(row[3]),
		kind = toStr(row[4]) == "sub" and "sub" or "main",
		rootSessionId = type(row[5]) == "number" and row[5] > 0 and row[5] or row[1],
		parentSessionId = type(row[6]) == "number" and row[6] > 0 and row[6] or nil,
		memoryScope = toStr(row[7]) ~= "" and toStr(row[7]) or "main",
		status = toStr(row[8]),
		currentTaskId = type(row[9]) == "number" and row[9] > 0 and row[9] or nil,
		currentTaskStatus = toStr(row[10]),
		currentTaskFinalizing = type(row[9]) == "number" and row[9] > 0 and finalizingSubSessionTaskIds[row[9]] == true,
		createdAt = row[11],
		updatedAt = row[12],
		metrics = decodeJsonObject(toStr(row[13])),
		workMode = toStr(row[14]) == "plan" and "plan" or "code"
	}
end
function rowToMessage(row)
	local message = {
		id = row[1],
		sessionId = row[2],
		taskId = type(row[3]) == "number" and row[3] > 0 and row[3] or nil,
		role = toStr(row[4]),
		content = toStr(row[5]),
		createdAt = row[7],
		updatedAt = row[8]
	}
	local displayContent = toStr(row[6])
	if displayContent ~= "" then
		message.displayContent = displayContent
	end
	return message
end
function rowToStep(row)
	return {
		id = row[1],
		sessionId = row[2],
		taskId = row[3],
		step = row[4],
		tool = toStr(row[5]),
		status = toStr(row[6]),
		reason = toStr(row[7]),
		reasoningContent = toStr(row[8]),
		params = decodeJsonObject(toStr(row[9])),
		result = decodeJsonObject(toStr(row[10])),
		checkpointId = type(row[11]) == "number" and row[11] > 0 and row[11] or nil,
		checkpointSeq = type(row[12]) == "number" and row[12] > 0 and row[12] or nil,
		files = decodeJsonFiles(toStr(row[13])),
		createdAt = row[14],
		updatedAt = row[15]
	}
end
function getQuestionnairePath(projectRoot)
	return Path(projectRoot, QUESTIONNAIRE_DIR, PENDING_QUESTIONNAIRE_FILE)
end
function decodeQuestionnaireFile(text)
	local value = decodeJsonObject(text)
	if not value then
		return nil
	end
	local schema = value.schema
	local id = type(value.id) == "number" and value.id or 0
	local sessionId = type(value.sessionId) == "number" and value.sessionId or 0
	local taskId = type(value.taskId) == "number" and value.taskId or 0
	local step = type(value.step) == "number" and value.step or 0
	local createdAt = type(value.createdAt) == "number" and value.createdAt or 0
	if id <= 0 or sessionId <= 0 or taskId <= 0 or step <= 0 or createdAt <= 0 or not schema or not __TS__ArrayIsArray(schema.questions) then
		return nil
	end
	return {
		id = id,
		sessionId = sessionId,
		taskId = taskId,
		step = step,
		status = "PENDING",
		schema = schema,
		createdAt = createdAt
	}
end
function getPendingQuestionnaire(sessionId)
	local session = getSessionItem(sessionId)
	if not session or session.kind ~= "main" then
		return nil
	end
	local path = getQuestionnairePath(session.projectRoot)
	if not Content:exist(path) then
		return nil
	end
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path)))
	return (questionnaire and questionnaire.sessionId) == sessionId and questionnaire or nil
end
function restorePendingQuestionnaireState(session)
	local questionnaire = getPendingQuestionnaire(session.id)
	if not questionnaire then
		return {session = session}
	end
	if session.workMode ~= "plan" or session.status ~= "WAITING_USER" or session.currentTaskId ~= questionnaire.taskId or session.currentTaskStatus ~= "WAITING_USER" then
		local t = now()
		DB:exec(("UPDATE " .. TABLE_SESSION) .. "\n\t\t\tSET work_mode = 'plan', status = 'WAITING_USER', current_task_id = ?, current_task_status = 'WAITING_USER', updated_at = ?\n\t\t\tWHERE id = ?", {questionnaire.taskId, t, session.id})
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER")
		local restored = getSessionItem(session.id)
		if restored then
			session = restored
		end
	end
	return {session = session, questionnaire = questionnaire}
end
function savePendingQuestionnaire(projectRoot, questionnaire)
	local dir = Path(projectRoot, QUESTIONNAIRE_DIR)
	if not Content:exist(dir) and not Content:mkdir(dir) then
		return false
	end
	local path = getQuestionnairePath(projectRoot)
	local tempPath = path .. ".tmp"
	local backupPath = path .. ".bak"
	Content:remove(tempPath)
	Content:remove(backupPath)
	if not Content:save(
		tempPath,
		encodeJson(questionnaire)
	) then
		return false
	end
	local hadOriginal = Content:exist(path)
	if hadOriginal and not Content:move(path, backupPath) then
		Content:remove(tempPath)
		return false
	end
	if Content:move(tempPath, path) then
		Content:remove(backupPath)
		Tools.sendWebIDEFileUpdate(
			path,
			true,
			encodeJson(questionnaire)
		)
		return true
	end
	Content:remove(tempPath)
	if hadOriginal and Content:exist(backupPath) then
		Content:move(backupPath, path)
	end
	return false
end
function removePendingQuestionnaire(session)
	local path = getQuestionnairePath(session.projectRoot)
	if not Content:exist(path) then
		return true
	end
	local questionnaire = decodeQuestionnaireFile(sanitizeUTF8(Content:load(path)))
	if questionnaire and questionnaire.sessionId ~= session.id then
		return false
	end
	if not Content:remove(path) then
		return false
	end
	Tools.sendWebIDEFileUpdate(path, false, "")
	return true
end
function publishQuestionnaire(request)
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local session = getSessionItem(request.sessionId)
		if not session or session.kind ~= "main" then
			return ____awaiter_resolve(nil, {success = false, message = "main session not found"})
		end
		local pendingPath = getQuestionnairePath(session.projectRoot)
		if Content:exist(pendingPath) then
			return ____awaiter_resolve(nil, {success = false, message = "project already has a pending questionnaire"})
		end
		local questionnaire = {
			id = request.taskId,
			sessionId = request.sessionId,
			taskId = request.taskId,
			step = request.step,
			status = "PENDING",
			schema = request.schema,
			createdAt = now()
		}
		if not savePendingQuestionnaire(session.projectRoot, questionnaire) then
			return ____awaiter_resolve(nil, {success = false, message = "failed to publish questionnaire file"})
		end
		return ____awaiter_resolve(nil, {success = true, questionnaireId = questionnaire.id})
	end)
end
function getMessageItem(messageId)
	local row = queryOne(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE id = ?", {messageId})
	return row and rowToMessage(row) or nil
end
function getStepItem(sessionId, taskId, step)
	local row = queryOne(("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step})
	return row and rowToStep(row) or nil
end
function deleteMessageSteps(sessionId, taskId)
	local rows = queryRows(("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"}) or ({})
	local ids = {}
	do
		local i = 0
		while i < #rows do
			local row = rows[i + 1]
			if type(row[1]) == "number" then
				ids[#ids + 1] = row[1]
			end
			i = i + 1
		end
	end
	if #ids > 0 then
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND tool = ?", {sessionId, taskId, "message"})
	end
	return ids
end
function normalizeDisabledAgentTools(value)
	if not __TS__ArrayIsArray(value) then
		return {}
	end
	local tools = {}
	do
		local i = 0
		while i < #value do
			do
				local name = value[i + 1]
				if type(name) ~= "string" or not AgentToolRegistry.isKnownToolName(name) then
					goto __continue124
				end
				if __TS__ArrayIndexOf(tools, name) < 0 then
					tools[#tools + 1] = name
				end
			end
			::__continue124::
			i = i + 1
		end
	end
	return tools
end
function normalizeWorkMode(value, fallback)
	if fallback == nil then
		fallback = "code"
	end
	return value == "plan" and "plan" or (value == "code" and "code" or fallback)
end
function getSessionRow(sessionId)
	return queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ?", {sessionId})
end
function getSessionItem(sessionId)
	local row = getSessionRow(sessionId)
	return row and rowToSession(row) or nil
end
function getTaskPrompt(taskId)
	local row = queryOne(("SELECT prompt FROM " .. TABLE_TASK) .. " WHERE id = ?", {taskId})
	if not row or type(row[1]) ~= "string" then
		return nil
	end
	return toStr(row[1])
end
function getLatestMainSessionByProjectRoot(projectRoot)
	if not isValidProjectRoot(projectRoot) then
		return nil
	end
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot})
	return row and rowToSession(row) or nil
end
function countRunningSubSessions(rootSessionId)
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSessionId}) or ({})
	local count = 0
	do
		local i = 0
		while i < #rows do
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1]))
			if session.currentTaskStatus == "RUNNING" then
				count = count + 1
			end
			i = i + 1
		end
	end
	return count
end
function deleteSessionRecords(sessionId, preserveArtifacts)
	if preserveArtifacts == nil then
		preserveArtifacts = false
	end
	streamUpdates:clear(sessionId)
	local session = getSessionItem(sessionId)
	local taskRows = queryRows(((((("SELECT current_task_id FROM " .. TABLE_SESSION) .. " WHERE id = ? AND current_task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_STEP) .. " WHERE session_id = ? AND task_id > 0\n\t\tUNION\n\t\tSELECT task_id FROM ") .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id > 0", {sessionId, sessionId, sessionId}) or ({})
	local taskIds = {}
	do
		local i = 0
		while i < #taskRows do
			local taskId = type(taskRows[i + 1][1]) == "number" and taskRows[i + 1][1] or 0
			if taskId > 0 and __TS__ArrayIndexOf(taskIds, taskId) < 0 then
				taskIds[#taskIds + 1] = taskId
				local stopToken = activeStopTokens[taskId]
				if stopToken ~= nil then
					stopToken.stopped = true
					stopToken.reason = "session deleted"
				end
			end
			i = i + 1
		end
	end
	local children = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId}) or ({})
	do
		local i = 0
		while i < #children do
			local row = children[i + 1]
			if type(row[1]) == "number" and row[1] > 0 then
				deleteSessionRecords(row[1], preserveArtifacts)
			end
			i = i + 1
		end
	end
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE parent_session_id = ?", {sessionId})
	DB:exec(("DELETE FROM " .. TABLE_STEP) .. " WHERE session_id = ?", {sessionId})
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ?", {sessionId})
	DB:exec(("DELETE FROM " .. TABLE_SESSION) .. " WHERE id = ?", {sessionId})
	if session and session.kind == "main" then
		removePendingQuestionnaire(session)
	end
	if not preserveArtifacts and session and session.kind == "sub" and session.memoryScope ~= "" then
		if Content:remove(Path(session.projectRoot, ".agent", session.memoryScope)) then
			Tools.sendWebIDERefreshTree()
		end
	end
	do
		local i = 0
		while i < #taskIds do
			cleanupTaskHeavyData(taskIds[i + 1])
			i = i + 1
		end
	end
end
function getSessionRootId(session)
	return session.rootSessionId > 0 and session.rootSessionId or session.id
end
function getRootSessionItem(sessionId)
	local session = getSessionItem(sessionId)
	if not session then
		return nil
	end
	return getSessionItem(getSessionRootId(session)) or session
end
function listRelatedSessions(sessionId)
	local root = getRootSessionItem(sessionId)
	if not root then
		return {}
	end
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE id = ? OR root_session_id = ?\n\t\tORDER BY\n\t\t\tCASE kind WHEN 'main' THEN 0 ELSE 1 END ASC,\n\t\t\tid ASC", {root.id, root.id}) or ({})
	return __TS__ArrayMap(
		rows,
		function(____, row) return normalizeSessionRuntimeState(rowToSession(row)) end
	)
end
function getSessionSpawnInfo(session)
	local info = readSpawnInfo(session.projectRoot, session.memoryScope)
	if not info then
		return nil
	end
	local ____temp_17 = type(info.sessionId) == "number" and info.sessionId or nil
	local ____temp_18 = type(info.rootSessionId) == "number" and info.rootSessionId or nil
	local ____temp_19 = type(info.parentSessionId) == "number" and info.parentSessionId or nil
	local ____temp_20 = type(info.title) == "string" and sanitizeUTF8(info.title) or nil
	local ____temp_21 = type(info.prompt) == "string" and sanitizeUTF8(info.prompt) or ""
	local ____temp_22 = type(info.goal) == "string" and sanitizeUTF8(info.goal) or ""
	local ____temp_23 = type(info.expectedOutput) == "string" and sanitizeUTF8(info.expectedOutput) or nil
	local ____temp_24 = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap(
		__TS__ArrayFilter(
			info.filesHint,
			function(____, item) return type(item) == "string" end
		),
		function(____, item) return sanitizeUTF8(item) end
	) or nil
	local ____temp_25 = sanitizeUTF8(toStr(info.status)) == "FAILED" and "FAILED" or (sanitizeUTF8(toStr(info.status)) == "STOPPED" and "STOPPED" or (sanitizeUTF8(toStr(info.status)) == "DONE" and "DONE" or (sanitizeUTF8(toStr(info.status)) == "RUNNING" and "RUNNING" or nil)))
	local ____temp_15
	if info.success == true then
		____temp_15 = true
	else
		local ____temp_14
		if info.success == false then
			____temp_14 = false
		else
			____temp_14 = nil
		end
		____temp_15 = ____temp_14
	end
	local ____temp_16
	if info.cleared == true then
		____temp_16 = true
	else
		____temp_16 = nil
	end
	return {
		sessionId = ____temp_17,
		rootSessionId = ____temp_18,
		parentSessionId = ____temp_19,
		title = ____temp_20,
		prompt = ____temp_21,
		goal = ____temp_22,
		expectedOutput = ____temp_23,
		filesHint = ____temp_24,
		status = ____temp_25,
		success = ____temp_15,
		cleared = ____temp_16,
		resultFilePath = type(info.resultFilePath) == "string" and sanitizeUTF8(info.resultFilePath) or nil,
		artifactDir = type(info.artifactDir) == "string" and sanitizeUTF8(info.artifactDir) or nil,
		sourceTaskId = type(info.sourceTaskId) == "number" and info.sourceTaskId or nil,
		changeSet = decodeChangeSetSummary(info.changeSet),
		handoffEvidence = decodeHandoffEvidence(info.handoffEvidence),
		memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry),
		memoryEntryError = type(info.memoryEntryError) == "string" and sanitizeUTF8(info.memoryEntryError) or nil,
		completion = info.completion and not __TS__ArrayIsArray(info.completion) and type(info.completion) == "table" and normalizeAgentCompletionReport(info.completion) or nil,
		createdAt = type(info.createdAt) == "string" and sanitizeUTF8(info.createdAt) or nil,
		finishedAt = type(info.finishedAt) == "string" and sanitizeUTF8(info.finishedAt) or nil,
		createdAtTs = type(info.createdAtTs) == "number" and info.createdAtTs or nil,
		finishedAtTs = type(info.finishedAtTs) == "number" and info.finishedAtTs or nil
	}
end
function ensureDirRecursive(dir)
	if dir == "" then
		return false
	end
	if Content:exist(dir) then
		return Content:isdir(dir)
	end
	local parent = Path:getPath(dir)
	if parent ~= "" and parent ~= dir and not Content:exist(parent) then
		if not ensureDirRecursive(parent) then
			return false
		end
	end
	return Content:mkdir(dir)
end
function writeSpawnInfo(projectRoot, memoryScope, value)
	local dir = Path(projectRoot, ".agent", memoryScope)
	if not Content:exist(dir) then
		ensureDirRecursive(dir)
	end
	local path = Path(dir, SPAWN_INFO_FILE)
	local text = safeJsonEncode(value)
	if not text then
		return false
	end
	local content = text .. "\n"
	if not Content:save(path, content) then
		return false
	end
	Tools.sendWebIDEFileUpdate(path, true, content)
	return true
end
function readSpawnInfo(projectRoot, memoryScope)
	local path = Path(projectRoot, ".agent", memoryScope, SPAWN_INFO_FILE)
	if not Content:exist(path) then
		return nil
	end
	local text = Content:load(path)
	if type(text) ~= "string" or __TS__StringTrim(text) == "" then
		return nil
	end
	local value = safeJsonDecode(text)
	if value and not __TS__ArrayIsArray(value) and type(value) == "table" then
		return value
	end
	return nil
end
function getArtifactRelativeDir(memoryScope)
	return Path(".agent", memoryScope)
end
function getArtifactDir(projectRoot, memoryScope)
	return Path(
		projectRoot,
		getArtifactRelativeDir(memoryScope)
	)
end
function getResultRelativePath(memoryScope)
	return Path(
		getArtifactRelativeDir(memoryScope),
		RESULT_FILE
	)
end
function getResultPath(projectRoot, memoryScope)
	return Path(
		projectRoot,
		getResultRelativePath(memoryScope)
	)
end
function readSubAgentResultSummary(projectRoot, resultFilePath)
	if resultFilePath == "" then
		return ""
	end
	local path = Path(projectRoot, resultFilePath)
	if not Content:exist(path) then
		return ""
	end
	local text = sanitizeUTF8(Content:load(path))
	if __TS__StringTrim(text) == "" then
		return ""
	end
	local marker = "\n## Summary\n"
	local start = string.find(text, marker, 1, true)
	if start ~= nil then
		return __TS__StringTrim(string.sub(text, start + #marker))
	end
	return __TS__StringTrim(text)
end
function buildStructuredSubAgentMemoryEntry(record)
	local hasPassedValidation = false
	do
		local i = 0
		while i < #record.completion.validation do
			local result = record.completion.validation[i + 1].result
			if result == "failed" then
				return nil
			end
			if result == "passed" then
				hasPassedValidation = true
			end
			i = i + 1
		end
	end
	if not hasPassedValidation then
		return nil
	end
	local candidates = record.completion.learningCandidates
	local claims = {}
	local evidence = {}
	do
		local i = 0
		while i < #candidates do
			do
				local candidate = candidates[i + 1]
				if candidate.confidence ~= "observed" or #candidate.evidence == 0 then
					goto __continue195
				end
				claims[#claims + 1] = (("[" .. candidate.scope) .. "] ") .. candidate.claim
				do
					local j = 0
					while j < #candidate.evidence and #evidence < SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS do
						local item = candidate.evidence[j + 1]
						if __TS__ArrayIndexOf(evidence, item) < 0 then
							evidence[#evidence + 1] = item
						end
						j = j + 1
					end
				end
			end
			::__continue195::
			i = i + 1
		end
	end
	local content = takeUtf8Head(
		table.concat(claims, "\n"),
		SUB_AGENT_MEMORY_ENTRY_MAX_CHARS
	)
	if content == "" then
		return nil
	end
	return {
		sourceSessionId = record.sessionId,
		sourceTaskId = record.sourceTaskId,
		content = content,
		evidence = evidence,
		createdAt = record.finishedAt
	}
end
function containsNormalizedText(text, query)
	local normalizedText = string.lower(sanitizeUTF8(text or ""))
	local normalizedQuery = string.lower(sanitizeUTF8(query or ""))
	if normalizedQuery == "" then
		return true
	end
	return ({string.find(normalizedText, normalizedQuery, 1, true)}) ~= nil
end
function getSubAgentDisplayKey(item)
	local goal = string.lower(__TS__StringTrim(sanitizeUTF8(item.goal or "")))
	local title = string.lower(__TS__StringTrim(sanitizeUTF8(item.title or "")))
	local label = goal ~= "" and goal or title
	return (((tostring(item.rootSessionId) .. ":") .. tostring(item.parentSessionId or 0)) .. ":") .. label
end
function writeSubAgentResultFile(session, record, resultText)
	local dir = getArtifactDir(session.projectRoot, session.memoryScope)
	if not Content:exist(dir) then
		ensureDirRecursive(dir)
	end
	local ____array_34 = __TS__SparseArrayNew(
		"# " .. (record.title ~= "" and record.title or "Sub Agent " .. tostring(record.sessionId)),
		"- Status: " .. record.status,
		"- Success: " .. (record.success and "true" or "false"),
		"- Outcome: " .. record.completion.outcome,
		"- Session ID: " .. tostring(record.sessionId),
		"- Source Task ID: " .. tostring(record.sourceTaskId),
		"- Goal: " .. record.goal,
		table.unpack(record.expectedOutput and record.expectedOutput ~= "" and ({"- Expected Output: " .. record.expectedOutput}) or ({}))
	)
	__TS__SparseArrayPush(
		____array_34,
		table.unpack(record.filesHint and #record.filesHint > 0 and ({"- Files Hint: " .. table.concat(record.filesHint, ", ")}) or ({}))
	)
	__TS__SparseArrayPush(
		____array_34,
		"- Finished At: " .. record.finishedAt,
		"",
		"## Validation",
		table.unpack(#record.completion.validation > 0 and __TS__ArrayMap(
			record.completion.validation,
			function(____, item) return ((("- " .. item.kind) .. ": ") .. item.result) .. (#item.evidence > 0 and (" (" .. table.concat(item.evidence, "; ")) .. ")" or "") end
		) or ({"- Not reported"}))
	)
	__TS__SparseArrayPush(____array_34, "", "## Recorded Evidence")
	local ____opt_26 = record.handoffEvidence
	__TS__SparseArrayPush(
		____array_34,
		table.unpack(____opt_26 and #____opt_26.modifiedFiles and __TS__ArrayMap(
			record.handoffEvidence.modifiedFiles,
			function(____, item) return "- modified: " .. item end
		) or ({"- modified: none recorded"}))
	)
	local ____opt_28 = record.handoffEvidence
	__TS__SparseArrayPush(
		____array_34,
		table.unpack(____opt_28 and ____opt_28.lastBuild and ({((((("- last build: " .. record.handoffEvidence.lastBuild.result) .. " path=") .. (record.handoffEvidence.lastBuild.path ~= "" and record.handoffEvidence.lastBuild.path or ".")) .. " (") .. record.handoffEvidence.lastBuild.evidence) .. ")"}) or ({"- last build: not run"}))
	)
	local ____opt_30 = record.handoffEvidence
	__TS__SparseArrayPush(
		____array_34,
		table.unpack(__TS__ArrayMap(
			____opt_30 and ____opt_30.commands or ({}),
			function(____, item) return ((((((("- command: " .. item.result) .. " mode=") .. item.mode) .. " ") .. item.command) .. " (") .. item.evidence) .. ")" end
		))
	)
	local ____opt_32 = record.handoffEvidence
	__TS__SparseArrayPush(
		____array_34,
		table.unpack(__TS__ArrayMap(
			____opt_32 and ____opt_32.authoritativeSources or ({}),
			function(____, item) return (((("- authoritative source: " .. item.result) .. " ") .. item.source) .. " query=") .. item.query end
		))
	)
	__TS__SparseArrayPush(
		____array_34,
		"",
		"## Known Issues",
		table.unpack(#record.completion.knownIssues > 0 and __TS__ArrayMap(
			record.completion.knownIssues,
			function(____, item) return "- " .. item end
		) or ({"- None reported"}))
	)
	__TS__SparseArrayPush(
		____array_34,
		"",
		"## Assumptions",
		table.unpack(#record.completion.assumptions > 0 and __TS__ArrayMap(
			record.completion.assumptions,
			function(____, item) return "- " .. item end
		) or ({"- None reported"}))
	)
	__TS__SparseArrayPush(____array_34, "", "## Summary", resultText ~= "" and resultText or "(empty)")
	local lines = {__TS__SparseArraySpread(____array_34)}
	local path = getResultPath(session.projectRoot, session.memoryScope)
	local content = table.concat(lines, "\n") .. "\n"
	if not Content:save(path, content) then
		return false
	end
	Tools.sendWebIDEFileUpdate(path, true, content)
	return true
end
function listSubAgentResultRecords(projectRoot, rootSessionId)
	local dir = Path(projectRoot, ".agent", "subagents")
	if not Content:exist(dir) or not Content:isdir(dir) then
		return {}
	end
	local items = {}
	for ____, rawPath in ipairs(Content:getDirs(dir)) do
		do
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath)
			if not Content:exist(path) or not Content:isdir(path) then
				goto __continue215
			end
			local info = readSpawnInfo(
				projectRoot,
				Path(
					"subagents",
					Path:getFilename(path)
				)
			)
			if not info then
				goto __continue215
			end
			local sessionId = tonumber(info.sessionId)
			local infoRootSessionId = tonumber(info.rootSessionId)
			local sourceTaskId = tonumber(info.sourceTaskId)
			local status = sanitizeUTF8(toStr(info.status))
			if not (sessionId and sessionId > 0) or not (infoRootSessionId and infoRootSessionId > 0) or infoRootSessionId ~= rootSessionId then
				goto __continue215
			end
			if status ~= "DONE" and status ~= "FAILED" and status ~= "STOPPED" then
				goto __continue215
			end
			local artifactDir = sanitizeUTF8(toStr(info.artifactDir))
			items[#items + 1] = {
				sessionId = sessionId,
				rootSessionId = infoRootSessionId,
				parentSessionId = tonumber(info.parentSessionId) or nil,
				title = sanitizeUTF8(toStr(info.title)),
				prompt = sanitizeUTF8(toStr(info.prompt)),
				goal = sanitizeUTF8(toStr(info.goal)),
				expectedOutput = sanitizeUTF8(toStr(info.expectedOutput)),
				filesHint = __TS__ArrayIsArray(info.filesHint) and __TS__ArrayMap(
					__TS__ArrayFilter(
						info.filesHint,
						function(____, item) return type(item) == "string" end
					),
					function(____, item) return sanitizeUTF8(item) end
				) or ({}),
				status = status == "FAILED" and "FAILED" or (status == "STOPPED" and "STOPPED" or "DONE"),
				success = info.success == true,
				cleared = info.cleared == true,
				resultFilePath = sanitizeUTF8(toStr(info.resultFilePath)),
				artifactDir = artifactDir ~= "" and artifactDir or getArtifactRelativeDir(Path(
					"subagents",
					Path:getFilename(path)
				)),
				sourceTaskId = sourceTaskId or 0,
				changeSet = decodeChangeSetSummary(info.changeSet),
				handoffEvidence = decodeHandoffEvidence(info.handoffEvidence),
				memoryEntry = decodeSubAgentMemoryEntry(info.memoryEntry),
				memoryEntryError = sanitizeUTF8(toStr(info.memoryEntryError)),
				completion = normalizeAgentCompletionReport(info.completion),
				createdAt = sanitizeUTF8(toStr(info.createdAt)),
				finishedAt = sanitizeUTF8(toStr(info.finishedAt)),
				createdAtTs = tonumber(info.createdAtTs) or 0,
				finishedAtTs = tonumber(info.finishedAtTs) or 0
			}
		end
		::__continue215::
	end
	__TS__ArraySort(
		items,
		function(____, a, b) return a.finishedAtTs > b.finishedAtTs and -1 or (a.finishedAtTs < b.finishedAtTs and 1 or 0) end
	)
	return items
end
function getPendingHandoffDir(projectRoot, memoryScope)
	return Path(projectRoot, ".agent", memoryScope, PENDING_HANDOFF_DIR)
end
function writePendingHandoff(projectRoot, memoryScope, value)
	local dir = getPendingHandoffDir(projectRoot, memoryScope)
	if not Content:exist(dir) then
		ensureDirRecursive(dir)
	end
	local path = Path(dir, value.id .. ".json")
	local text = safeJsonEncode(value)
	if not text then
		return false
	end
	local content = text .. "\n"
	if not Content:save(path, content) then
		return false
	end
	Tools.sendWebIDEFileUpdate(path, true, content)
	return true
end
function listPendingHandoffs(projectRoot, memoryScope)
	local dir = getPendingHandoffDir(projectRoot, memoryScope)
	if not Content:exist(dir) or not Content:isdir(dir) then
		return {}
	end
	local items = {}
	for ____, rawPath in ipairs(Content:getFiles(dir)) do
		do
			local path = Content:isAbsolutePath(rawPath) and rawPath or Path(dir, rawPath)
			if not __TS__StringEndsWith(path, ".json") or not Content:exist(path) then
				goto __continue231
			end
			local text = Content:load(path)
			if type(text) ~= "string" or __TS__StringTrim(text) == "" then
				goto __continue231
			end
			local obj = safeJsonDecode(text)
			if not obj or __TS__ArrayIsArray(obj) or type(obj) ~= "table" then
				goto __continue231
			end
			local value = obj
			local sourceTaskId = tonumber(value.sourceTaskId)
			local sourceSessionId = tonumber(value.sourceSessionId)
			local id = sanitizeUTF8(toStr(value.id))
			local sourceTitle = sanitizeUTF8(toStr(value.sourceTitle))
			local message = sanitizeUTF8(toStr(value.message))
			local prompt = sanitizeUTF8(toStr(value.prompt))
			local goal = sanitizeUTF8(toStr(value.goal))
			local createdAt = sanitizeUTF8(toStr(value.createdAt))
			if not (sourceTaskId and sourceTaskId > 0) or not (sourceSessionId and sourceSessionId > 0) or id == "" or createdAt == "" then
				goto __continue231
			end
			items[#items + 1] = {
				id = id,
				sourceSessionId = sourceSessionId,
				sourceTitle = sourceTitle,
				sourceTaskId = sourceTaskId,
				message = message,
				prompt = prompt,
				goal = goal,
				expectedOutput = sanitizeUTF8(toStr(value.expectedOutput)),
				filesHint = __TS__ArrayIsArray(value.filesHint) and __TS__ArrayMap(
					__TS__ArrayFilter(
						value.filesHint,
						function(____, item) return type(item) == "string" end
					),
					function(____, item) return sanitizeUTF8(item) end
				) or ({}),
				success = value.success == true,
				resultFilePath = sanitizeUTF8(toStr(value.resultFilePath)),
				artifactDir = sanitizeUTF8(toStr(value.artifactDir)),
				finishedAt = sanitizeUTF8(toStr(value.finishedAt)),
				changeSet = decodeChangeSetSummary(value.changeSet),
				handoffEvidence = decodeHandoffEvidence(value.handoffEvidence),
				memoryEntry = decodeSubAgentMemoryEntry(value.memoryEntry),
				completion = value.completion and not __TS__ArrayIsArray(value.completion) and type(value.completion) == "table" and normalizeAgentCompletionReport(value.completion) or nil,
				createdAt = createdAt
			}
		end
		::__continue231::
	end
	__TS__ArraySort(
		items,
		function(____, a, b) return a.id < b.id and -1 or (a.id > b.id and 1 or 0) end
	)
	return items
end
function deletePendingHandoff(projectRoot, memoryScope, id)
	local path = Path(
		getPendingHandoffDir(projectRoot, memoryScope),
		id .. ".json"
	)
	if Content:exist(path) then
		if Content:remove(path) then
			Tools.sendWebIDEFileUpdate(path, false, "")
		end
	end
end
function normalizePromptText(prompt)
	return __TS__StringTrim(truncateAgentUserPrompt(prompt or ""))
end
function normalizePromptTextSafe(prompt)
	if type(prompt) == "string" then
		local normalized = normalizePromptText(prompt)
		if normalized ~= "" then
			return normalized
		end
		local sanitized = __TS__StringTrim(sanitizeUTF8(prompt))
		if sanitized ~= "" then
			return truncateAgentUserPrompt(sanitized)
		end
		return ""
	end
	local text = __TS__StringTrim(sanitizeUTF8(toStr(prompt)))
	if text == "" then
		return ""
	end
	return truncateAgentUserPrompt(text)
end
function buildSubAgentPromptFallback(title, expectedOutput, filesHint)
	local sections = {}
	local normalizedTitle = __TS__StringTrim(sanitizeUTF8(title or ""))
	local normalizedExpected = __TS__StringTrim(sanitizeUTF8(expectedOutput or ""))
	local normalizedFiles = __TS__ArrayFilter(
		__TS__ArrayMap(
			__TS__ArrayFilter(
				filesHint or ({}),
				function(____, item) return type(item) == "string" end
			),
			function(____, item) return __TS__StringTrim(sanitizeUTF8(item)) end
		),
		function(____, item) return item ~= "" end
	)
	if normalizedTitle ~= "" then
		sections[#sections + 1] = "Task: " .. normalizedTitle
	end
	if normalizedExpected ~= "" then
		sections[#sections + 1] = "Expected output: " .. normalizedExpected
	end
	if #normalizedFiles > 0 then
		sections[#sections + 1] = "Files hint:\n- " .. table.concat(normalizedFiles, "\n- ")
	end
	return __TS__StringTrim(table.concat(sections, "\n\n"))
end
function normalizeSessionRuntimeState(session)
	if session.currentTaskId == nil or session.currentTaskStatus ~= "RUNNING" then
		return session
	end
	if activeStopTokens[session.currentTaskId] ~= nil then
		return session
	end
	if activeLocalAgentControls[session.currentTaskId] ~= nil then
		return session
	end
	local pendingToolRows = queryRows(("SELECT id, result_json FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND tool IN (?, ?, ?, ?) AND status IN ('PENDING', 'RUNNING')", {session.id, session.currentTaskId, "fetch_url", "execute_command"}) or ({})
	if #pendingToolRows > 0 then
		local t = now()
		do
			local i = 0
			while i < #pendingToolRows do
				local row = pendingToolRows[i + 1]
				local result = decodeJsonObject(toStr(row[2])) or ({})
				result.success = false
				result.state = "failed"
				result.interrupted = true
				result.message = "tool call was interrupted because the program exited before it completed."
				DB:exec(
					("UPDATE " .. TABLE_STEP) .. " SET status = 'FAILED', result_json = ?, updated_at = ? WHERE id = ?",
					{
						encodeJson(result),
						t,
						row[1]
					}
				)
				i = i + 1
			end
		end
		Tools.setTaskStatus(session.currentTaskId, "FAILED")
		setSessionState(session.id, "FAILED", session.currentTaskId, "FAILED")
		return __TS__ObjectAssign({}, session, {status = "FAILED", currentTaskStatus = "FAILED", updatedAt = t})
	end
	Tools.setTaskStatus(session.currentTaskId, "STOPPED")
	setSessionState(session.id, "STOPPED", session.currentTaskId, "STOPPED")
	return __TS__ObjectAssign(
		{},
		session,
		{
			status = "STOPPED",
			currentTaskStatus = "STOPPED",
			updatedAt = now()
		}
	)
end
function setSessionState(sessionId, status, currentTaskId, currentTaskStatus)
	DB:exec(
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET status = ?, current_task_id = ?, current_task_status = ?, updated_at = ?\n\t\tWHERE id = ?",
		{
			status,
			currentTaskId or 0,
			currentTaskStatus or status,
			now(),
			sessionId
		}
	)
end
function mergeAgentMetrics(current, next)
	return __TS__ObjectAssign({}, current or ({}), next)
end
function updateSessionMetrics(sessionId, metrics)
	local session = getSessionItem(sessionId)
	if not session then
		return nil
	end
	local merged = mergeAgentMetrics(session.metrics, metrics)
	DB:exec(
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?",
		{
			encodeJson(merged),
			now(),
			sessionId
		}
	)
	return merged
end
function clearSessionTokenUsage(sessionId)
	local session = getSessionItem(sessionId)
	if not session then
		return nil
	end
	local metrics = __TS__ObjectAssign({}, session.metrics or ({}))
	__TS__Delete(metrics, "usage")
	__TS__Delete(metrics, "visionUsage")
	DB:exec(
		("UPDATE " .. TABLE_SESSION) .. "\n\t\tSET metrics_json = ?, updated_at = ?\n\t\tWHERE id = ?",
		{
			encodeJson(metrics),
			now(),
			sessionId
		}
	)
	return metrics
end
function getInitialTokenUsage(session)
	local ____opt_35 = session.metrics
	local usage = ____opt_35 and ____opt_35.usage
	if not usage or (usage.requestCount or 0) <= 0 then
		return nil
	end
	return {
		inputTokens = usage.inputTokens or 0,
		outputTokens = usage.outputTokens or 0,
		totalTokens = usage.totalTokens,
		cachedInputTokens = usage.cachedInputTokens,
		cacheMissInputTokens = usage.cacheMissInputTokens,
		reasoningOutputTokens = usage.reasoningOutputTokens,
		requestCount = usage.requestCount or 0,
		cacheReportedRequestCount = usage.cacheReportedRequestCount,
		model = usage.model or "",
		phase = usage.phase or "",
		step = usage.step or 0,
		updatedAt = usage.updatedAt or now()
	}
end
function setSessionStateForTaskEvent(sessionId, taskId, status, currentTaskStatus)
	if taskId == nil or taskId <= 0 then
		setSessionState(sessionId, status, taskId, currentTaskStatus)
		return
	end
	local row = getSessionRow(sessionId)
	if not row then
		return
	end
	local session = rowToSession(row)
	if session.currentTaskId ~= taskId then
		Log(
			"Info",
			(((("[AgentSession] ignore stale task event session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(taskId)) .. " currentTask=") .. tostring(session.currentTaskId)
		)
		return
	end
	setSessionState(sessionId, status, taskId, currentTaskStatus)
end
function insertMessage(sessionId, role, content, taskId, displayContent)
	local t = now()
	DB:exec(
		("INSERT INTO " .. TABLE_MESSAGE) .. "(session_id, task_id, role, content, display_content, created_at, updated_at)\n\t\tVALUES(?, ?, ?, ?, ?, ?, ?)",
		{
			sessionId,
			taskId or 0,
			role,
			sanitizeUTF8(content),
			displayContent and sanitizeUTF8(displayContent) or "",
			t,
			t
		}
	)
	return getLastInsertRowId()
end
function updateMessage(messageId, content)
	DB:exec(
		("UPDATE " .. TABLE_MESSAGE) .. " SET content = ?, updated_at = ? WHERE id = ?",
		{
			sanitizeUTF8(content),
			now(),
			messageId
		}
	)
end
function updateUserMessageForTask(messageId, content, taskId)
	DB:exec(
		("UPDATE " .. TABLE_MESSAGE) .. "\n\t\tSET content = ?, task_id = ?, updated_at = ?\n\t\tWHERE id = ?",
		{
			sanitizeUTF8(content),
			taskId,
			now(),
			messageId
		}
	)
end
function removeContinuableTaskSummary(session)
	local taskId = session.currentTaskId
	if taskId == nil then
		return
	end
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND task_id = ? AND role = ?", {session.id, taskId, "assistant"})
end
function upsertAssistantMessage(sessionId, taskId, content)
	local row = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND task_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, taskId, "assistant"})
	if row and type(row[1]) == "number" then
		updateMessage(row[1], content)
		return row[1]
	end
	return insertMessage(sessionId, "assistant", content, taskId)
end
function upsertStep(sessionId, taskId, step, tool, patch)
	local row = queryOne(("SELECT id FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ? AND step = ?", {sessionId, taskId, step})
	local reason = sanitizeUTF8(patch.reason or "")
	local reasoningContent = sanitizeUTF8(patch.reasoningContent or "")
	local paramsJson = patch.params and encodeJson(patch.params) or ""
	local resultJson = patch.result and encodeJson(patch.result) or ""
	local filesJson = patch.files and encodeJson(patch.files) or ""
	local statusPatch = patch.status or ""
	local status = patch.status or "PENDING"
	if not row then
		local t = now()
		DB:exec(("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
			sessionId,
			taskId,
			step,
			tool,
			status,
			reason,
			reasoningContent,
			paramsJson,
			resultJson,
			patch.checkpointId or 0,
			patch.checkpointSeq or 0,
			filesJson,
			t,
			t
		})
		return
	end
	DB:exec(
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET tool = ?, status = CASE WHEN ? = '' THEN status ELSE ? END,\n\t\t\treason = CASE WHEN ? = '' THEN reason ELSE ? END,\n\t\t\treasoning_content = CASE WHEN ? = '' THEN reasoning_content ELSE ? END,\n\t\t\tparams_json = CASE WHEN ? = '' THEN params_json ELSE ? END,\n\t\t\tresult_json = CASE WHEN ? = '' THEN result_json ELSE ? END,\n\t\t\tcheckpoint_id = CASE WHEN ? > 0 THEN ? ELSE checkpoint_id END,\n\t\t\tcheckpoint_seq = CASE WHEN ? > 0 THEN ? ELSE checkpoint_seq END,\n\t\t\tfiles_json = CASE WHEN ? = '' THEN files_json ELSE ? END,\n\t\t\tupdated_at = ?\n\t\tWHERE id = ?",
		{
			tool,
			statusPatch,
			status,
			reason,
			reason,
			reasoningContent,
			reasoningContent,
			paramsJson,
			paramsJson,
			resultJson,
			resultJson,
			patch.checkpointId or 0,
			patch.checkpointId or 0,
			patch.checkpointSeq or 0,
			patch.checkpointSeq or 0,
			filesJson,
			filesJson,
			now(),
			row[1]
		}
	)
end
function getNextStepNumber(sessionId, taskId)
	local row = queryOne(("SELECT MAX(step) FROM " .. TABLE_STEP) .. " WHERE session_id = ? AND task_id = ?", {sessionId, taskId})
	local current = row and type(row[1]) == "number" and row[1] or 0
	return math.max(0, current) + 1
end
function appendHandoffSystemStep(sessionId, ownerTaskId, targetTaskId, reason, result, params)
	local step = getNextStepNumber(sessionId, ownerTaskId)
	local t = now()
	local sqls = {
		{
			("INSERT INTO " .. TABLE_STEP) .. "(session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at)\n\t\t\tVALUES(?, ?, ?, ?, ?, ?, '', ?, ?, 0, 0, '', ?, ?)",
			{{
				sessionId,
				ownerTaskId,
				step,
				"sub_agent_handoff",
				"DONE",
				sanitizeUTF8(reason),
				encodeJson(params),
				encodeJson(result),
				t,
				t
			}}
		},
		{("INSERT OR IGNORE INTO " .. TABLE_TASK_REFERENCE) .. "(owner_task_id, target_task_id, kind, created_at)\n\t\t\tVALUES(?, ?, 'sub_agent_handoff', ?)", {{ownerTaskId, targetTaskId, t}}}
	}
	if not DB:transaction(sqls) then
		return nil
	end
	return getStepItem(sessionId, ownerTaskId, step)
end
function finalizeTaskSteps(sessionId, taskId, finalSteps, finalStatus)
	if taskId <= 0 then
		return
	end
	if finalSteps ~= nil and finalSteps >= 0 then
		DB:exec(("DELETE FROM " .. TABLE_STEP) .. "\n\t\t\tWHERE session_id = ? AND task_id = ? AND step > ?", {sessionId, taskId, finalSteps})
	end
	if not finalStatus then
		return
	end
	if finalSteps ~= nil and finalSteps >= 0 then
		DB:exec(
			("UPDATE " .. TABLE_STEP) .. "\n\t\t\tSET status = ?, updated_at = ?\n\t\t\tWHERE session_id = ? AND task_id = ? AND step <= ? AND status IN ('PENDING', 'RUNNING')",
			{
				finalStatus,
				now(),
				sessionId,
				taskId,
				finalSteps
			}
		)
		return
	end
	DB:exec(
		("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = ?, updated_at = ?\n\t\tWHERE session_id = ? AND task_id = ? AND status IN ('PENDING', 'RUNNING')",
		{
			finalStatus,
			now(),
			sessionId,
			taskId
		}
	)
end
function emitAgentSessionPatch(sessionId, patch)
	local text = safeJsonEncode(__TS__ObjectAssign({name = "AgentSessionPatch", sessionId = sessionId}, patch))
	if not text then
		return
	end
	local failed = publishSessionPatch(sessionId, text)
	if failed > 0 then
		Log(
			"Warn",
			("[AgentSession] " .. tostring(failed)) .. " patch subscribers failed"
		)
	end
	if HttpServer ~= nil and HttpServer.wsConnectionCount > 0 then
		emit("AppWS", "Send", text)
	end
end
function emitSessionDeletedPatch(sessionId, rootSessionId, projectRoot)
	emitAgentSessionPatch(
		sessionId,
		{
			sessionDeleted = true,
			relatedSessions = listRelatedSessions(rootSessionId)
		}
	)
	local rootSession = getSessionItem(rootSessionId)
	if rootSession then
		emitAgentSessionPatch(
			rootSessionId,
			{
				session = rootSession,
				relatedSessions = listRelatedSessions(rootSessionId)
			}
		)
	end
end
function flushPendingSubAgentHandoffs(rootSession)
	if rootSession.kind ~= "main" then
		return
	end
	if rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId] then
		return
	end
	local items = listPendingHandoffs(rootSession.projectRoot, rootSession.memoryScope)
	if #items == 0 then
		return
	end
	local handoffTaskId = 0
	local previousTaskId = rootSession.currentTaskId
	local ____rootSession_currentTaskId_39
	if rootSession.currentTaskId then
		____rootSession_currentTaskId_39 = getTaskPrompt(rootSession.currentTaskId)
	else
		____rootSession_currentTaskId_39 = nil
	end
	local currentTaskPrompt = ____rootSession_currentTaskId_39
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 and rootSession.currentTaskStatus ~= "RUNNING" and type(currentTaskPrompt) == "string" and __TS__StringStartsWith(currentTaskPrompt, "[sub_agent_handoff]") then
		handoffTaskId = rootSession.currentTaskId
	else
		local taskRes = Tools.createTask(
			("[sub_agent_handoff] " .. tostring(#items)) .. " item(s)",
			"code"
		)
		if not taskRes.success then
			Log(
				"Warn",
				(("[AgentSession] failed to create sub-agent handoff task for root=" .. tostring(rootSession.id)) .. ": ") .. taskRes.message
			)
			return
		end
		handoffTaskId = taskRes.taskId
		Tools.setTaskStatus(handoffTaskId, "DONE")
		setSessionState(rootSession.id, "DONE", handoffTaskId, "DONE")
		emitAgentSessionPatch(
			rootSession.id,
			{session = getSessionItem(rootSession.id)}
		)
	end
	do
		local i = 0
		while i < #items do
			local item = items[i + 1]
			local step = appendHandoffSystemStep(
				rootSession.id,
				handoffTaskId,
				item.sourceTaskId,
				item.message,
				{
					sourceSessionId = item.sourceSessionId,
					sourceTitle = item.sourceTitle,
					sourceTaskId = item.sourceTaskId,
					success = item.success == true,
					summary = item.message,
					resultFilePath = item.resultFilePath or "",
					artifactDir = item.artifactDir or "",
					finishedAt = item.finishedAt or "",
					changeSet = item.changeSet,
					handoffEvidence = item.handoffEvidence,
					memoryEntry = item.memoryEntry,
					completion = item.completion
				},
				{
					sourceSessionId = item.sourceSessionId,
					sourceTitle = item.sourceTitle,
					sourceTaskId = item.sourceTaskId,
					prompt = item.prompt,
					goal = item.goal ~= "" and item.goal or item.sourceTitle,
					expectedOutput = item.expectedOutput or "",
					filesHint = item.filesHint or ({}),
					resultFilePath = item.resultFilePath or "",
					artifactDir = item.artifactDir or "",
					changeSet = item.changeSet,
					handoffEvidence = item.handoffEvidence,
					memoryEntry = item.memoryEntry,
					completion = item.completion
				}
			)
			if step then
				emitAgentSessionPatch(rootSession.id, {step = step})
				deletePendingHandoff(rootSession.projectRoot, rootSession.memoryScope, item.id)
			else
				Log(
					"Warn",
					(("[AgentSession] failed to persist sub-agent handoff reference owner=" .. tostring(handoffTaskId)) .. " target=") .. tostring(item.sourceTaskId)
				)
			end
			i = i + 1
		end
	end
	if previousTaskId and previousTaskId ~= handoffTaskId then
		cleanupTaskHeavyData(previousTaskId)
	end
end
function applyEvent(sessionId, event)
	if not getSessionItem(sessionId) then
		streamUpdates:clear(sessionId)
		if (event.type == "task_finished" or event.type == "task_waiting_for_user") and event.taskId ~= nil then
			__TS__Delete(activeStopTokens, event.taskId)
			__TS__Delete(finalizingSubSessionTaskIds, event.taskId)
		end
		return
	end
	repeat
		local ____switch326 = event.type
		local metrics, startedSession
		local ____cond326 = ____switch326 == "task_started"
		if ____cond326 then
			streamUpdates:clear(sessionId)
			setSessionStateForTaskEvent(sessionId, event.taskId, "RUNNING", "RUNNING")
			local ____event_resumed_42
			if event.resumed then
				local ____opt_40 = getSessionItem(sessionId)
				____event_resumed_42 = ____opt_40 and ____opt_40.metrics
			else
				____event_resumed_42 = clearSessionTokenUsage(sessionId)
			end
			metrics = ____event_resumed_42
			startedSession = getSessionItem(sessionId)
			emitAgentSessionPatch(
				sessionId,
				{
					session = startedSession,
					metrics = metrics,
					hasActivePlan = startedSession ~= nil and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(startedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE))
				}
			)
			break
		end
		____cond326 = ____cond326 or ____switch326 == "decision_made"
		if ____cond326 then
			upsertStep(
				sessionId,
				event.taskId,
				event.step,
				event.tool,
				{status = "PENDING", reason = event.reason, reasoningContent = event.reasoningContent, params = event.tool == "ask_user" and ({storage = PENDING_QUESTIONNAIRE_FILE}) or event.params}
			)
			emitAgentSessionPatch(
				sessionId,
				{step = getStepItem(sessionId, event.taskId, event.step)}
			)
			break
		end
		____cond326 = ____cond326 or ____switch326 == "tool_started"
		if ____cond326 then
			upsertStep(
				sessionId,
				event.taskId,
				event.step,
				event.tool,
				{status = "RUNNING"}
			)
			emitAgentSessionPatch(
				sessionId,
				{step = getStepItem(sessionId, event.taskId, event.step)}
			)
			break
		end
		____cond326 = ____cond326 or ____switch326 == "tool_finished"
		if ____cond326 then
			do
				upsertStep(
					sessionId,
					event.taskId,
					event.step,
					event.tool,
					{status = event.execution.status, reason = event.reason, result = event.result}
				)
				emitAgentSessionPatch(
					sessionId,
					{step = getStepItem(sessionId, event.taskId, event.step)}
				)
				break
			end
		end
		____cond326 = ____cond326 or ____switch326 == "tool_progress"
		if ____cond326 then
			do
				local currentStep = getStepItem(sessionId, event.taskId, event.step)
				if currentStep and currentStep.status ~= "PENDING" and currentStep.status ~= "RUNNING" then
					break
				end
			end
			upsertStep(
				sessionId,
				event.taskId,
				event.step,
				event.tool,
				{status = "RUNNING", result = event.result}
			)
			emitAgentSessionPatch(
				sessionId,
				{step = getStepItem(sessionId, event.taskId, event.step)}
			)
			break
		end
		____cond326 = ____cond326 or ____switch326 == "checkpoint_created"
		if ____cond326 then
			upsertStep(
				sessionId,
				event.taskId,
				event.step,
				event.tool,
				{checkpointId = event.checkpointId, checkpointSeq = event.checkpointSeq, files = event.files}
			)
			emitAgentSessionPatch(
				sessionId,
				{
					step = getStepItem(sessionId, event.taskId, event.step),
					checkpoint = Tools.getCheckpoint(event.checkpointId)
				}
			)
			break
		end
		____cond326 = ____cond326 or ____switch326 == "memory_compression_started"
		if ____cond326 then
			upsertStep(
				sessionId,
				event.taskId,
				event.step,
				event.tool,
				{status = "RUNNING", reason = event.reason, params = event.params}
			)
			emitAgentSessionPatch(
				sessionId,
				{step = getStepItem(sessionId, event.taskId, event.step)}
			)
			break
		end
		____cond326 = ____cond326 or ____switch326 == "memory_compression_finished"
		if ____cond326 then
			upsertStep(
				sessionId,
				event.taskId,
				event.step,
				event.tool,
				{status = event.result.success == true and "DONE" or "FAILED", reason = event.reason, result = event.result}
			)
			emitAgentSessionPatch(
				sessionId,
				{step = getStepItem(sessionId, event.taskId, event.step)}
			)
			break
		end
		____cond326 = ____cond326 or ____switch326 == "metrics_updated"
		if ____cond326 then
			do
				local metrics = updateSessionMetrics(sessionId, event.metrics)
				emitAgentSessionPatch(sessionId, {metrics = metrics})
				break
			end
		end
		____cond326 = ____cond326 or ____switch326 == "assistant_message_updated"
		if ____cond326 then
			do
				local session = getSessionItem(sessionId)
				if (session and session.currentTaskId) ~= event.taskId then
					streamUpdates:clear(sessionId, event.taskId)
					break
				end
				streamUpdates:update(
					sessionId,
					event.taskId,
					event.step,
					event,
					App.runningTime
				)
				scheduleStreamFlush()
				break
			end
		end
		____cond326 = ____cond326 or ____switch326 == "assistant_message_finished"
		if ____cond326 then
			do
				local ____opt_45 = getSessionItem(sessionId)
				if (____opt_45 and ____opt_45.currentTaskId) ~= event.taskId then
					streamUpdates:clear(sessionId, event.taskId)
					break
				end
				streamUpdates:finish(sessionId, event.taskId, event.step)
				upsertStep(
					sessionId,
					event.taskId,
					event.step,
					"message",
					{status = "DONE", reason = event.content, reasoningContent = event.reasoningContent, result = event.result}
				)
				emitAgentSessionPatch(
					sessionId,
					{step = getStepItem(sessionId, event.taskId, event.step)}
				)
				break
			end
		end
		____cond326 = ____cond326 or ____switch326 == "task_waiting_for_user"
		if ____cond326 then
			do
				local ____opt_47 = getSessionItem(sessionId)
				if (____opt_47 and ____opt_47.currentTaskId) ~= event.taskId then
					streamUpdates:clear(sessionId, event.taskId)
					break
				end
				streamUpdates:clear(sessionId, event.taskId, App.runningTime)
				setSessionStateForTaskEvent(sessionId, event.taskId, "WAITING_USER", "WAITING_USER")
				__TS__Delete(activeStopTokens, event.taskId)
				emitAgentSessionPatch(
					sessionId,
					{
						session = getSessionItem(sessionId),
						pendingQuestionnaire = getPendingQuestionnaire(sessionId)
					}
				)
				break
			end
		end
		____cond326 = ____cond326 or ____switch326 == "task_finished"
		if ____cond326 then
			do
				local session = getSessionItem(sessionId)
				if session and event.taskId ~= nil and session.currentTaskId ~= event.taskId then
					__TS__Delete(activeStopTokens, event.taskId)
					streamUpdates:clear(sessionId, event.taskId)
					Log(
						"Info",
						(((("[AgentSession] ignore stale task finish session=" .. tostring(sessionId)) .. " eventTask=") .. tostring(event.taskId)) .. " currentTask=") .. tostring(session.currentTaskId)
					)
					break
				end
				streamUpdates:clear(sessionId, event.taskId, App.runningTime)
				local ____opt_49 = activeStopTokens[event.taskId or -1]
				local stopped = (____opt_49 and ____opt_49.stopped) == true or session ~= nil and session.currentTaskId == event.taskId and session.currentTaskStatus == "STOPPED"
				local finalStatus = event.success and "DONE" or (stopped and "STOPPED" or "FAILED")
				local isSubSession = (session and session.kind) == "sub"
				local sessionStatus = isSubSession and "RUNNING" or finalStatus
				if isSubSession and event.taskId ~= nil then
					finalizingSubSessionTaskIds[event.taskId] = true
				end
				setSessionStateForTaskEvent(sessionId, event.taskId, sessionStatus, sessionStatus)
				if event.taskId ~= nil then
					local removedStepIds = deleteMessageSteps(sessionId, event.taskId)
					local ____finalizeTaskSteps_55 = finalizeTaskSteps
					local ____array_54 = __TS__SparseArrayNew(
						sessionId,
						event.taskId,
						type(event.steps) == "number" and math.max(
							0,
							math.floor(event.steps)
						) or nil
					)
					local ____event_success_53
					if event.success then
						____event_success_53 = nil
					else
						____event_success_53 = stopped and "STOPPED" or "FAILED"
					end
					__TS__SparseArrayPush(____array_54, ____event_success_53)
					____finalizeTaskSteps_55(__TS__SparseArraySpread(____array_54))
					local messageId = upsertAssistantMessage(sessionId, event.taskId, event.message)
					if not isSubSession then
						__TS__Delete(activeStopTokens, event.taskId)
					end
					emitAgentSessionPatch(
						sessionId,
						{
							session = getSessionItem(sessionId),
							message = getMessageItem(messageId),
							removedStepIds = removedStepIds
						}
					)
				end
				if session and session.kind == "main" then
					flushPendingSubAgentHandoffs(session)
				end
				break
			end
		end
	until true
end
function ____exports.createSession(projectRoot, title)
	if title == nil then
		title = ""
	end
	local storage = requireAgentStorage()
	if not storage.success then
		return storage
	end
	if not isValidProjectRoot(projectRoot) then
		return {success = false, message = "invalid projectRoot"}
	end
	local row = queryOne(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE project_root = ? AND kind = 'main'\n\t\tORDER BY updated_at DESC, id DESC\n\t\tLIMIT 1", {projectRoot})
	if row then
		return {
			success = true,
			session = restorePendingQuestionnaireState(rowToSession(row)).session
		}
	end
	local t = now()
	DB:exec(
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at, work_mode)\n\t\tVALUES(?, ?, 'main', 0, 0, 'main', 'IDLE', 'IDLE', ?, ?, 'code')",
		{
			projectRoot,
			title ~= "" and title or Path:getFilename(projectRoot),
			t,
			t
		}
	)
	local sessionId = getLastInsertRowId()
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET root_session_id = ? WHERE id = ?", {sessionId, sessionId})
	local session = getSessionItem(sessionId)
	if not session then
		return {success = false, message = "failed to create session"}
	end
	return {success = true, session = session}
end
function ____exports.createSubSession(parentSessionId, title)
	if title == nil then
		title = ""
	end
	local storage = requireAgentStorage()
	if not storage.success then
		return storage
	end
	local parent = getSessionItem(parentSessionId)
	if not parent then
		return {success = false, message = "parent session not found"}
	end
	local rootId = getSessionRootId(parent)
	if isProjectTaskAdmissionClosed(parent.projectRoot) then
		return {success = false, message = "project task admission is closed"}
	end
	local t = now()
	DB:exec(
		("INSERT INTO " .. TABLE_SESSION) .. "(project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_status, created_at, updated_at)\n\t\tVALUES(?, ?, 'sub', ?, ?, '', 'IDLE', 'IDLE', ?, ?)",
		{
			parent.projectRoot,
			title ~= "" and title or "Sub " .. tostring(rootId),
			rootId,
			parent.id,
			t,
			t
		}
	)
	local sessionId = getLastInsertRowId()
	local memoryScope = "subagents/" .. tostring(sessionId)
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET memory_scope = ? WHERE id = ?", {memoryScope, sessionId})
	local session = getSessionItem(sessionId)
	if not session then
		return {success = false, message = "failed to create sub session"}
	end
	local parentStorage = __TS__New(DualLayerStorage, parent.projectRoot, parent.memoryScope)
	local subStorage = __TS__New(DualLayerStorage, parent.projectRoot, memoryScope)
	subStorage:writeMemory(parentStorage:readMemory())
	return {success = true, session = session}
end
function spawnSubAgentSession(request)
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local normalizedTitle = __TS__StringTrim(sanitizeUTF8(request.title or ""))
		local rawPrompt = type(request.prompt) == "string" and request.prompt or toStr(request.prompt)
		local normalizedPrompt = normalizePromptTextSafe(request.prompt)
		if normalizedPrompt == "" then
			normalizedPrompt = buildSubAgentPromptFallback(normalizedTitle, request.expectedOutput, request.filesHint)
		end
		if normalizedPrompt == "" then
			local ____Log_61 = Log
			local ____temp_58 = #normalizedTitle
			local ____temp_59 = #rawPrompt
			local ____temp_60 = #toStr(request.expectedOutput)
			local ____opt_56 = request.filesHint
			____Log_61(
				"Warn",
				(((((("[AgentSession] sub agent prompt empty title_len=" .. tostring(____temp_58)) .. " raw_prompt_len=") .. tostring(____temp_59)) .. " expected_len=") .. tostring(____temp_60)) .. " files_hint_count=") .. tostring(____opt_56 and #____opt_56 or 0)
			)
			return ____awaiter_resolve(nil, {success = false, message = "sub agent prompt is empty"})
		end
		Log(
			"Info",
			(((("[AgentSession] sub agent prompt prepared title_len=" .. tostring(#normalizedTitle)) .. " raw_prompt_len=") .. tostring(#rawPrompt)) .. " normalized_prompt_len=") .. tostring(#normalizedPrompt)
		)
		local parentSessionId = request.parentSessionId
		if not getSessionItem(parentSessionId) and request.projectRoot and request.projectRoot ~= "" then
			local fallbackParent = getLatestMainSessionByProjectRoot(request.projectRoot)
			if not fallbackParent then
				local createdMain = ____exports.createSession(request.projectRoot)
				if createdMain.success then
					fallbackParent = createdMain.session
				end
			end
			if fallbackParent then
				Log(
					"Warn",
					(((("[AgentSession] spawn fallback parent session requested=" .. tostring(request.parentSessionId)) .. " resolved=") .. tostring(fallbackParent.id)) .. " project=") .. request.projectRoot
				)
				parentSessionId = fallbackParent.id
			end
		end
		local parentSession = getSessionItem(parentSessionId)
		if not parentSession then
			return ____awaiter_resolve(nil, {success = false, message = "parent session not found"})
		end
		local runningSubSessionCount = countRunningSubSessions(getSessionRootId(parentSession))
		if isProjectTaskAdmissionClosed(parentSession.projectRoot) then
			return ____awaiter_resolve(nil, {success = false, message = "project task admission is closed"})
		end
		if runningSubSessionCount >= MAX_CONCURRENT_SUB_AGENTS then
			return ____awaiter_resolve(nil, {success = false, message = "已达到子代理并发上限，暂无法派出新的代理。"})
		end
		local created = ____exports.createSubSession(parentSessionId, request.title)
		if not created.success then
			return ____awaiter_resolve(nil, created)
		end
		writeSpawnInfo(
			created.session.projectRoot,
			created.session.memoryScope,
			{
				sessionId = created.session.id,
				rootSessionId = created.session.rootSessionId,
				parentSessionId = created.session.parentSessionId,
				title = created.session.title,
				prompt = normalizedPrompt,
				goal = normalizedTitle ~= "" and normalizedTitle or request.title,
				expectedOutput = request.expectedOutput or "",
				filesHint = request.filesHint or ({}),
				status = "RUNNING",
				success = false,
				resultFilePath = "",
				artifactDir = getArtifactRelativeDir(created.session.memoryScope),
				sourceTaskId = 0,
				createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ"),
				createdAtTs = created.session.createdAt,
				finishedAt = "",
				finishedAtTs = 0
			}
		)
		local sent = ____exports.sendPrompt(
			created.session.id,
			normalizedPrompt,
			request.disabledAgentTools,
			nil,
			nil,
			request.llmConfig
		)
		if not sent.success then
			return ____awaiter_resolve(nil, {success = false, message = sent.message})
		end
		return ____awaiter_resolve(nil, {success = true, sessionId = created.session.id, taskId = sent.taskId, title = created.session.title})
	end)
end
function appendSubAgentHandoffStep(session, taskId, result, summary)
	local rootSession = getRootSessionItem(session.id)
	if not rootSession then
		return
	end
	local changeSet = result.changeSet or getTaskChangeSetSummary(taskId)
	local createdAt = os.date("!%Y-%m-%dT%H:%M:%SZ")
	local cleanedTime1 = string.gsub(createdAt, "[-:]", "")
	local cleanedTime2 = string.gsub(cleanedTime1, "%.%d+Z$", "Z")
	local queueResult = writePendingHandoff(
		rootSession.projectRoot,
		rootSession.memoryScope,
		{
			id = (((cleanedTime2 .. "_sub_") .. tostring(session.id)) .. "_") .. tostring(taskId),
			sourceSessionId = session.id,
			sourceTitle = session.title,
			sourceTaskId = taskId,
			message = summary,
			prompt = result.prompt,
			goal = result.goal,
			expectedOutput = result.expectedOutput or "",
			filesHint = result.filesHint or ({}),
			success = result.success,
			resultFilePath = result.resultFilePath,
			artifactDir = result.artifactDir,
			finishedAt = result.finishedAt,
			changeSet = changeSet,
			handoffEvidence = result.handoffEvidence,
			memoryEntry = result.memoryEntry,
			completion = result.completion,
			createdAt = createdAt
		}
	)
	if not queueResult then
		Log(
			"Warn",
			(("[AgentSession] failed to queue sub-agent handoff root=" .. tostring(rootSession.id)) .. " source=") .. tostring(session.id)
		)
		return
	end
	if rootSession.currentTaskId and rootSession.currentTaskId > 0 then
		addTaskReference(rootSession.currentTaskId, taskId)
	end
	if not (rootSession.currentTaskStatus == "RUNNING" and rootSession.currentTaskId and activeStopTokens[rootSession.currentTaskId]) then
		flushPendingSubAgentHandoffs(rootSession)
	end
end
function finalizeSubSession(session, taskId, success, message, completion, forceHandoff)
	if forceHandoff == nil then
		forceHandoff = false
	end
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local rootSessionId = getSessionRootId(session)
		local rootSession = getRootSessionItem(session.id)
		if not rootSession then
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"})
		end
		local spawnInfo = getSessionSpawnInfo(session)
		local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ")
		local finishedAtTs = now()
		local resultText = sanitizeUTF8(message)
		local changeSet = getTaskChangeSetSummary(taskId)
		local handoffEvidence = getTaskHandoffEvidence(taskId, changeSet)
		local ____completion_71 = completion
		if ____completion_71 == nil then
			local ____normalizeAgentCompletionReport_70 = normalizeAgentCompletionReport
			local ____opt_68 = handoffEvidence.lastBuild
			____completion_71 = ____normalizeAgentCompletionReport_70({outcome = (____opt_68 and ____opt_68.result) == "passed" and "completed" or "partial", knownIssues = {}})
		end
		local completionReport = ____completion_71
		completionReport = reconcileCompletionWithHandoffEvidence(completionReport, handoffEvidence)
		if not success and completionReport.outcome == "completed" and not forceHandoff then
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "blocked", knownIssues = {resultText ~= "" and resultText or "The sub-agent did not complete."}}))
		end
		if forceHandoff and not success and completionReport.outcome ~= "partial" then
			completionReport = normalizeAgentCompletionReport(__TS__ObjectAssign({}, completionReport, {outcome = "partial", knownIssues = #completionReport.knownIssues > 0 and completionReport.knownIssues or ({resultText ~= "" and resultText or "The sub-agent handoff summary could not be completed."})}))
		end
		local completed = success and completionReport.outcome == "completed"
		local recordStatus = completed and "DONE" or (completionReport.outcome == "partial" and "STOPPED" or "FAILED")
		local record = {
			sessionId = session.id,
			rootSessionId = rootSessionId,
			parentSessionId = session.parentSessionId,
			title = session.title,
			prompt = spawnInfo and spawnInfo.prompt or "",
			goal = spawnInfo and spawnInfo.goal or session.title,
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "",
			filesHint = spawnInfo and spawnInfo.filesHint or ({}),
			status = recordStatus,
			success = completed,
			resultFilePath = getResultRelativePath(session.memoryScope),
			artifactDir = getArtifactRelativeDir(session.memoryScope),
			sourceTaskId = taskId,
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt,
			finishedAt = finishedAt,
			createdAtTs = session.createdAt,
			finishedAtTs = finishedAtTs,
			changeSet = changeSet,
			handoffEvidence = handoffEvidence,
			completion = completionReport
		}
		local ____record_success_82
		if record.success then
			____record_success_82 = buildStructuredSubAgentMemoryEntry(record)
		else
			____record_success_82 = nil
		end
		record.memoryEntry = ____record_success_82
		if not writeSubAgentResultFile(session, record, resultText) then
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session result file"})
		end
		if not writeSpawnInfo(session.projectRoot, session.memoryScope, {
			sessionId = record.sessionId,
			rootSessionId = record.rootSessionId,
			parentSessionId = record.parentSessionId,
			title = record.title,
			prompt = record.prompt,
			goal = record.goal,
			expectedOutput = record.expectedOutput or "",
			filesHint = record.filesHint or ({}),
			status = record.status,
			success = record.success,
			resultFilePath = record.resultFilePath,
			artifactDir = record.artifactDir,
			sourceTaskId = record.sourceTaskId,
			createdAt = record.createdAt,
			finishedAt = record.finishedAt,
			createdAtTs = record.createdAtTs,
			finishedAtTs = record.finishedAtTs,
			changeSet = record.changeSet,
			handoffEvidence = record.handoffEvidence,
			memoryEntry = record.memoryEntry,
			memoryEntryError = record.memoryEntryError,
			completion = record.completion
		}) then
			return ____awaiter_resolve(nil, {success = false, message = "failed to persist sub session spawn info"})
		end
		if success or forceHandoff then
			appendSubAgentHandoffStep(session, taskId, record, resultText)
			deleteSessionRecords(session.id, true)
			emitSessionDeletedPatch(session.id, rootSessionId, rootSession.projectRoot)
		end
		return ____awaiter_resolve(nil, {success = true})
	end)
end
function stopClearedSubSession(session, taskId)
	local spawnInfo = getSessionSpawnInfo(session)
	local finishedAt = os.date("!%Y-%m-%dT%H:%M:%SZ")
	local rootSessionId = getSessionRootId(session)
	Tools.setTaskStatus(taskId, "STOPPED")
	setSessionState(session.id, "STOPPED", taskId, "STOPPED")
	if not writeSpawnInfo(
		session.projectRoot,
		session.memoryScope,
		{
			sessionId = session.id,
			rootSessionId = rootSessionId,
			parentSessionId = session.parentSessionId,
			title = session.title,
			prompt = spawnInfo and spawnInfo.prompt or "",
			goal = spawnInfo and spawnInfo.goal or session.title,
			expectedOutput = spawnInfo and spawnInfo.expectedOutput or "",
			filesHint = spawnInfo and spawnInfo.filesHint or ({}),
			status = "STOPPED",
			success = false,
			cleared = true,
			resultFilePath = "",
			artifactDir = getArtifactRelativeDir(session.memoryScope),
			sourceTaskId = taskId,
			createdAt = spawnInfo and spawnInfo.createdAt or finishedAt,
			finishedAt = finishedAt,
			createdAtTs = session.createdAt,
			finishedAtTs = now()
		}
	) then
		return {success = false, message = "failed to persist cleared sub session spawn info"}
	end
	deleteSessionRecords(session.id, true)
	emitSessionDeletedPatch(session.id, rootSessionId, session.projectRoot)
	return {success = true}
end
function ____exports.sendPrompt(sessionId, prompt, disabledAgentTools, workMode, llmConfigId, llmConfig, maxSteps)
	local session = getSessionItem(sessionId)
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then
		return {success = false, message = "project task admission is closed"}
	end
	if not session then
		return {success = false, message = "session not found"}
	end
	if getPendingQuestionnaire(sessionId) then
		return {success = false, message = "complete the pending questionnaire before sending another prompt"}
	end
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then
		return {success = false, message = "session task is finalizing"}
	end
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then
		return {success = false, message = "session task is still running"}
	end
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] == nil then
		Log(
			"Warn",
			("[AgentSession] orphan task " .. tostring(session.currentTaskId)) .. " detected (RUNNING but no stop token after restart); marking FAILED"
		)
		DB:exec("update AgentTask set status = 'FAILED' where id = " .. tostring(session.currentTaskId))
		session.currentTaskStatus = "FAILED"
	end
	local normalizedPrompt = normalizePromptTextSafe(prompt)
	if normalizedPrompt == "" and session.kind == "sub" then
		local spawnInfo = getSessionSpawnInfo(session)
		if spawnInfo then
			normalizedPrompt = normalizePromptTextSafe(spawnInfo.prompt)
			if normalizedPrompt == "" then
				normalizedPrompt = buildSubAgentPromptFallback(spawnInfo.goal, spawnInfo.expectedOutput, spawnInfo.filesHint)
			end
		end
	end
	if normalizedPrompt == "" then
		return {success = false, message = "prompt is empty"}
	end
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code"
	if session.workMode ~= nextWorkMode then
		DB:exec(
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?",
			{
				nextWorkMode,
				now(),
				session.id
			}
		)
		session.workMode = nextWorkMode
	end
	local boundedMaxSteps = type(maxSteps) == "number" and maxSteps >= 1 and maxSteps <= AgentConfig.AGENT_DEFAULTS.maxSteps and math.floor(maxSteps) or nil
	return startPromptTask(
		session,
		normalizedPrompt,
		nil,
		normalizeDisabledAgentTools(disabledAgentTools),
		{workMode = nextWorkMode, llmConfigId = llmConfigId, llmConfig = llmConfig, maxSteps = boundedMaxSteps}
	)
end
function startPromptTask(session, normalizedPrompt, existingUserMessageId, disabledAgentTools, options)
	if disabledAgentTools == nil then
		disabledAgentTools = {}
	end
	local taskWorkMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code"
	if isProjectTaskAdmissionClosed(session.projectRoot) then
		return {success = false, message = "project task admission is closed"}
	end
	local llmConfigRes = options and options.llmConfig and ({success = true, config = options.llmConfig}) or getLLMConfig(options and options.llmConfigId)
	if not llmConfigRes.success then
		return {success = false, message = llmConfigRes.message}
	end
	local llmConfig = llmConfigRes.config
	local llmConfigValidation = validateAgentLLMConfig(llmConfig)
	if not llmConfigValidation.success then
		return llmConfigValidation
	end
	local taskRes = (options and options.existingTaskId) ~= nil and ({success = true, taskId = options.existingTaskId}) or Tools.createTask(normalizedPrompt, taskWorkMode)
	if not taskRes.success then
		return {success = false, message = taskRes.message}
	end
	if session.currentTaskStatus == "STOPPED" or session.currentTaskStatus == "FAILED" then
		removeContinuableTaskSummary(session)
	end
	local taskId = taskRes.taskId
	local ____temp_103
	if (options and options.existingTaskId) == nil then
		____temp_103 = session.currentTaskId
	else
		____temp_103 = nil
	end
	local previousTaskId = ____temp_103
	local useChineseResponse = getDefaultUseChineseResponse()
	local promptMessageId
	if existingUserMessageId ~= nil then
		updateUserMessageForTask(existingUserMessageId, normalizedPrompt, taskId)
		promptMessageId = existingUserMessageId
	elseif (options and options.resumeConversation) ~= true and (options and options.persistUserMessage) ~= false then
		promptMessageId = insertMessage(
			session.id,
			"user",
			normalizedPrompt,
			taskId,
			options and options.displayContent
		)
	end
	local stopToken = {stopped = false}
	activeStopTokens[taskId] = stopToken
	setSessionState(session.id, "RUNNING", taskId, "RUNNING")
	emitAgentSessionPatch(
		session.id,
		__TS__ObjectAssign(
			{session = getSessionItem(session.id)},
			promptMessageId ~= nil and ({message = getMessageItem(promptMessageId)}) or ({})
		)
	)
	if previousTaskId and previousTaskId ~= taskId then
		cleanupTaskHeavyData(previousTaskId)
	end
	activePromptRuns = activePromptRuns + 1
	local ____runCodingAgent_132 = runCodingAgent
	local ____normalizedPrompt_125 = normalizedPrompt
	local ____temp_126 = options and options.resumeConversation
	local ____temp_127 = (options and options.existingTaskId) ~= nil
	local ____temp_128 = options and options.initialStep
	local ____temp_129 = options and options.initialAgentStepCount
	local ____temp_120
	if (options and options.existingTaskId) ~= nil then
		____temp_120 = getInitialTokenUsage(session)
	else
		____temp_120 = nil
	end
	____runCodingAgent_132(
		{
			prompt = ____normalizedPrompt_125,
			resumeConversation = ____temp_126,
			resumeTask = ____temp_127,
			initialStep = ____temp_128,
			initialAgentStepCount = ____temp_129,
			initialTokenUsage = ____temp_120,
			workDir = session.projectRoot,
			useChineseResponse = useChineseResponse,
			taskId = taskId,
			sessionId = session.id,
			memoryScope = session.memoryScope,
			role = session.kind,
			maxSteps = options and options.maxSteps,
			disabledAgentTools = disabledAgentTools,
			workMode = session.kind == "main" and (options and options.workMode or session.workMode) or "code",
			llmConfig = llmConfig,
			spawnSubAgent = session.kind == "main" and (function(request) return spawnSubAgentSession(__TS__ObjectAssign({}, request, {llmConfig = llmConfig})) end) or nil,
			listSubAgents = session.kind == "main" and ____exports.listRunningSubAgents or nil,
			publishQuestionnaire = session.kind == "main" and publishQuestionnaire or nil,
			stopToken = stopToken,
			onEvent = function(____, event) return applyEvent(session.id, event) end
		},
		function(result)
			return __TS__AsyncAwaiter(function(____awaiter_resolve)
				local ____hasReturned, ____returnValue
				local ____try = __TS__AsyncAwaiter(function()
					local nextSession = getSessionItem(session.id)
					if nextSession and nextSession.kind == "sub" then
						if __TS__StringTrim(normalizedPrompt) == "/clear" then
							local stopped = stopClearedSubSession(nextSession, taskId)
							if not stopped.success then
								Log(
									"Warn",
									(("[AgentSession] sub session clear stop failed session=" .. tostring(nextSession.id)) .. " error=") .. stopped.message
								)
								emitAgentSessionPatch(
									session.id,
									{session = getSessionItem(session.id)}
								)
							end
							__TS__Delete(activeStopTokens, taskId)
							____hasReturned = true
							return
						end
						setSessionState(session.id, "RUNNING", taskId, "RUNNING")
						emitAgentSessionPatch(
							session.id,
							{session = getSessionItem(session.id)}
						)
						local finalized = __TS__Await(finalizeSubSession(
							nextSession,
							taskId,
							result.success,
							result.message,
							result.completion,
							(options and options.forceSubAgentHandoff) == true
						))
						if not finalized.success then
							Log(
								"Warn",
								(("[AgentSession] sub session finalize failed session=" .. tostring(nextSession.id)) .. " error=") .. finalized.message
							)
						end
						local finalizedSession = getSessionItem(session.id)
						if finalizedSession then
							local stopped = stopToken.stopped == true
							local finalStatus = result.success and "DONE" or (stopped and "STOPPED" or "FAILED")
							setSessionState(session.id, finalStatus, taskId, finalStatus)
							emitAgentSessionPatch(
								session.id,
								{session = getSessionItem(session.id)}
							)
						end
						__TS__Delete(activeStopTokens, taskId)
						__TS__Delete(finalizingSubSessionTaskIds, taskId)
					end
					local fallbackSession = getSessionItem(session.id)
					if not result.success and (not nextSession or nextSession.kind ~= "sub") and fallbackSession ~= nil and fallbackSession.currentTaskId == result.taskId and fallbackSession.currentTaskStatus == "RUNNING" then
						applyEvent(session.id, {
							type = "task_finished",
							sessionId = session.id,
							taskId = result.taskId,
							success = false,
							message = result.message,
							steps = result.steps
						})
					end
				end)
				____try = ____try.finally(
					____try,
					function()
						return __TS__AsyncAwaiter(function()
							activePromptRuns = activePromptRuns - 1
						end)
					end
				)
				__TS__Await(____try)
				if ____hasReturned then
					return ____awaiter_resolve(nil, ____returnValue)
				end
			end)
		end
	)
	return {success = true, sessionId = session.id, taskId = taskId}
end
function buildQuestionnaireFeedbackDisplay(questionnaire, answers)
	local lines = {}
	do
		local i = 0
		while i < #questionnaire.schema.questions do
			local question = questionnaire.schema.questions[i + 1]
			local answer = __TS__ArrayFind(
				answers,
				function(____, item) return item.questionId == question.id end
			)
			local answerText = "已跳过"
			if answer and answer.status == "answered" then
				local parts = {}
				do
					local j = 0
					while j < #(answer.selectedOptionIds or ({})) do
						local optionId = (answer.selectedOptionIds or ({}))[j + 1]
						local option = __TS__ArrayFind(
							question.options or ({}),
							function(____, item) return item.id == optionId end
						)
						if option then
							parts[#parts + 1] = option.label
						end
						j = j + 1
					end
				end
				if answer.otherText then
					parts[#parts + 1] = answer.otherText
				end
				if answer.text then
					parts[#parts + 1] = answer.text
				end
				answerText = #parts > 0 and table.concat(parts, "、") or "未填写"
			end
			lines[#lines + 1] = (question.prompt .. "\n") .. answerText
			i = i + 1
		end
	end
	return table.concat(lines, "\n\n")
end
function ____exports.listRunningSubAgents(request)
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local session = getSessionItem(request.sessionId)
		if not session and request.projectRoot and request.projectRoot ~= "" then
			session = getLatestMainSessionByProjectRoot(request.projectRoot)
		end
		if not session then
			return ____awaiter_resolve(nil, {success = false, message = "session not found"})
		end
		local rootSession = getRootSessionItem(session.id)
		if not rootSession then
			return ____awaiter_resolve(nil, {success = false, message = "root session not found"})
		end
		local requestedStatus = __TS__StringTrim(sanitizeUTF8(toStr(request.status)))
		local status = requestedStatus ~= "" and requestedStatus or "active_or_recent"
		local limit = math.max(
			1,
			math.floor(tonumber(request.limit) or 5)
		)
		local offset = math.max(
			0,
			math.floor(tonumber(request.offset) or 0)
		)
		local query = __TS__StringTrim(sanitizeUTF8(toStr(request.query)))
		local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE root_session_id = ? AND kind = 'sub'\n\t\tORDER BY id ASC", {rootSession.id}) or ({})
		local runningSessions = {}
		do
			local i = 0
			while i < #rows do
				do
					local current = normalizeSessionRuntimeState(rowToSession(rows[i + 1]))
					if current.currentTaskStatus ~= "RUNNING" then
						goto __continue571
					end
					local spawnInfo = getSessionSpawnInfo(current)
					runningSessions[#runningSessions + 1] = {
						sessionId = current.id,
						title = current.title,
						parentSessionId = current.parentSessionId,
						rootSessionId = current.rootSessionId,
						status = "RUNNING",
						currentTaskId = current.currentTaskId,
						currentTaskStatus = current.currentTaskStatus or current.status,
						goal = spawnInfo and spawnInfo.goal,
						expectedOutput = spawnInfo and spawnInfo.expectedOutput,
						filesHint = spawnInfo and spawnInfo.filesHint,
						createdAt = current.createdAt,
						updatedAt = current.updatedAt
					}
				end
				::__continue571::
				i = i + 1
			end
		end
		local completedRecords = listSubAgentResultRecords(rootSession.projectRoot, rootSession.id)
		local completedSessions = __TS__ArrayMap(
			completedRecords,
			function(____, record) return {
				sessionId = record.sessionId,
				title = record.title,
				parentSessionId = record.parentSessionId,
				rootSessionId = record.rootSessionId,
				status = record.status,
				goal = record.goal,
				expectedOutput = record.expectedOutput,
				filesHint = record.filesHint,
				summary = readSubAgentResultSummary(rootSession.projectRoot, record.resultFilePath),
				success = record.success,
				cleared = record.cleared,
				resultFilePath = record.resultFilePath,
				artifactDir = record.artifactDir,
				finishedAt = record.finishedAt,
				createdAt = record.createdAtTs,
				updatedAt = record.finishedAtTs
			} end
		)
		local merged = {}
		if status == "running" then
			merged = runningSessions
		elseif status == "done" then
			merged = __TS__ArrayFilter(
				completedSessions,
				function(____, item) return item.status == "DONE" end
			)
		elseif status == "failed" then
			merged = __TS__ArrayFilter(
				completedSessions,
				function(____, item) return item.status == "FAILED" end
			)
		elseif status == "stopped" then
			merged = __TS__ArrayFilter(
				completedSessions,
				function(____, item) return item.status == "STOPPED" end
			)
		elseif status == "all" then
			merged = __TS__ArrayConcat(runningSessions, completedSessions)
		else
			local runningKeys = {}
			do
				local i = 0
				while i < #runningSessions do
					runningKeys[getSubAgentDisplayKey(runningSessions[i + 1])] = true
					i = i + 1
				end
			end
			local latestCompletedByKey = {}
			do
				local i = 0
				while i < #completedSessions do
					do
						local item = completedSessions[i + 1]
						local key = getSubAgentDisplayKey(item)
						if runningKeys[key] then
							goto __continue586
						end
						local current = latestCompletedByKey[key]
						if current == nil or item.updatedAt > current.updatedAt then
							latestCompletedByKey[key] = item
						end
					end
					::__continue586::
					i = i + 1
				end
			end
			local latestCompleted = {}
			for ____, item in pairs(latestCompletedByKey) do
				latestCompleted[#latestCompleted + 1] = item
			end
			merged = __TS__ArrayConcat(runningSessions, latestCompleted)
		end
		if query ~= "" then
			merged = __TS__ArrayFilter(
				merged,
				function(____, item) return containsNormalizedText(item.title, query) or containsNormalizedText(item.goal or "", query) or containsNormalizedText(item.summary or "", query) end
			)
		end
		__TS__ArraySort(
			merged,
			function(____, a, b)
				if a.status == "RUNNING" and b.status ~= "RUNNING" then
					return -1
				end
				if a.status ~= "RUNNING" and b.status == "RUNNING" then
					return 1
				end
				if a.status == "RUNNING" or b.status == "RUNNING" then
					return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0)
				end
				return a.updatedAt > b.updatedAt and -1 or (a.updatedAt < b.updatedAt and 1 or 0)
			end
		)
		local paged = __TS__ArraySlice(merged, offset, offset + limit)
		return ____awaiter_resolve(nil, {
			success = true,
			rootSessionId = rootSession.id,
			maxConcurrent = MAX_CONCURRENT_SUB_AGENTS,
			status = status,
			limit = limit,
			offset = offset,
			hasMore = offset + limit < #merged,
			sessions = paged
		})
	end)
end
QUESTIONNAIRE_DIR = ".agent/questionnaire"
PENDING_QUESTIONNAIRE_FILE = "pending.json"
SPAWN_INFO_FILE = "SPAWN.json"
RESULT_FILE = "RESULT.md"
PENDING_HANDOFF_DIR = "pending-handoffs"
MAX_CONCURRENT_SUB_AGENTS = 4
SUB_AGENT_MEMORY_ENTRY_MAX_CHARS = 1200
SUB_AGENT_MEMORY_EVIDENCE_MAX_ITEMS = 5
activeStopTokens = {}
activeLocalAgentControls = {}
finalizingSubSessionTaskIds = {}
activePromptRuns = 0
streamUpdates = __TS__New(
	StreamUpdates,
	function(sessionId, taskId, step, value)
		local ____opt_0 = getSessionItem(sessionId)
		if (____opt_0 and ____opt_0.currentTaskId) ~= taskId then
			return
		end
		upsertStep(
			sessionId,
			taskId,
			step,
			"message",
			{status = "RUNNING", reason = value.content, reasoningContent = value.reasoningContent}
		)
		emitAgentSessionPatch(
			sessionId,
			{step = getStepItem(sessionId, taskId, step)}
		)
	end
)
streamFlushScheduled = false
--- Runtime ownership, including asynchronous completion after task status changes.
function ____exports.isRuntimeIdle()
	return activePromptRuns == 0 and #__TS__ObjectKeys(activeStopTokens) == 0 and #__TS__ObjectKeys(activeLocalAgentControls) == 0 and #__TS__ObjectKeys(finalizingSubSessionTaskIds) == 0
end
SESSION_SELECT_COLUMNS = "id, project_root, title, kind, root_session_id, parent_session_id, memory_scope, status, current_task_id, current_task_status, created_at, updated_at, metrics_json, work_mode"
now = function() return os.time() end
local function rebaseProjectRoot(projectRoot, oldRoot, newRoot)
	if projectRoot == oldRoot then
		return newRoot
	end
	for ____, separator in ipairs({"/", "\\"}) do
		local prefix = oldRoot .. separator
		if __TS__StringStartsWith(projectRoot, prefix) then
			return newRoot .. __TS__StringSlice(projectRoot, #oldRoot)
		end
	end
	return nil
end
local function clearSessionAfterMessage(sessionId, message)
	local removedStepRows = queryRows(((("SELECT id FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id}) or ({})
	local removedStepIds = {}
	do
		local i = 0
		while i < #removedStepRows do
			local row = removedStepRows[i + 1]
			if type(row[1]) == "number" then
				removedStepIds[#removedStepIds + 1] = row[1]
			end
			i = i + 1
		end
	end
	DB:exec(((("DELETE FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id IN (\n\t\t\tSELECT DISTINCT task_id FROM ") .. TABLE_MESSAGE) .. "\n\t\t\tWHERE session_id = ? AND id >= ? AND task_id > 0\n\t\t)", {sessionId, sessionId, message.id})
	DB:exec(("DELETE FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id > ?", {sessionId, message.id})
	return removedStepIds
end
local function truncatePersistedSessionBeforeLatestUserPrompt(session)
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope)
	local persisted = storage:readSessionState()
	local userIndex = -1
	do
		local i = #persisted.messages - 1
		while i >= 0 do
			if persisted.messages[i + 1].role == "user" then
				userIndex = i
				break
			end
			i = i - 1
		end
	end
	if userIndex < 0 then
		return
	end
	local messages = __TS__ArraySlice(persisted.messages, 0, userIndex)
	local lastConsolidatedIndex = math.min(persisted.lastConsolidatedIndex, #messages)
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex >= 0 and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex)
end
local function listCurrentTaskCheckpoints(sessionId)
	local session = getSessionItem(sessionId)
	local taskId = session and session.currentTaskId
	return taskId ~= nil and Tools.listCheckpoints(taskId) or ({})
end
local function getAgentStepCount(sessionId, taskId)
	local row = queryOne(("SELECT COUNT(*) FROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ? AND task_id = ?\n\t\t\tAND tool NOT IN (?, ?, ?, ?, ?)", {
		sessionId,
		taskId,
		"compress_memory",
		"merge_memory",
		"sub_agent_handoff",
		"questionnaire_answer",
		"message"
	})
	return row and type(row[1]) == "number" and math.max(0, row[1]) or 0
end
local function appendSystemStep(sessionId, taskId, tool, _systemType, reason, result, params, status)
	if status == nil then
		status = "DONE"
	end
	local step = getNextStepNumber(sessionId, taskId)
	upsertStep(
		sessionId,
		taskId,
		step,
		tool,
		{status = status, reason = reason, params = params, result = result}
	)
	return getStepItem(sessionId, taskId, step)
end
local function sanitizeStoredSteps(sessionId)
	DB:exec(
		((((((((("UPDATE " .. TABLE_STEP) .. "\n\t\tSET status = (\n\t\t\tCASE (\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t)\n\t\t\t\tWHEN 'STOPPED' THEN 'STOPPED'\n\t\t\t\tELSE 'FAILED'\n\t\t\tEND\n\t\t),\n\t\tupdated_at = ?\n\t\tWHERE session_id = ?\n\t\t\tAND status IN ('PENDING', 'RUNNING')\n\t\t\tAND COALESCE((\n\t\t\t\tSELECT status FROM ") .. TABLE_TASK) .. "\n\t\t\t\tWHERE id = ") .. TABLE_STEP) .. ".task_id\n\t\t\t), '') <> 'RUNNING'",
		{
			now(),
			sessionId
		}
	)
end
function ____exports.deleteSessionsByProjectRoot(projectRoot)
	if projectRoot == "" or not Content:isAbsolutePath(projectRoot) then
		return {success = false, message = "invalid projectRoot"}
	end
	local rows = queryRows(("SELECT id FROM " .. TABLE_SESSION) .. " WHERE project_root = ?", {projectRoot}) or ({})
	for ____, row in ipairs(rows) do
		local sessionId = type(row[1]) == "number" and row[1] or 0
		if sessionId > 0 then
			deleteSessionRecords(sessionId)
		end
	end
	return {success = true, deleted = #rows}
end
function ____exports.renameSessionsByProjectRoot(oldRoot, newRoot)
	if oldRoot == "" or newRoot == "" or not Content:isAbsolutePath(oldRoot) or not Content:isAbsolutePath(newRoot) then
		return {success = false, message = "invalid projectRoot"}
	end
	local rows = queryRows("SELECT id, project_root, root_session_id FROM " .. TABLE_SESSION) or ({})
	local renamed = 0
	for ____, row in ipairs(rows) do
		local sessionId = type(row[1]) == "number" and row[1] or 0
		local projectRoot = toStr(row[2])
		local nextProjectRoot = rebaseProjectRoot(projectRoot, oldRoot, newRoot)
		if sessionId > 0 and nextProjectRoot then
			local rootSessionId = type(row[3]) == "number" and row[3] > 0 and row[3] or sessionId
			DB:exec(
				("UPDATE " .. TABLE_SESSION) .. " SET project_root = ?, title = ?, updated_at = ? WHERE id = ?",
				{
					nextProjectRoot,
					Path:getFilename(nextProjectRoot),
					now(),
					sessionId
				}
			)
			renamed = renamed + 1
		end
	end
	return {success = true, renamed = renamed}
end
function ____exports.getSession(sessionId, view)
	local session = getSessionItem(sessionId)
	if not session then
		return {success = false, message = "session not found"}
	end
	local restored = restorePendingQuestionnaireState(session)
	local normalizedSession = normalizeSessionRuntimeState(restored.session)
	local relatedSessions = listRelatedSessions(sessionId)
	sanitizeStoredSteps(sessionId)
	local firstMessageId = 0
	local hasEarlierMessages = false
	if view then
		local limit = math.max(
			1,
			math.min(
				1000,
				math.floor(view.recentRounds)
			)
		)
		local requests = queryRows(("SELECT id FROM " .. TABLE_MESSAGE) .. " WHERE session_id = ? AND role = 'user'\n\t\t\tORDER BY id DESC LIMIT ?", {sessionId, limit + 1}) or ({})
		if #requests > limit then
			firstMessageId = requests[limit][1]
			hasEarlierMessages = true
		end
	end
	local messages = queryRows(("SELECT id, session_id, task_id, role, content, display_content, created_at, updated_at\n\t\tFROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND id >= ?\n\t\tORDER BY id ASC", {sessionId, firstMessageId}) or ({})
	local steps = queryRows(((("SELECT id, session_id, task_id, step, tool, status, reason, reasoning_content, params_json, result_json, checkpoint_id, checkpoint_seq, files_json, created_at, updated_at\n\t\tFROM " .. TABLE_STEP) .. "\n\t\tWHERE session_id = ?\n\t\t\t") .. (view and view.currentTaskStepsOnly and "AND task_id = ?" or "")) .. "\n\t\t\tAND NOT (status IN ('FAILED', 'STOPPED') AND result_json = '')\n\t\tORDER BY task_id DESC, step ASC", view and view.currentTaskStepsOnly and ({sessionId, normalizedSession.currentTaskId or 0}) or ({sessionId})) or ({})
	local ____relatedSessions_67 = relatedSessions
	local ____temp_66
	if normalizedSession.kind == "sub" then
		____temp_66 = getSessionSpawnInfo(normalizedSession)
	else
		____temp_66 = nil
	end
	return {
		success = true,
		session = normalizedSession,
		relatedSessions = ____relatedSessions_67,
		spawnInfo = ____temp_66,
		messages = __TS__ArrayMap(
			messages,
			function(____, row) return rowToMessage(row) end
		),
		hasEarlierMessages = hasEarlierMessages,
		steps = __TS__ArrayMap(
			steps,
			function(____, row) return rowToStep(row) end
		),
		checkpoints = listCurrentTaskCheckpoints(sessionId),
		pendingQuestionnaire = restored.questionnaire,
		hasActivePlan = Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PLAN_FILE)) and Content:exist(Path(normalizedSession.projectRoot, AgentRuntimePolicy.AGENT_PROGRESS_FILE))
	}
end
function ____exports.setWorkMode(sessionId, workMode)
	local session = getSessionItem(sessionId)
	if not session then
		return {success = false, message = "session not found"}
	end
	if session.kind ~= "main" then
		return {success = false, message = "Plan mode is only available for main sessions"}
	end
	if workMode ~= "code" and workMode ~= "plan" then
		return {success = false, message = "invalid work mode"}
	end
	local normalizedSession = normalizeSessionRuntimeState(session)
	if normalizedSession.currentTaskStatus == "RUNNING" or normalizedSession.currentTaskStatus == "WAITING_USER" then
		return {success = false, message = "work mode cannot change while the session is running or waiting for user feedback"}
	end
	if getPendingQuestionnaire(sessionId) then
		return {success = false, message = "complete the pending questionnaire before changing work mode"}
	end
	if normalizedSession.workMode ~= workMode then
		DB:exec(
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?",
			{
				workMode,
				now(),
				sessionId
			}
		)
	end
	local updated = getSessionItem(sessionId)
	emitAgentSessionPatch(sessionId, {session = updated})
	return {
		success = true,
		session = updated or __TS__ObjectAssign({}, normalizedSession, {workMode = workMode})
	}
end
function ____exports.sendLocalPrompt(sessionId, prompt, localAgentConfigId)
	local session = getSessionItem(sessionId)
	if not session then
		return {success = false, message = "session not found"}
	end
	if session.kind ~= "main" then
		return {success = false, message = "local Agent only supports main sessions"}
	end
	if getPendingQuestionnaire(sessionId) then
		return {success = false, message = "complete the pending questionnaire before sending another prompt"}
	end
	if session.currentTaskStatus == "RUNNING" then
		return {success = false, message = "session task is still running"}
	end
	local normalizedPrompt = normalizePromptTextSafe(prompt)
	if normalizedPrompt == "" then
		return {success = false, message = "prompt is empty"}
	end
	local config = LocalAgent.getConfig(localAgentConfigId)
	if not config then
		return {success = false, message = "local Agent config not found"}
	end
	if not config.verifiedAt then
		return {success = false, message = "local Agent config is not verified"}
	end
	local taskRes = Tools.createTask(normalizedPrompt, "code")
	if not taskRes.success then
		return taskRes
	end
	local taskId = taskRes.taskId
	local messageId = insertMessage(session.id, "user", normalizedPrompt, taskId)
	Tools.setTaskStatus(taskId, "RUNNING")
	setSessionState(session.id, "RUNNING", taskId, "RUNNING")
	upsertStep(
		session.id,
		taskId,
		1,
		"local_agent_message",
		{status = "RUNNING", reason = config.name .. " · full permissions", params = {provider = config.provider, configId = config.id}, result = {events = {}, transcript = ""}}
	)
	emitAgentSessionPatch(
		session.id,
		{
			session = getSessionItem(session.id),
			message = getMessageItem(messageId),
			step = getStepItem(session.id, taskId, 1)
		}
	)
	local events = {}
	local transcript = ""
	local assistant = ""
	local lastFlush = 0
	local function flush(force)
		if force == nil then
			force = false
		end
		if not force and App.runningTime - lastFlush < 0.075 then
			return
		end
		lastFlush = App.runningTime
		if #events > 400 then
			events = __TS__ArraySlice(events, #events - 400)
		end
		if #transcript > 1024 * 1024 then
			transcript = __TS__StringSlice(transcript, #transcript - 1024 * 1024)
		end
		upsertStep(
			session.id,
			taskId,
			1,
			"local_agent_message",
			{status = "RUNNING", reason = config.name .. " · full permissions", result = {provider = config.provider, events = events, transcript = transcript}}
		)
		local message
		if assistant ~= "" then
			local assistantId = upsertAssistantMessage(session.id, taskId, assistant)
			message = getMessageItem(assistantId)
		end
		emitAgentSessionPatch(
			session.id,
			__TS__ObjectAssign(
				{step = getStepItem(session.id, taskId, 1)},
				message and ({message = message}) or ({})
			)
		)
	end
	local completedSynchronously = false
	local control = LocalAgent.run(
		session.id,
		config,
		session.projectRoot,
		normalizedPrompt,
		function(event)
			local text = sanitizeUTF8(event.text)
			if text == "" then
				return
			end
			local previous = #events > 0 and events[#events] or nil
			if previous and previous.kind == event.kind and previous.text == text then
				return
			end
			events[#events + 1] = {kind = event.kind, text = text}
			transcript = transcript .. ((event.kind .. ": ") .. text) .. "\n"
			if event.kind == "assistant" then
				assistant = text
			end
			flush(false)
		end,
		function(result)
			completedSynchronously = true
			flush(true)
			__TS__Delete(activeLocalAgentControls, taskId)
			local status = result.stopped and "STOPPED" or (result.success and "DONE" or "FAILED")
			Tools.setTaskStatus(taskId, status)
			setSessionState(session.id, status, taskId, status)
			upsertStep(
				session.id,
				taskId,
				1,
				"local_agent_message",
				{status = status, reason = config.name .. " · full permissions", result = {
					provider = config.provider,
					events = events,
					transcript = transcript,
					exitCode = result.exitCode,
					resumeId = result.resumeId,
					message = result.message
				}}
			)
			emitAgentSessionPatch(
				session.id,
				{
					session = getSessionItem(session.id),
					step = getStepItem(session.id, taskId, 1)
				}
			)
		end
	)
	if not completedSynchronously then
		activeLocalAgentControls[taskId] = control
	end
	return {success = true, sessionId = session.id, taskId = taskId}
end
function ____exports.continuePrompt(sessionId, disabledAgentTools, llmConfigId)
	local session = getSessionItem(sessionId)
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then
		return {success = false, message = "project task admission is closed"}
	end
	if not session then
		return {success = false, message = "session not found"}
	end
	if getPendingQuestionnaire(sessionId) then
		return {success = false, message = "complete the pending questionnaire before continuing"}
	end
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then
		return {success = false, message = "session task is finalizing"}
	end
	if session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then
		return {success = false, message = "session task is still stopping"}
	end
	if session.currentTaskStatus ~= "FAILED" and session.currentTaskStatus ~= "STOPPED" then
		return {success = false, message = "session task is not continuable"}
	end
	if session.currentTaskId == nil then
		return {success = false, message = "session task not found"}
	end
	local taskId = session.currentTaskId
	return startPromptTask(
		session,
		"",
		nil,
		normalizeDisabledAgentTools(disabledAgentTools),
		{
			workMode = session.workMode,
			persistUserMessage = false,
			resumeConversation = true,
			existingTaskId = taskId,
			initialStep = math.max(
				0,
				getNextStepNumber(session.id, taskId) - 1
			),
			initialAgentStepCount = 0,
			llmConfigId = llmConfigId
		}
	)
end
function ____exports.finishSubSessionHandoff(sessionId, llmConfigId)
	local session = getSessionItem(sessionId)
	if not session then
		return {success = false, message = "session not found"}
	end
	if session.kind ~= "sub" then
		return {success = false, message = "only sub-agent sessions can be ended with handoff"}
	end
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then
		return {success = false, message = "session task is finalizing"}
	end
	local normalizedSession = normalizeSessionRuntimeState(session)
	if normalizedSession.currentTaskStatus == "RUNNING" or session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] ~= nil then
		return {success = false, message = "stop the running sub-agent task before ending it with handoff"}
	end
	if normalizedSession.currentTaskStatus ~= "STOPPED" and normalizedSession.currentTaskStatus ~= "FAILED" then
		return {success = false, message = "only stopped or failed sub-agent sessions can be ended with handoff"}
	end
	local disabledAgentTools = AgentToolRegistry.getAllowedToolsForRole("sub")
	local prompt = getDefaultUseChineseResponse() and "请结束当前子任务并给出最终总结。不要再调用任何工具；用纯文本如实总结已完成内容、文件变更、验证状态和剩余问题。" or "End this sub task now and hand off the work already completed. Do not continue implementation, reading, searching, building, or validation. Call finish only: summarize completed work, file changes, validation status, and remaining issues from evidence already present in this session. Use outcome partial when unfinished, and do not claim unverified work as complete."
	return startPromptTask(
		session,
		prompt,
		nil,
		disabledAgentTools,
		{maxSteps = 1, forceSubAgentHandoff = true, llmConfigId = llmConfigId}
	)
end
function ____exports.resendPrompt(sessionId, messageId, prompt, disabledAgentTools, workMode, llmConfigId)
	local session = getSessionItem(sessionId)
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then
		return {success = false, message = "project task admission is closed"}
	end
	if not session then
		return {success = false, message = "session not found"}
	end
	if getPendingQuestionnaire(sessionId) then
		return {success = false, message = "complete the pending questionnaire before resending a prompt"}
	end
	if session.currentTaskFinalizing == true or session.currentTaskId ~= nil and finalizingSubSessionTaskIds[session.currentTaskId] == true then
		return {success = false, message = "session task is finalizing"}
	end
	if session.currentTaskStatus == "RUNNING" and session.currentTaskId ~= nil and activeStopTokens[session.currentTaskId] then
		return {success = false, message = "session task is still running"}
	end
	local message = getMessageItem(messageId)
	if not message or message.sessionId ~= sessionId or message.role ~= "user" then
		return {success = false, message = "message not found"}
	end
	local latestUserRow = queryOne(("SELECT id FROM " .. TABLE_MESSAGE) .. "\n\t\tWHERE session_id = ? AND role = ?\n\t\tORDER BY id DESC LIMIT 1", {sessionId, "user"})
	local latestUserMessageId = latestUserRow and type(latestUserRow[1]) == "number" and latestUserRow[1] or 0
	if latestUserMessageId ~= messageId then
		return {success = false, message = "only the latest user prompt can be edited"}
	end
	local normalizedPrompt = normalizePromptTextSafe(prompt)
	if normalizedPrompt == "" then
		return {success = false, message = "prompt is empty"}
	end
	local nextWorkMode = session.kind == "main" and normalizeWorkMode(workMode, session.workMode) or "code"
	if session.workMode ~= nextWorkMode then
		DB:exec(
			("UPDATE " .. TABLE_SESSION) .. " SET work_mode = ?, updated_at = ? WHERE id = ?",
			{
				nextWorkMode,
				now(),
				session.id
			}
		)
		session.workMode = nextWorkMode
	end
	local removedStepIds = clearSessionAfterMessage(sessionId, message)
	truncatePersistedSessionBeforeLatestUserPrompt(session)
	local result = startPromptTask(
		session,
		normalizedPrompt,
		messageId,
		normalizeDisabledAgentTools(disabledAgentTools),
		{workMode = nextWorkMode, llmConfigId = llmConfigId}
	)
	if result.success and #removedStepIds > 0 then
		emitAgentSessionPatch(sessionId, {removedStepIds = removedStepIds})
	end
	return result
end
local function buildQuestionnaireResumeQuery(questionnaire, answers, status)
	if status == "dismissed" then
		return ("用户关闭了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”，没有作答。请把未作答视为用户反馈并继续当前任务；不要机械地重复同一份问卷。"
	end
	return (("用户提交了 Plan 模式调查问卷“" .. questionnaire.schema.title) .. "”的回答。\n\n") .. buildQuestionnaireFeedbackDisplay(questionnaire, answers)
end
local function buildQuestionnaireAnswerResult(questionnaire, answers, status)
	if status == "dismissed" then
		return {
			success = true,
			status = "dismissed",
			source = "user",
			questionnaireId = questionnaire.id,
			title = questionnaire.schema.title,
			answers = {},
			responses = {},
			displayText = "用户关闭了调查问卷，未作答。",
			guidance = "The user dismissed this questionnaire without answering. Treat that as authoritative feedback and continue with reasonable assumptions where possible. Do not repeat the same questionnaire mechanically; ask again only when a materially different unresolved decision prevents useful progress."
		}
	end
	local responses = {}
	do
		local i = 0
		while i < #questionnaire.schema.questions do
			do
				local question = questionnaire.schema.questions[i + 1]
				local answer = __TS__ArrayFind(
					answers,
					function(____, item) return item.questionId == question.id end
				)
				if not answer or answer.status == "skipped" then
					responses[#responses + 1] = {questionId = question.id, prompt = question.prompt, status = "skipped"}
					goto __continue483
				end
				local selectedOptionLabels = {}
				do
					local j = 0
					while j < #(answer.selectedOptionIds or ({})) do
						local optionId = (answer.selectedOptionIds or ({}))[j + 1]
						local option = __TS__ArrayFind(
							question.options or ({}),
							function(____, item) return item.id == optionId end
						)
						if option then
							selectedOptionLabels[#selectedOptionLabels + 1] = option.label
						end
						j = j + 1
					end
				end
				responses[#responses + 1] = {
					questionId = question.id,
					prompt = question.prompt,
					status = "answered",
					selectedOptionIds = answer.selectedOptionIds or ({}),
					selectedOptionLabels = selectedOptionLabels,
					otherText = answer.otherText,
					text = answer.text
				}
			end
			::__continue483::
			i = i + 1
		end
	end
	return {
		success = true,
		status = "answered",
		source = "user",
		questionnaireId = questionnaire.id,
		title = questionnaire.schema.title,
		answers = answers,
		responses = responses,
		displayText = buildQuestionnaireFeedbackDisplay(questionnaire, answers),
		guidance = "These questionnaire answers were submitted by the user and are authoritative. Incorporate them into .agent/plan/PLAN.md and .agent/plan/PROGRESS.md before finish; use ask_user again only if a material product decision remains unresolved."
	}
end
local function replaceQuestionnaireToolResult(session, questionnaire, answers, status)
	local storage = __TS__New(DualLayerStorage, session.projectRoot, session.memoryScope)
	local persisted = storage:readSessionState()
	local messages = __TS__ArraySlice(persisted.messages)
	local toolResultIndex = -1
	local existingResult
	do
		local i = #messages - 1
		while i >= 0 do
			do
				local message = messages[i + 1]
				if message.role ~= "tool" or message.name ~= "ask_user" or type(message.content) ~= "string" then
					goto __continue503
				end
				local decoded = safeJsonDecode(message.content)
				if not decoded or __TS__ArrayIsArray(decoded) or type(decoded) ~= "table" then
					goto __continue503
				end
				local row = decoded
				if row.questionnaireId ~= questionnaire.id then
					goto __continue503
				end
				toolResultIndex = i
				existingResult = row
				break
			end
			::__continue503::
			i = i - 1
		end
	end
	local result = buildQuestionnaireAnswerResult(questionnaire, answers, status)
	local guidance = {}
	if type(existingResult and existingResult.guidance) == "string" and __TS__StringTrim(existingResult.guidance) ~= "" then
		guidance[#guidance + 1] = existingResult.guidance
	end
	if type(result.guidance) == "string" and __TS__ArrayIndexOf(guidance, result.guidance) < 0 then
		guidance[#guidance + 1] = result.guidance
	end
	result.guidance = table.concat(guidance, "\n")
	if toolResultIndex < 0 then
		messages[#messages + 1] = {
			role = "user",
			content = "Questionnaire response recovered after its original tool result was compacted:\n" .. encodeJson(result)
		}
		toolResultIndex = #messages - 1
	else
		messages[toolResultIndex + 1] = __TS__ObjectAssign(
			{},
			messages[toolResultIndex + 1],
			{content = encodeJson(result)}
		)
	end
	local pairStartIndex = toolResultIndex
	local toolCallId = messages[toolResultIndex + 1].tool_call_id
	if toolCallId and toolCallId ~= "" then
		do
			local i = toolResultIndex - 1
			while i >= 0 do
				do
					local message = messages[i + 1]
					if message.role ~= "assistant" or not message.tool_calls then
						goto __continue513
					end
					if __TS__ArraySome(
						message.tool_calls,
						function(____, call) return call.id == toolCallId end
					) then
						pairStartIndex = i
						break
					end
				end
				::__continue513::
				i = i - 1
			end
		end
	end
	local lastConsolidatedIndex = toolResultIndex < persisted.lastConsolidatedIndex and math.min(persisted.lastConsolidatedIndex, pairStartIndex) or persisted.lastConsolidatedIndex
	local carryMessageIndex = type(persisted.carryMessageIndex) == "number" and persisted.carryMessageIndex < lastConsolidatedIndex and persisted.carryMessageIndex or nil
	storage:writeSessionState(messages, lastConsolidatedIndex, carryMessageIndex)
	upsertStep(
		session.id,
		questionnaire.taskId,
		questionnaire.step,
		"ask_user",
		{status = "DONE", result = result}
	)
	local answerStep = getNextStepNumber(session.id, questionnaire.taskId)
	upsertStep(
		session.id,
		questionnaire.taskId,
		answerStep,
		"questionnaire_answer",
		{status = "DONE", result = result}
	)
	return {success = true, answerStep = answerStep, result = result}
end
function ____exports.cancelQuestionnaire(sessionId, questionnaireId, llmConfigId, llmConfig)
	local session = getSessionItem(sessionId)
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then
		return {success = false, message = "project task admission is closed"}
	end
	if not session then
		return {success = false, message = "session not found"}
	end
	if session.kind ~= "main" then
		return {success = false, message = "questionnaires are only available for main sessions"}
	end
	local questionnaire = getPendingQuestionnaire(sessionId)
	if not questionnaire or questionnaire.id ~= questionnaireId then
		return {success = false, message = "pending questionnaire not found or already handled"}
	end
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId)
	if not llmConfigRes.success then
		return {success = false, message = llmConfigRes.message}
	end
	if not removePendingQuestionnaire(session) then
		return {success = false, message = "failed to consume questionnaire file"}
	end
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, {}, "dismissed")
	if not replaced.success then
		savePendingQuestionnaire(session.projectRoot, questionnaire)
		return replaced
	end
	local t = now()
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId})
	session.workMode = "plan"
	local result = startPromptTask(
		session,
		buildQuestionnaireResumeQuery(questionnaire, {}, "dismissed"),
		nil,
		{},
		{
			workMode = "plan",
			persistUserMessage = false,
			resumeConversation = true,
			existingTaskId = questionnaire.taskId,
			initialStep = replaced.answerStep,
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId),
			llmConfig = llmConfigRes.config
		}
	)
	if not result.success then
		savePendingQuestionnaire(session.projectRoot, questionnaire)
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER")
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER")
		emitAgentSessionPatch(
			session.id,
			{
				session = getSessionItem(session.id),
				pendingQuestionnaire = questionnaire
			}
		)
		return result
	end
	emitAgentSessionPatch(
		sessionId,
		{
			session = getSessionItem(sessionId),
			pendingQuestionnaire = false
		}
	)
	return result
end
function ____exports.respondQuestionnaire(sessionId, questionnaireId, answers, llmConfigId, llmConfig)
	local session = getSessionItem(sessionId)
	if session and isProjectTaskAdmissionClosed(session.projectRoot) then
		return {success = false, message = "project task admission is closed"}
	end
	if not session then
		return {success = false, message = "session not found"}
	end
	if session.kind ~= "main" then
		return {success = false, message = "questionnaires are only available for main sessions"}
	end
	local questionnaire = getPendingQuestionnaire(sessionId)
	if not questionnaire or questionnaire.id ~= questionnaireId then
		return {success = false, message = "pending questionnaire not found"}
	end
	local validated = validateQuestionnaireAnswers(questionnaire.schema, answers)
	if not validated.success then
		return validated
	end
	local llmConfigRes = llmConfig and ({success = true, config = llmConfig}) or getLLMConfig(llmConfigId)
	if not llmConfigRes.success then
		return {success = false, message = llmConfigRes.message}
	end
	local t = now()
	if not removePendingQuestionnaire(session) then
		return {success = false, message = "failed to consume questionnaire file"}
	end
	local replaced = replaceQuestionnaireToolResult(session, questionnaire, validated.answers, "answered")
	if not replaced.success then
		savePendingQuestionnaire(session.projectRoot, questionnaire)
		return replaced
	end
	DB:exec(("UPDATE " .. TABLE_SESSION) .. " SET work_mode = 'plan', updated_at = ? WHERE id = ?", {t, sessionId})
	session.workMode = "plan"
	local result = startPromptTask(
		session,
		buildQuestionnaireResumeQuery(questionnaire, validated.answers, "answered"),
		nil,
		{},
		{
			workMode = "plan",
			persistUserMessage = false,
			resumeConversation = true,
			existingTaskId = questionnaire.taskId,
			initialStep = replaced.answerStep,
			initialAgentStepCount = getAgentStepCount(session.id, questionnaire.taskId),
			llmConfig = llmConfigRes.config
		}
	)
	if not result.success then
		savePendingQuestionnaire(session.projectRoot, questionnaire)
		Tools.setTaskStatus(questionnaire.taskId, "WAITING_USER")
		setSessionState(session.id, "WAITING_USER", questionnaire.taskId, "WAITING_USER")
		emitAgentSessionPatch(
			session.id,
			{
				session = getSessionItem(session.id),
				pendingQuestionnaire = questionnaire
			}
		)
		return result
	end
	emitAgentSessionPatch(
		sessionId,
		{
			session = getSessionItem(sessionId),
			pendingQuestionnaire = false
		}
	)
	return result
end
function ____exports.stopSessionTask(sessionId)
	local session = getSessionItem(sessionId)
	if not session or session.currentTaskId == nil then
		return {success = false, message = "session task not found"}
	end
	if session.currentTaskFinalizing == true or finalizingSubSessionTaskIds[session.currentTaskId] == true then
		return {success = false, message = "session task is finalizing"}
	end
	streamUpdates:clear(sessionId, session.currentTaskId, App.runningTime)
	local normalizedSession = normalizeSessionRuntimeState(session)
	local localControl = activeLocalAgentControls[session.currentTaskId]
	if localControl ~= nil then
		localControl:stop()
		return {success = true, stopping = true}
	end
	local stopToken = activeStopTokens[session.currentTaskId]
	if stopToken == nil then
		if normalizedSession.currentTaskStatus == "STOPPED" then
			return {success = true, recovered = true}
		end
		return {success = false, message = "task is not running"}
	end
	if stopToken.stopped then
		return {success = true, stopping = true}
	end
	stopToken.stopped = true
	stopToken.reason = getDefaultUseChineseResponse() and "用户已中断" or "stopped by user"
	return {success = true, stopping = true}
end
function ____exports.getCurrentTaskId(sessionId)
	local ____opt_135 = getSessionItem(sessionId)
	return ____opt_135 and ____opt_135.currentTaskId
end
--- Trusted host lifecycle only. Quiescent does not mean persisted or resumable.
function ____exports.beginProjectTaskQuiescence(sessionId)
	local owner = getSessionItem(sessionId)
	if not owner then
		return {success = false, message = "session not found"}
	end
	local projectRoot = owner.projectRoot
	local release = holdProjectTaskAdmission(projectRoot)
	local closed = false
	return {
		success = true,
		projectRoot = projectRoot,
		close = function()
			if not closed then
				closed = true
				release()
			end
		end,
		poll = function()
			if closed then
				return {success = false, message = "quiescence handle closed"}
			end
			local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. " FROM ") .. TABLE_SESSION) .. " WHERE project_root = ? ORDER BY id ASC", {projectRoot})
			if not rows then
				return {success = false, message = "failed to inspect project tasks"}
			end
			local pending = {}
			for ____, row in ipairs(rows) do
				do
					local session = rowToSession(row)
					local taskId = session.currentTaskId
					if taskId == nil then
						goto __continue551
					end
					local finalizing = finalizingSubSessionTaskIds[taskId] == true
					if not finalizing and activeStopTokens[taskId] == nil and session.currentTaskStatus ~= "RUNNING" then
						goto __continue551
					end
					local result = finalizing and ({success = false, message = "session task is finalizing"}) or ____exports.stopSessionTask(session.id)
					local ____session_id_138 = session.id
					local ____taskId_139 = taskId
					local ____finalizing_140 = finalizing
					local ____result_success_141 = result.success
					local ____result_success_137
					if result.success then
						____result_success_137 = nil
					else
						____result_success_137 = result.message
					end
					pending[#pending + 1] = {
						sessionId = ____session_id_138,
						taskId = ____taskId_139,
						finalizing = ____finalizing_140,
						stopRequested = ____result_success_141,
						message = ____result_success_137
					}
				end
				::__continue551::
			end
			return {success = true, quiescent = #pending == 0, pending = pending}
		end
	}
end
function ____exports.validateTaskAccess(sessionId, taskId)
	local session = getSessionItem(sessionId)
	if not session then
		return {success = false, message = "session not found"}
	end
	if taskId <= 0 or __TS__ArrayIndexOf(
		getSessionOperableTaskIds(sessionId),
		taskId
	) < 0 then
		return {success = false, message = "task is not operable for this session"}
	end
	return {success = true, session = session}
end
function ____exports.validateCheckpointAccess(sessionId, checkpointId)
	if checkpointId <= 0 then
		return {success = false, message = "invalid checkpointId"}
	end
	local checkpoint = Tools.getCheckpoint(checkpointId)
	if not checkpoint then
		return {success = false, message = "checkpoint not found"}
	end
	local taskAccess = ____exports.validateTaskAccess(sessionId, checkpoint.taskId)
	if not taskAccess.success then
		return taskAccess
	end
	return {success = true, session = taskAccess.session, checkpoint = checkpoint}
end
function ____exports.listRunningSessions()
	local rows = queryRows(((("SELECT " .. SESSION_SELECT_COLUMNS) .. "\n\t\tFROM ") .. TABLE_SESSION) .. "\n\t\tWHERE current_task_status = ?\n\t\tORDER BY updated_at DESC, id DESC", {"RUNNING"}) or ({})
	local sessions = {}
	do
		local i = 0
		while i < #rows do
			local session = normalizeSessionRuntimeState(rowToSession(rows[i + 1]))
			if session.currentTaskStatus == "RUNNING" then
				sessions[#sessions + 1] = session
			end
			i = i + 1
		end
	end
	return {success = true, sessions = sessions}
end
return ____exports
