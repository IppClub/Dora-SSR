-- [ts]: CodingAgent.ts
local ____lualib = require("lualib_bundle") -- 1
local __TS__ArrayIsArray = ____lualib.__TS__ArrayIsArray -- 1
local __TS__ObjectAssign = ____lualib.__TS__ObjectAssign -- 1
local __TS__StringTrim = ____lualib.__TS__StringTrim -- 1
local __TS__Delete = ____lualib.__TS__Delete -- 1
local __TS__StringEndsWith = ____lualib.__TS__StringEndsWith -- 1
local __TS__StringSplit = ____lualib.__TS__StringSplit -- 1
local __TS__SparseArrayNew = ____lualib.__TS__SparseArrayNew -- 1
local __TS__SparseArrayPush = ____lualib.__TS__SparseArrayPush -- 1
local __TS__SparseArraySpread = ____lualib.__TS__SparseArraySpread -- 1
local __TS__ArraySlice = ____lualib.__TS__ArraySlice -- 1
local __TS__ArraySort = ____lualib.__TS__ArraySort -- 1
local __TS__ArrayIndexOf = ____lualib.__TS__ArrayIndexOf -- 1
local __TS__AsyncAwaiter = ____lualib.__TS__AsyncAwaiter -- 1
local __TS__Await = ____lualib.__TS__Await -- 1
local __TS__ArrayMap = ____lualib.__TS__ArrayMap -- 1
local __TS__Number = ____lualib.__TS__Number -- 1
local __TS__StringSlice = ____lualib.__TS__StringSlice -- 1
local __TS__StringAccess = ____lualib.__TS__StringAccess -- 1
local __TS__NumberIsFinite = ____lualib.__TS__NumberIsFinite -- 1
local __TS__ArrayFilter = ____lualib.__TS__ArrayFilter -- 1
local __TS__ArrayPush = ____lualib.__TS__ArrayPush -- 1
local __TS__StringSubstring = ____lualib.__TS__StringSubstring -- 1
local __TS__StringStartsWith = ____lualib.__TS__StringStartsWith -- 1
local __TS__Class = ____lualib.__TS__Class -- 1
local __TS__ClassExtends = ____lualib.__TS__ClassExtends -- 1
local Map = ____lualib.Map -- 1
local __TS__StringIncludes = ____lualib.__TS__StringIncludes -- 1
local __TS__New = ____lualib.__TS__New -- 1
local Error = ____lualib.Error -- 1
local RangeError = ____lualib.RangeError -- 1
local ReferenceError = ____lualib.ReferenceError -- 1
local SyntaxError = ____lualib.SyntaxError -- 1
local TypeError = ____lualib.TypeError -- 1
local URIError = ____lualib.URIError -- 1
local __TS__PromiseAll = ____lualib.__TS__PromiseAll -- 1
local ____exports = {} -- 1
local isRecord, isArray, emitAgentEvent, getCancelledReason, truncateText, utf8TakeHead, getReplyLanguageDirective, replacePromptVars, limitReadContentForHistory, sanitizeReadResultForHistory, sanitizeSearchMatchesForHistory, sanitizeSearchResultForHistory, sanitizeListFilesResultForHistory, sanitizeBuildResultForHistory, getDecisionToolDefinitions, isToolAllowedForRole, getFinishMessage, normalizeCompletionText, normalizeCompletionTextList, getCompletionReport, persistHistoryState, getActiveConversationMessages, getActiveRealMessageCount, applyCompressedSessionState, ensureToolCallId, hasXMLParam, inferToolNameFromXMLParams, parseDSMLAttribute, extractDSMLReason, parseDSMLToolCallObjectFromText, parseXMLToolCallObjectFromText, parseDecisionObject, getDecisionPath, validateDecisionForShared, clampIntegerParam, parseReadLineParam, validateDecision, validateCompletionForRole, buildAgentSystemPrompt, buildSkillsSection, isFinalDecisionTurn, buildXmlDecisionInstruction, tryParseAndValidateDecision, executeToolAction, sanitizeToolActionResultForHistory, emitAgentTaskFinishEvent, COMPLETION_TEXT_MAX_CHARS, COMPLETION_LIST_MAX_ITEMS, COMPLETION_EVIDENCE_MAX_ITEMS, EditFileAction -- 1
local ____Dora = require("Dora") -- 2
local App = ____Dora.App -- 2
local Path = ____Dora.Path -- 2
local Content = ____Dora.Content -- 2
local ____flow = require("Agent.flow") -- 3
local Flow = ____flow.Flow -- 3
local Node = ____flow.Node -- 3
local ____Utils = require("Agent.Utils") -- 4
local callLLMStreamAggregated = ____Utils.callLLMStreamAggregated -- 4
local Log = ____Utils.Log -- 4
local getActiveLLMConfig = ____Utils.getActiveLLMConfig -- 4
local createLocalToolCallId = ____Utils.createLocalToolCallId -- 4
local parseSimpleXMLChildren = ____Utils.parseSimpleXMLChildren -- 4
local parseXMLObjectFromText = ____Utils.parseXMLObjectFromText -- 4
local safeJsonDecode = ____Utils.safeJsonDecode -- 4
local safeJsonEncode = ____Utils.safeJsonEncode -- 4
local sanitizeUTF8 = ____Utils.sanitizeUTF8 -- 4
local estimateTextTokens = ____Utils.estimateTextTokens -- 4
local Tools = require("Agent.Tools") -- 6
local ____Memory = require("Agent.Memory") -- 7
local MemoryCompressor = ____Memory.MemoryCompressor -- 7
local AgentToolRegistry = require("Agent.AgentToolRegistry") -- 9
local AgentSkills = require("Agent.AgentSkills") -- 11
local AgentConfig = require("Agent.AgentConfig") -- 12
local AgentRuntimePolicy = require("Agent.AgentRuntimePolicy") -- 13
local ____AgentQuestionnaire = require("Agent.AgentQuestionnaire") -- 14
local normalizeQuestionnaire = ____AgentQuestionnaire.normalizeQuestionnaire -- 14
function isRecord(value) -- 17
	return type(value) == "table" -- 18
end -- 18
function isArray(value) -- 21
	return __TS__ArrayIsArray(value) -- 22
end -- 22
function emitAgentEvent(shared, event) -- 445
	if shared.onEvent then -- 445
		do -- 445
			local function ____catch(____error) -- 445
				Log( -- 450
					"Error", -- 450
					"[CodingAgent] onEvent handler failed: " .. tostring(____error) -- 450
				) -- 450
			end -- 450
			local ____try, ____hasReturned = pcall(function() -- 450
				shared:onEvent(event) -- 448
			end) -- 448
			if not ____try then -- 448
				____catch(____hasReturned) -- 448
			end -- 448
		end -- 448
	end -- 448
end -- 448
function getCancelledReason(shared) -- 619
	if shared.stopToken.reason and shared.stopToken.reason ~= "" then -- 619
		return shared.stopToken.reason -- 620
	end -- 620
	return shared.useChineseResponse and "已取消" or "cancelled" -- 621
end -- 621
function ____exports.normalizePolicyPath(path) -- 683
	return AgentRuntimePolicy.normalizeAgentPath(path) -- 684
end -- 683
--- Main-session memory is an Agent-authored workspace area. Keep this check
-- rooted so similarly named nested project directories do not accidentally
-- bypass authored-source validation and build cadence.
function ____exports.isMainAgentMemoryPath(path) -- 692
	return AgentRuntimePolicy.isMainAgentMemoryPath(path) -- 693
end -- 692
function truncateText(text, maxLen) -- 857
	if #text <= maxLen then -- 857
		return text -- 858
	end -- 858
	local nextPos = utf8.offset(text, maxLen + 1) -- 859
	if nextPos == nil then -- 859
		return text -- 860
	end -- 860
	return string.sub(text, 1, nextPos - 1) .. "..." -- 861
end -- 861
function utf8TakeHead(text, maxChars) -- 864
	if maxChars <= 0 or text == "" then -- 864
		return "" -- 865
	end -- 865
	local nextPos = utf8.offset(text, maxChars + 1) -- 866
	if nextPos == nil then -- 866
		return text -- 867
	end -- 867
	return string.sub(text, 1, nextPos - 1) -- 868
end -- 868
function getReplyLanguageDirective(shared) -- 871
	return shared.useChineseResponse and shared.promptPack.replyLanguageDirectiveZh or shared.promptPack.replyLanguageDirectiveEn -- 872
end -- 872
function replacePromptVars(template, vars) -- 877
	local output = template -- 878
	for key in pairs(vars) do -- 879
		output = table.concat( -- 880
			__TS__StringSplit(output, ("{{" .. key) .. "}}"), -- 880
			vars[key] or "" or "," -- 880
		) -- 880
	end -- 880
	return output -- 882
end -- 882
function limitReadContentForHistory(content, tool) -- 885
	local lines = __TS__StringSplit(content, "\n") -- 886
	local overLineLimit = #lines > AgentConfig.AGENT_LIMITS.historyReadFileMaxLines -- 887
	local limitedByLines = overLineLimit and table.concat( -- 888
		__TS__ArraySlice(lines, 0, AgentConfig.AGENT_LIMITS.historyReadFileMaxLines), -- 889
		"\n" -- 889
	) or content -- 889
	if #limitedByLines <= AgentConfig.AGENT_LIMITS.historyReadFileMaxChars and not overLineLimit then -- 889
		return content -- 892
	end -- 892
	local limited = #limitedByLines > AgentConfig.AGENT_LIMITS.historyReadFileMaxChars and utf8TakeHead(limitedByLines, AgentConfig.AGENT_LIMITS.historyReadFileMaxChars) or limitedByLines -- 894
	local reasons = {} -- 897
	if #content > AgentConfig.AGENT_LIMITS.historyReadFileMaxChars then -- 897
		reasons[#reasons + 1] = tostring(#content) .. " chars" -- 898
	end -- 898
	if #lines > AgentConfig.AGENT_LIMITS.historyReadFileMaxLines then -- 898
		reasons[#reasons + 1] = tostring(#lines) .. " lines" -- 899
	end -- 899
	local hint = "Narrow the requested line range." -- 900
	return (((((("[" .. tool) .. " content truncated for history (") .. table.concat(reasons, ", ")) .. "). ") .. hint) .. "]\n") .. limited -- 901
end -- 901
function sanitizeReadResultForHistory(tool, result) -- 916
	if tool ~= "read_file" or result.success ~= true or type(result.content) ~= "string" then -- 916
		return result -- 918
	end -- 918
	local clone = {} -- 920
	for key in pairs(result) do -- 921
		clone[key] = result[key] -- 922
	end -- 922
	clone.content = limitReadContentForHistory(result.content, tool) -- 924
	return clone -- 925
end -- 925
function sanitizeSearchMatchesForHistory(items, maxItems) -- 928
	local shown = math.min(#items, maxItems) -- 932
	local out = {} -- 933
	do -- 933
		local i = 0 -- 934
		while i < shown do -- 934
			local row = items[i + 1] -- 935
			out[#out + 1] = { -- 936
				file = row.file, -- 937
				line = row.line, -- 938
				content = type(row.content) == "string" and truncateText(row.content, 240) or row.content -- 939
			} -- 939
			i = i + 1 -- 934
		end -- 934
	end -- 934
	return out -- 944
end -- 944
function sanitizeSearchResultForHistory(tool, result) -- 947
	if result.success ~= true or not isArray(result.results) then -- 947
		return result -- 951
	end -- 951
	if tool ~= "grep_files" and tool ~= "search_dora_api" then -- 951
		return result -- 952
	end -- 952
	local clone = {} -- 953
	for key in pairs(result) do -- 954
		clone[key] = result[key] -- 955
	end -- 955
	local maxItems = tool == "grep_files" and AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches or AgentConfig.AGENT_LIMITS.historySearchDoraApiMaxMatches -- 957
	clone.results = sanitizeSearchMatchesForHistory(result.results, maxItems) -- 958
	if tool == "grep_files" and isArray(result.groupedResults) then -- 958
		local grouped = result.groupedResults -- 963
		local shown = math.min(#grouped, AgentConfig.AGENT_LIMITS.historySearchFilesMaxMatches) -- 964
		local sanitizedGroups = {} -- 965
		do -- 965
			local i = 0 -- 966
			while i < shown do -- 966
				local row = grouped[i + 1] -- 967
				sanitizedGroups[#sanitizedGroups + 1] = { -- 968
					file = row.file, -- 969
					totalMatches = row.totalMatches, -- 970
					matches = isArray(row.matches) and sanitizeSearchMatchesForHistory(row.matches, 3) or ({}) -- 971
				} -- 971
				i = i + 1 -- 966
			end -- 966
		end -- 966
		clone.groupedResults = sanitizedGroups -- 976
	end -- 976
	return clone -- 978
end -- 978
function sanitizeListFilesResultForHistory(result) -- 981
	if result.success ~= true or not isArray(result.files) then -- 981
		return result -- 982
	end -- 982
	local clone = {} -- 983
	for key in pairs(result) do -- 984
		clone[key] = result[key] -- 985
	end -- 985
	clone.files = __TS__ArraySlice(result.files, 0, AgentConfig.AGENT_LIMITS.historyListFilesMaxEntries) -- 987
	return clone -- 988
end -- 988
function sanitizeBuildResultForHistory(result) -- 991
	if not isArray(result.messages) then -- 991
		return result -- 992
	end -- 992
	local clone = {} -- 993
	for key in pairs(result) do -- 994
		clone[key] = result[key] -- 995
	end -- 995
	local messages = result.messages -- 997
	local ordered = __TS__ArraySort( -- 998
		__TS__ArraySlice(messages), -- 998
		function(____, a, b) -- 998
			local aFailed = a.success ~= true -- 999
			local bFailed = b.success ~= true -- 1000
			if aFailed == bFailed then -- 1000
				return 0 -- 1001
			end -- 1001
			return aFailed and -1 or 1 -- 1002
		end -- 998
	) -- 998
	local shown = math.min(#ordered, AgentConfig.AGENT_LIMITS.historyBuildMaxMessages) -- 1004
	local sanitized = {} -- 1005
	do -- 1005
		local i = 0 -- 1006
		while i < shown do -- 1006
			local item = ordered[i + 1] -- 1007
			local next = {} -- 1008
			for key in pairs(item) do -- 1009
				local value = item[key] -- 1010
				next[key] = key == "message" and type(value) == "string" and truncateText(value, AgentConfig.AGENT_LIMITS.historyBuildMessageMaxChars) or value -- 1011
			end -- 1011
			sanitized[#sanitized + 1] = next -- 1015
			i = i + 1 -- 1006
		end -- 1006
	end -- 1006
	clone.messages = sanitized -- 1017
	if #ordered > shown then -- 1017
		clone.truncatedMessages = #ordered - shown -- 1019
	end -- 1019
	return clone -- 1021
end -- 1021
function ____exports.getDecisionDisabledAgentTools(shared) -- 1039
	return __TS__ArraySlice(shared.disabledAgentTools) -- 1043
end -- 1039
function getDecisionToolDefinitions(shared) -- 1046
	local params = {SEARCH_DORA_API_LIMIT_MAX = tostring(AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax)} -- 1047
	local usesDefaultToolPrompts = shared.promptPack.toolDefinitionsDetailed == AgentToolRegistry.AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.mainAgentToolDefinitionsDetailed == AgentToolRegistry.MAIN_AGENT_TOOL_DEFINITIONS_DETAILED and shared.promptPack.xmlToolDefinitionsDetailed == AgentToolRegistry.XML_TOOL_DEFINITIONS_DETAILED -- 1048
	local base = shared.promptPack.toolDefinitionsDetailed -- 1051
	local mainAgentTools = shared.role == "main" and shared.promptPack.mainAgentToolDefinitionsDetailed or "" -- 1052
	if usesDefaultToolPrompts then -- 1052
		local definitions = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 1055
			shared.role, -- 1055
			{ -- 1055
				includeFinish = true, -- 1056
				includeXmlRules = true, -- 1057
				context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 1058
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1059
				workMode = shared.workMode -- 1060
			} -- 1060
		) -- 1060
		return replacePromptVars(definitions, params) -- 1062
	end -- 1062
	local withRole = replacePromptVars(base .. mainAgentTools, params) -- 1064
	if (shared and shared.decisionMode) ~= "xml" then -- 1064
		return withRole -- 1069
	end -- 1069
	local xmlToolDefinitionsDetailed = shared.promptPack.xmlToolDefinitionsDetailed -- 1071
	return replacePromptVars(withRole .. xmlToolDefinitionsDetailed, params) -- 1072
end -- 1072
function isToolAllowedForRole(shared, tool) -- 1086
	return __TS__ArrayIndexOf( -- 1087
		AgentToolRegistry.getAllowedToolsForRole( -- 1087
			shared.role, -- 1087
			{ -- 1087
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1088
				workMode = shared.workMode -- 1089
			} -- 1089
		), -- 1089
		tool -- 1090
	) >= 0 -- 1090
end -- 1090
function getFinishMessage(params, fallback) -- 1504
	if fallback == nil then -- 1504
		fallback = "" -- 1504
	end -- 1504
	if type(params.message) == "string" and __TS__StringTrim(params.message) ~= "" then -- 1504
		return __TS__StringTrim(params.message) -- 1506
	end -- 1506
	if type(params.response) == "string" and __TS__StringTrim(params.response) ~= "" then -- 1506
		return __TS__StringTrim(params.response) -- 1509
	end -- 1509
	if type(params.summary) == "string" and __TS__StringTrim(params.summary) ~= "" then -- 1509
		return __TS__StringTrim(params.summary) -- 1512
	end -- 1512
	return __TS__StringTrim(fallback) -- 1514
end -- 1514
function normalizeCompletionText(value) -- 1521
	if type(value) ~= "string" then -- 1521
		return "" -- 1522
	end -- 1522
	return __TS__StringSlice( -- 1523
		__TS__StringTrim(sanitizeUTF8(value)), -- 1523
		0, -- 1523
		COMPLETION_TEXT_MAX_CHARS -- 1523
	) -- 1523
end -- 1523
function normalizeCompletionTextList(value, maxItems) -- 1526
	if maxItems == nil then -- 1526
		maxItems = COMPLETION_LIST_MAX_ITEMS -- 1526
	end -- 1526
	if not isArray(value) then -- 1526
		return {} -- 1527
	end -- 1527
	local items = {} -- 1528
	do -- 1528
		local i = 0 -- 1529
		while i < #value and #items < maxItems do -- 1529
			local item = normalizeCompletionText(value[i + 1]) -- 1530
			if item ~= "" and __TS__ArrayIndexOf(items, item) < 0 then -- 1530
				items[#items + 1] = item -- 1531
			end -- 1531
			i = i + 1 -- 1529
		end -- 1529
	end -- 1529
	return items -- 1533
end -- 1533
function ____exports.normalizeAgentCompletionReport(value) -- 1536
	local row = value and not isArray(value) and isRecord(value) and value or ({}) -- 1537
	local outcome = (row.outcome == "partial" or row.outcome == "blocked") and row.outcome or "completed" -- 1538
	local validation = {} -- 1541
	if isArray(row.validation) then -- 1541
		do -- 1541
			local i = 0 -- 1543
			while i < #row.validation and #validation < COMPLETION_LIST_MAX_ITEMS do -- 1543
				do -- 1543
					local raw = row.validation[i + 1] -- 1544
					if not raw or isArray(raw) or not isRecord(raw) then -- 1544
						goto __continue224 -- 1545
					end -- 1545
					local kind = (raw.kind == "runtime" or raw.kind == "manual") and raw.kind or (raw.kind == "build" and "build" or nil) -- 1546
					local result = (raw.result == "passed" or raw.result == "failed" or raw.result == "not_run") and raw.result or nil -- 1547
					if kind == nil or result == nil then -- 1547
						goto __continue224 -- 1548
					end -- 1548
					validation[#validation + 1] = { -- 1549
						kind = kind, -- 1550
						result = result, -- 1551
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS) -- 1552
					} -- 1552
				end -- 1552
				::__continue224:: -- 1552
				i = i + 1 -- 1543
			end -- 1543
		end -- 1543
	end -- 1543
	local learningCandidates = {} -- 1556
	if isArray(row.learningCandidates) then -- 1556
		do -- 1556
			local i = 0 -- 1558
			while i < #row.learningCandidates and #learningCandidates < COMPLETION_LIST_MAX_ITEMS do -- 1558
				do -- 1558
					local raw = row.learningCandidates[i + 1] -- 1559
					if not raw or isArray(raw) or not isRecord(raw) then -- 1559
						goto __continue229 -- 1560
					end -- 1560
					local claim = normalizeCompletionText(raw.claim) -- 1561
					if claim == "" then -- 1561
						goto __continue229 -- 1562
					end -- 1562
					learningCandidates[#learningCandidates + 1] = { -- 1563
						claim = claim, -- 1564
						scope = (raw.scope == "file" or raw.scope == "engine") and raw.scope or "project", -- 1565
						evidence = normalizeCompletionTextList(raw.evidence, COMPLETION_EVIDENCE_MAX_ITEMS), -- 1566
						confidence = raw.confidence == "inferred" and "inferred" or "observed" -- 1567
					} -- 1567
				end -- 1567
				::__continue229:: -- 1567
				i = i + 1 -- 1558
			end -- 1558
		end -- 1558
	end -- 1558
	return { -- 1571
		outcome = outcome, -- 1572
		validation = validation, -- 1573
		knownIssues = normalizeCompletionTextList(row.knownIssues), -- 1574
		assumptions = normalizeCompletionTextList(row.assumptions), -- 1575
		learningCandidates = learningCandidates -- 1576
	} -- 1576
end -- 1536
function getCompletionReport(params) -- 1580
	return ____exports.normalizeAgentCompletionReport(params) -- 1581
end -- 1581
function persistHistoryState(shared) -- 1584
	shared.memory.compressor:getStorage():writeSessionState(shared.messages, shared.lastConsolidatedIndex, shared.carryMessageIndex) -- 1585
end -- 1585
function getActiveConversationMessages(shared) -- 1592
	local activeMessages = {} -- 1593
	if type(shared.carryMessageIndex) == "number" and shared.carryMessageIndex >= 0 and shared.carryMessageIndex < shared.lastConsolidatedIndex and shared.carryMessageIndex < #shared.messages then -- 1593
		activeMessages[#activeMessages + 1] = __TS__ObjectAssign({}, shared.messages[shared.carryMessageIndex + 1]) -- 1600
	end -- 1600
	do -- 1600
		local i = shared.lastConsolidatedIndex -- 1604
		while i < #shared.messages do -- 1604
			activeMessages[#activeMessages + 1] = shared.messages[i + 1] -- 1605
			i = i + 1 -- 1604
		end -- 1604
	end -- 1604
	return activeMessages -- 1607
end -- 1607
function getActiveRealMessageCount(shared) -- 1610
	return math.max(0, #shared.messages - shared.lastConsolidatedIndex) -- 1611
end -- 1611
function applyCompressedSessionState(shared, compressedCount, carryMessageIndex, sessionSummary) -- 1614
	local syntheticPrefixCount = type(shared.carryMessageIndex) == "number" and 1 or 0 -- 1620
	local previousActiveStart = shared.lastConsolidatedIndex -- 1621
	local realCompressedCount = math.max(0, compressedCount - syntheticPrefixCount) -- 1622
	shared.lastConsolidatedIndex = math.min(#shared.messages, previousActiveStart + realCompressedCount) -- 1623
	if type(carryMessageIndex) == "number" then -- 1623
		if syntheticPrefixCount > 0 and carryMessageIndex == 0 then -- 1623
		else -- 1623
			local carryOffset = syntheticPrefixCount > 0 and carryMessageIndex - 1 or carryMessageIndex -- 1631
			shared.carryMessageIndex = carryOffset >= 0 and previousActiveStart + carryOffset or nil -- 1634
		end -- 1634
	else -- 1634
		shared.carryMessageIndex = nil -- 1639
	end -- 1639
	if type(shared.carryMessageIndex) == "number" and (shared.carryMessageIndex < 0 or shared.carryMessageIndex >= shared.lastConsolidatedIndex or shared.carryMessageIndex >= #shared.messages) then -- 1639
		shared.carryMessageIndex = nil -- 1649
	end -- 1649
	local hasUncompressedTail = shared.lastConsolidatedIndex < #shared.messages -- 1657
	shared.resumeCheckpointPending = true -- 1658
	shared.resumeRequiredTool = nil -- 1659
	shared.resumeNarrowReadMode = true -- 1660
	if shared.unbuiltEdits == true then -- 1660
		shared.resumeRequiredTool = "build" -- 1668
	end -- 1668
	local carryStartsNewTask = type(shared.carryMessageIndex) == "number" and shared.step <= 1 -- 1677
	if not hasUncompressedTail and not carryStartsNewTask and shared.resumeRequiredTool == nil and type(sessionSummary) == "string" then -- 1677
		local marker = "**Next tool**:" -- 1688
		local markerIndex = (string.find(sessionSummary, marker, nil, true) or 0) - 1 -- 1689
		if markerIndex >= 0 then -- 1689
			local nextToolLine = __TS__StringSlice(sessionSummary, markerIndex, markerIndex + 120) -- 1691
			local toolNames = { -- 1692
				"read_file", -- 1693
				"edit_file", -- 1693
				"delete_file", -- 1693
				"grep_files", -- 1693
				"search_dora_api", -- 1693
				"glob_files", -- 1694
				"build", -- 1694
				"fetch_url", -- 1694
				"execute_command", -- 1694
				"list_sub_agents", -- 1694
				"spawn_sub_agent", -- 1695
				"finish" -- 1695
			} -- 1695
			do -- 1695
				local i = 0 -- 1697
				while i < #toolNames do -- 1697
					local tool = toolNames[i + 1] -- 1698
					if (string.find(nextToolLine, ("`" .. tool) .. "`", nil, true) or 0) - 1 >= 0 then -- 1698
						shared.resumeRequiredTool = tool -- 1700
						break -- 1701
					end -- 1701
					i = i + 1 -- 1697
				end -- 1697
			end -- 1697
		end -- 1697
	end -- 1697
	if shared.hasSpawnedSubAgentThisTask == true and shared.resumeRequiredTool == "list_sub_agents" then -- 1697
		shared.resumeRequiredTool = nil -- 1707
	end -- 1707
	if shared.resumeRequiredTool ~= nil and not isToolAllowedForRole(shared, shared.resumeRequiredTool) then -- 1707
		shared.resumeRequiredTool = nil -- 1710
	end -- 1710
end -- 1710
function ensureToolCallId(toolCallId) -- 1725
	if toolCallId and toolCallId ~= "" then -- 1725
		return toolCallId -- 1726
	end -- 1726
	return createLocalToolCallId() -- 1727
end -- 1727
function hasXMLParam(params, name) -- 1760
	return params[name] ~= nil -- 1761
end -- 1761
function inferToolNameFromXMLParams(params) -- 1764
	if hasXMLParam(params, "old_str") or hasXMLParam(params, "new_str") then -- 1764
		return "edit_file" -- 1766
	end -- 1766
	if hasXMLParam(params, "target_file") then -- 1766
		return "delete_file" -- 1769
	end -- 1769
	if hasXMLParam(params, "startLine") or hasXMLParam(params, "endLine") then -- 1769
		if hasXMLParam(params, "path") then -- 1769
			return "read_file" -- 1772
		end -- 1772
		return nil -- 1773
	end -- 1773
	if hasXMLParam(params, "docSource") or hasXMLParam(params, "programmingLanguage") then -- 1773
		if hasXMLParam(params, "pattern") then -- 1773
			return "search_dora_api" -- 1776
		end -- 1776
		return nil -- 1777
	end -- 1777
	if hasXMLParam(params, "groupByFile") or hasXMLParam(params, "caseSensitive") then -- 1777
		if hasXMLParam(params, "pattern") then -- 1777
			return "grep_files" -- 1780
		end -- 1780
		return nil -- 1781
	end -- 1781
	if hasXMLParam(params, "globs") then -- 1781
		if hasXMLParam(params, "pattern") then -- 1781
			return "grep_files" -- 1784
		end -- 1784
		return "glob_files" -- 1785
	end -- 1785
	if hasXMLParam(params, "maxEntries") then -- 1785
		return "glob_files" -- 1788
	end -- 1788
	if hasXMLParam(params, "message") or hasXMLParam(params, "response") or hasXMLParam(params, "summary") then -- 1788
		return "finish" -- 1791
	end -- 1791
	if hasXMLParam(params, "title") or hasXMLParam(params, "prompt") or hasXMLParam(params, "expectedOutput") or hasXMLParam(params, "filesHint") then -- 1791
		return "spawn_sub_agent" -- 1794
	end -- 1794
	if hasXMLParam(params, "status") or hasXMLParam(params, "query") then -- 1794
		return "list_sub_agents" -- 1797
	end -- 1797
	return nil -- 1799
end -- 1799
function parseDSMLAttribute(source, offset, name) -- 1802
	local attrOpen = name .. "=\"" -- 1803
	local attrStart = (string.find( -- 1804
		source, -- 1804
		attrOpen, -- 1804
		math.max(offset + 1, 1), -- 1804
		true -- 1804
	) or 0) - 1 -- 1804
	if attrStart < 0 then -- 1804
		return {success = false, message = ("missing " .. name) .. " attribute"} -- 1805
	end -- 1805
	local valueStart = attrStart + #attrOpen -- 1806
	local valueEnd = (string.find( -- 1807
		source, -- 1807
		"\"", -- 1807
		math.max(valueStart + 1, 1), -- 1807
		true -- 1807
	) or 0) - 1 -- 1807
	if valueEnd < 0 then -- 1807
		return {success = false, message = ("unterminated " .. name) .. " attribute"} -- 1808
	end -- 1808
	return { -- 1809
		success = true, -- 1810
		value = __TS__StringSlice(source, valueStart, valueEnd), -- 1811
		next = valueEnd + 1 -- 1812
	} -- 1812
end -- 1812
function extractDSMLReason(text, invokeStart, tool) -- 1816
	local toolCallsStart = (string.find(text, "<｜｜DSML｜｜tool_calls>", nil, true) or 0) - 1 -- 1817
	local before = toolCallsStart >= 0 and toolCallsStart < invokeStart and __TS__StringTrim(__TS__StringSlice(text, 0, toolCallsStart)) or __TS__StringTrim(__TS__StringSlice(text, 0, invokeStart)) -- 1818
	if before ~= "" and (string.find(before, "<｜｜DSML", nil, true) or 0) - 1 < 0 then -- 1818
		return before -- 1821
	end -- 1821
	if tool == "finish" then -- 1821
		return "" -- 1822
	end -- 1822
	return "Converted provider-native tool call syntax to XML." -- 1823
end -- 1823
function parseDSMLToolCallObjectFromText(text) -- 1826
	local invokeOpen = "<｜｜DSML｜｜invoke name=\"" -- 1827
	local invokeStart = (string.find(text, invokeOpen, nil, true) or 0) - 1 -- 1828
	if invokeStart < 0 then -- 1828
		return {success = false, message = "missing DSML invoke"} -- 1829
	end -- 1829
	local nameStart = invokeStart + #invokeOpen -- 1830
	local nameEnd = (string.find( -- 1831
		text, -- 1831
		"\"", -- 1831
		math.max(nameStart + 1, 1), -- 1831
		true -- 1831
	) or 0) - 1 -- 1831
	if nameEnd < 0 then -- 1831
		return {success = false, message = "unterminated DSML invoke name"} -- 1832
	end -- 1832
	local toolName = __TS__StringSlice(text, nameStart, nameEnd) -- 1833
	if not AgentToolRegistry.isKnownToolName(toolName) then -- 1833
		return {success = false, message = "unknown DSML tool: " .. toolName} -- 1835
	end -- 1835
	local invokeOpenEnd = (string.find( -- 1837
		text, -- 1837
		">", -- 1837
		math.max(nameEnd + 1, 1), -- 1837
		true -- 1837
	) or 0) - 1 -- 1837
	if invokeOpenEnd < 0 then -- 1837
		return {success = false, message = "unterminated DSML invoke open tag"} -- 1838
	end -- 1838
	local invokeClose = "</｜｜DSML｜｜invoke>" -- 1839
	local invokeEnd = (string.find( -- 1840
		text, -- 1840
		invokeClose, -- 1840
		math.max(invokeOpenEnd + 1 + 1, 1), -- 1840
		true -- 1840
	) or 0) - 1 -- 1840
	if invokeEnd < 0 then -- 1840
		return {success = false, message = "missing DSML invoke close tag"} -- 1841
	end -- 1841
	local body = __TS__StringSlice(text, invokeOpenEnd + 1, invokeEnd) -- 1843
	local params = {} -- 1844
	local paramOpen = "<｜｜DSML｜｜parameter" -- 1845
	local paramClose = "</｜｜DSML｜｜parameter>" -- 1846
	local pos = 0 -- 1847
	while pos < #body do -- 1847
		local start = (string.find( -- 1849
			body, -- 1849
			paramOpen, -- 1849
			math.max(pos + 1, 1), -- 1849
			true -- 1849
		) or 0) - 1 -- 1849
		if start < 0 then -- 1849
			break -- 1850
		end -- 1850
		local openEnd = (string.find( -- 1851
			body, -- 1851
			">", -- 1851
			math.max(start + #paramOpen + 1, 1), -- 1851
			true -- 1851
		) or 0) - 1 -- 1851
		if openEnd < 0 then -- 1851
			return {success = false, message = "unterminated DSML parameter open tag"} -- 1852
		end -- 1852
		local name = parseDSMLAttribute(body, start + #paramOpen, "name") -- 1853
		if not name.success then -- 1853
			return name -- 1854
		end -- 1854
		local close = (string.find( -- 1855
			body, -- 1855
			paramClose, -- 1855
			math.max(openEnd + 1 + 1, 1), -- 1855
			true -- 1855
		) or 0) - 1 -- 1855
		if close < 0 then -- 1855
			return {success = false, message = "missing DSML parameter close tag"} -- 1856
		end -- 1856
		params[name.value] = __TS__StringSlice(body, openEnd + 1, close) -- 1857
		pos = close + #paramClose -- 1858
	end -- 1858
	return { -- 1860
		success = true, -- 1861
		obj = { -- 1862
			tool = toolName, -- 1863
			reason = extractDSMLReason(text, invokeStart, toolName), -- 1864
			params = params -- 1865
		} -- 1865
	} -- 1865
end -- 1865
function parseXMLToolCallObjectFromText(text) -- 1870
	local children = parseXMLObjectFromText(text, "tool_call") -- 1871
	local rawObj -- 1872
	if children.success then -- 1872
		rawObj = children.obj -- 1874
	else -- 1874
		local dsml = parseDSMLToolCallObjectFromText(text) -- 1876
		if dsml.success then -- 1876
			return dsml -- 1877
		end -- 1877
		local toolStart = (string.find(text, "<tool>", nil, true) or 0) - 1 -- 1878
		local paramsCloseToken = "</params>" -- 1879
		if toolStart >= 0 then -- 1879
			local paramsClose = (string.find( -- 1881
				text, -- 1881
				paramsCloseToken, -- 1881
				math.max(toolStart + 1, 1), -- 1881
				true -- 1881
			) or 0) - 1 -- 1881
			if paramsClose >= toolStart then -- 1881
				local bareCandidate = __TS__StringTrim(__TS__StringSlice(text, toolStart, paramsClose + #paramsCloseToken)) -- 1883
				local bare = parseSimpleXMLChildren(bareCandidate) -- 1884
				if bare.success and type(bare.obj.tool) == "string" and type(bare.obj.params) == "string" then -- 1884
					rawObj = bare.obj -- 1886
				end -- 1886
			end -- 1886
		end -- 1886
		if rawObj == nil then -- 1886
			local paramsOpen = (string.find(text, "<params>", nil, true) or 0) - 1 -- 1891
			if paramsOpen < 0 then -- 1891
				return children -- 1892
			end -- 1892
			local paramsCloseOnly = (string.find( -- 1893
				text, -- 1893
				paramsCloseToken, -- 1893
				math.max(paramsOpen + 1, 1), -- 1893
				true -- 1893
			) or 0) - 1 -- 1893
			if paramsCloseOnly < paramsOpen then -- 1893
				return children -- 1894
			end -- 1894
			local paramsTextOnly = __TS__StringSlice(text, paramsOpen + #"<params>", paramsCloseOnly) -- 1895
			local paramsOnly = parseSimpleXMLChildren(paramsTextOnly) -- 1896
			if not paramsOnly.success then -- 1896
				return children -- 1897
			end -- 1897
			local inferredTool = inferToolNameFromXMLParams(paramsOnly.obj) -- 1898
			if inferredTool == nil then -- 1898
				return children -- 1899
			end -- 1899
			local ____temp_52 -- 1904
			if inferredTool == "finish" then -- 1904
				____temp_52 = nil -- 1904
			else -- 1904
				____temp_52 = "Inferred tool from XML params." -- 1904
			end -- 1904
			return {success = true, obj = {tool = inferredTool, reason = ____temp_52, params = paramsOnly.obj}} -- 1900
		end -- 1900
	end -- 1900
	if rawObj == nil then -- 1900
		return children -- 1910
	end -- 1910
	local paramsText = type(rawObj.params) == "string" and rawObj.params or "" -- 1911
	local params = paramsText ~= "" and parseSimpleXMLChildren(paramsText) or ({success = true, obj = {}}) -- 1912
	if not params.success then -- 1912
		return {success = false, message = params.message} -- 1916
	end -- 1916
	return {success = true, obj = {tool = rawObj.tool, reason = rawObj.reason, params = params.obj}} -- 1918
end -- 1918
function parseDecisionObject(rawObj) -- 2014
	if type(rawObj.tool) ~= "string" then -- 2014
		return {success = false, message = "missing tool"} -- 2015
	end -- 2015
	local tool = rawObj.tool -- 2016
	if not AgentToolRegistry.isKnownToolName(tool) then -- 2016
		return {success = false, message = "unknown tool: " .. tool} -- 2018
	end -- 2018
	local reason = type(rawObj.reason) == "string" and __TS__StringTrim(rawObj.reason) or nil -- 2020
	if tool ~= "finish" and (not reason or reason == "") then -- 2020
		return {success = false, message = tool .. " requires top-level reason"} -- 2024
	end -- 2024
	local params = isRecord(rawObj.params) and rawObj.params or ({}) -- 2026
	return {success = true, tool = tool, params = params, reason = reason} -- 2027
end -- 2027
function getDecisionPath(params) -- 2149
	if type(params.path) == "string" then -- 2149
		return __TS__StringTrim(params.path) -- 2150
	end -- 2150
	if type(params.target_file) == "string" then -- 2150
		return __TS__StringTrim(params.target_file) -- 2151
	end -- 2151
	return "" -- 2152
end -- 2152
function validateDecisionForShared(shared, tool, params, enforceFinalTurn) -- 2155
	if enforceFinalTurn == nil then -- 2155
		enforceFinalTurn = false -- 2159
	end -- 2159
	if enforceFinalTurn and isFinalDecisionTurn(shared) and tool ~= "finish" then -- 2159
		return {success = false, message = "the final task turn must call finish; use completed only when all acceptance criteria have evidence, otherwise use partial with unverified items and the next action"} -- 2162
	end -- 2162
	if not isToolAllowedForRole(shared, tool) then -- 2162
		return {success = false, message = (((tool .. " is not allowed in ") .. shared.workMode) .. " mode for role ") .. shared.role} -- 2165
	end -- 2165
	if shared.workMode == "plan" and (tool == "edit_file" or tool == "delete_file") then -- 2165
		local path = getDecisionPath(params) -- 2168
		if not AgentRuntimePolicy.isAgentPlanPath(path) then -- 2168
			return {success = false, message = (tool .. " in Plan mode may only write under ") .. AgentRuntimePolicy.AGENT_PLAN_DIR} -- 2170
		end -- 2170
	end -- 2170
	if tool == "delete_file" then -- 2170
		local path = AgentRuntimePolicy.normalizeAgentPath(getDecisionPath(params)) -- 2174
		if path == AgentRuntimePolicy.AGENT_PLAN_FILE or path == AgentRuntimePolicy.AGENT_PROGRESS_FILE then -- 2174
			return {success = false, message = path .. " is a fixed living document and cannot be deleted"} -- 2176
		end -- 2176
	end -- 2176
	return {success = true} -- 2179
end -- 2179
function clampIntegerParam(value, fallback, minValue, maxValue) -- 2182
	local num = __TS__Number(value) -- 2183
	if not __TS__NumberIsFinite(num) then -- 2183
		num = fallback -- 2184
	end -- 2184
	num = math.floor(num) -- 2185
	if num < minValue then -- 2185
		num = minValue -- 2186
	end -- 2186
	if maxValue ~= nil and num > maxValue then -- 2186
		num = maxValue -- 2187
	end -- 2187
	return num -- 2188
end -- 2188
function parseReadLineParam(value, fallback, paramName) -- 2191
	local num = __TS__Number(value) -- 2196
	if not __TS__NumberIsFinite(num) then -- 2196
		num = fallback -- 2197
	end -- 2197
	num = math.floor(num) -- 2198
	if num == 0 then -- 2198
		return {success = false, message = paramName .. " cannot be 0"} -- 2200
	end -- 2200
	return {success = true, value = num} -- 2202
end -- 2202
function validateDecision(tool, params) -- 2205
	if tool == "finish" then -- 2205
		local message = getFinishMessage(params) -- 2210
		if message == "" then -- 2210
			return {success = false, message = "finish requires params.message"} -- 2211
		end -- 2211
		params.message = message -- 2212
		local completion = getCompletionReport(params) -- 2213
		params.outcome = completion.outcome -- 2214
		params.validation = completion.validation -- 2215
		params.knownIssues = completion.knownIssues -- 2216
		params.assumptions = completion.assumptions -- 2217
		params.learningCandidates = completion.learningCandidates -- 2218
		return {success = true, params = params} -- 2219
	end -- 2219
	if tool == "ask_user" then -- 2219
		local normalized = normalizeQuestionnaire(params) -- 2223
		if not normalized.success then -- 2223
			return normalized -- 2224
		end -- 2224
		return {success = true, params = normalized.schema} -- 2225
	end -- 2225
	if tool == "read_file" then -- 2225
		local path = getDecisionPath(params) -- 2229
		if path == "" then -- 2229
			return {success = false, message = "read_file requires path"} -- 2230
		end -- 2230
		params.path = path -- 2231
		local startLineRes = parseReadLineParam(params.startLine, 1, "startLine") -- 2232
		if not startLineRes.success then -- 2232
			return startLineRes -- 2233
		end -- 2233
		local endLineDefault = startLineRes.value < 0 and -1 or AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 2234
		local endLineRes = parseReadLineParam(params.endLine, endLineDefault, "endLine") -- 2235
		if not endLineRes.success then -- 2235
			return endLineRes -- 2236
		end -- 2236
		params.startLine = startLineRes.value -- 2237
		params.endLine = endLineRes.value -- 2238
		return {success = true, params = params} -- 2239
	end -- 2239
	if tool == "edit_file" then -- 2239
		local path = getDecisionPath(params) -- 2243
		if path == "" then -- 2243
			return {success = false, message = "edit_file requires path"} -- 2244
		end -- 2244
		local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 2245
		local newStr = type(params.new_str) == "string" and params.new_str or "" -- 2246
		params.path = path -- 2247
		params.old_str = oldStr -- 2248
		params.new_str = newStr -- 2249
		return {success = true, params = params} -- 2250
	end -- 2250
	if tool == "delete_file" then -- 2250
		local targetFile = getDecisionPath(params) -- 2254
		if targetFile == "" then -- 2254
			return {success = false, message = "delete_file requires target_file"} -- 2255
		end -- 2255
		params.target_file = targetFile -- 2256
		return {success = true, params = params} -- 2257
	end -- 2257
	if tool == "grep_files" then -- 2257
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2261
		if pattern == "" then -- 2261
			return {success = false, message = "grep_files requires pattern"} -- 2262
		end -- 2262
		params.pattern = pattern -- 2263
		params.limit = clampIntegerParam(params.limit, AgentConfig.AGENT_LIMITS.searchFilesLimitDefault, 1) -- 2264
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2265
		return {success = true, params = params} -- 2266
	end -- 2266
	if tool == "search_dora_api" then -- 2266
		local pattern = type(params.pattern) == "string" and __TS__StringTrim(params.pattern) or "" -- 2270
		if pattern == "" then -- 2270
			return {success = false, message = "search_dora_api requires pattern"} -- 2271
		end -- 2271
		params.pattern = pattern -- 2272
		params.limit = clampIntegerParam(params.limit, 8, 1, AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax) -- 2273
		return {success = true, params = params} -- 2274
	end -- 2274
	if tool == "glob_files" then -- 2274
		params.maxEntries = clampIntegerParam(params.maxEntries, AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault, 1) -- 2278
		return {success = true, params = params} -- 2279
	end -- 2279
	if tool == "build" then -- 2279
		local path = getDecisionPath(params) -- 2283
		if path ~= "" then -- 2283
			params.path = path -- 2285
		end -- 2285
		return {success = true, params = params} -- 2287
	end -- 2287
	if tool == "list_sub_agents" then -- 2287
		local status = type(params.status) == "string" and __TS__StringTrim(params.status) or "" -- 2291
		if status ~= "" then -- 2291
			params.status = status -- 2293
		end -- 2293
		params.limit = clampIntegerParam(params.limit, 5, 1) -- 2295
		params.offset = clampIntegerParam(params.offset, 0, 0) -- 2296
		if type(params.query) == "string" then -- 2296
			params.query = __TS__StringTrim(params.query) -- 2298
		end -- 2298
		return {success = true, params = params} -- 2300
	end -- 2300
	if tool == "spawn_sub_agent" then -- 2300
		local prompt = type(params.prompt) == "string" and __TS__StringTrim(params.prompt) or "" -- 2304
		local title = type(params.title) == "string" and __TS__StringTrim(params.title) or "" -- 2305
		if prompt == "" then -- 2305
			return {success = false, message = "spawn_sub_agent requires prompt"} -- 2306
		end -- 2306
		if title == "" then -- 2306
			return {success = false, message = "spawn_sub_agent requires title"} -- 2307
		end -- 2307
		params.prompt = prompt -- 2308
		params.title = title -- 2309
		if type(params.expectedOutput) == "string" then -- 2309
			params.expectedOutput = __TS__StringTrim(params.expectedOutput) -- 2311
		end -- 2311
		if isArray(params.filesHint) then -- 2311
			params.filesHint = __TS__ArrayMap( -- 2314
				__TS__ArrayFilter( -- 2314
					params.filesHint, -- 2314
					function(____, item) return type(item) == "string" end -- 2315
				), -- 2315
				function(____, item) return sanitizeUTF8(item) end -- 2316
			) -- 2316
		end -- 2316
		return {success = true, params = params} -- 2318
	end -- 2318
	return {success = true, params = params} -- 2321
end -- 2321
function validateCompletionForRole(role, tool, params) -- 2324
	if role ~= "sub" or tool ~= "finish" then -- 2324
		return {success = true} -- 2329
	end -- 2329
	if params.outcome ~= "completed" and params.outcome ~= "partial" and params.outcome ~= "blocked" then -- 2329
		return {success = false, message = "sub-agent finish requires params.outcome"} -- 2331
	end -- 2331
	local requiredArrays = {"validation", "knownIssues", "assumptions", "learningCandidates"} -- 2333
	do -- 2333
		local i = 0 -- 2334
		while i < #requiredArrays do -- 2334
			local name = requiredArrays[i + 1] -- 2335
			if not isArray(params[name]) then -- 2335
				return {success = false, message = ("sub-agent finish requires params." .. name) .. " as an array"} -- 2337
			end -- 2337
			i = i + 1 -- 2334
		end -- 2334
	end -- 2334
	return {success = true} -- 2340
end -- 2340
function buildAgentSystemPrompt(shared, includeToolDefinitions) -- 2343
	if includeToolDefinitions == nil then -- 2343
		includeToolDefinitions = false -- 2343
	end -- 2343
	local rolePrompt = shared.workMode == "plan" and shared.promptPack.planAgentRolePrompt or (shared.role == "main" and shared.promptPack.mainAgentRolePrompt or shared.promptPack.subAgentRolePrompt) -- 2344
	local sections = { -- 2347
		shared.promptPack.agentIdentityPrompt, -- 2348
		rolePrompt, -- 2349
		getReplyLanguageDirective(shared) -- 2350
	} -- 2350
	if shared.role == "main" then -- 2350
		local planPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PLAN_FILE) -- 2353
		local progressPath = Path(shared.workingDir, AgentRuntimePolicy.AGENT_PROGRESS_FILE) -- 2354
		if Content:exist(planPath) and Content:exist(progressPath) then -- 2354
			sections[#sections + 1] = table.concat( -- 2356
				{ -- 2356
					"# Current Living Development Plan", -- 2357
					"These files were reloaded from disk for this decision. Treat them as authoritative over older conversation summaries.", -- 2358
					(("## " .. AgentRuntimePolicy.AGENT_PLAN_FILE) .. "\n\n") .. truncateText( -- 2358
						sanitizeUTF8(Content:load(planPath)), -- 2359
						12000 -- 2359
					), -- 2359
					(("## " .. AgentRuntimePolicy.AGENT_PROGRESS_FILE) .. "\n\n") .. truncateText( -- 2359
						sanitizeUTF8(Content:load(progressPath)), -- 2360
						12000 -- 2360
					) -- 2360
				}, -- 2360
				"\n\n" -- 2361
			) -- 2361
		end -- 2361
	end -- 2361
	if shared.decisionMode == "tool_calling" then -- 2361
		sections[#sections + 1] = shared.promptPack.functionCallingPrompt -- 2365
	end -- 2365
	local memoryBudget = shared.memory.compressor:getMemoryContextBudget() -- 2367
	local memoryContext = shared.memory.compressor:getStorage():getRelevantMemoryContext(shared.userQuery, memoryBudget) -- 2368
	if memoryContext ~= "" then -- 2368
		sections[#sections + 1] = memoryContext -- 2370
	end -- 2370
	local skillsSection = buildSkillsSection(shared) -- 2372
	if skillsSection ~= "" then -- 2372
		sections[#sections + 1] = skillsSection -- 2374
	end -- 2374
	if includeToolDefinitions then -- 2374
		sections[#sections + 1] = "### Available Tools\n\n" .. getDecisionToolDefinitions(shared) -- 2377
		if shared.decisionMode == "xml" then -- 2377
			sections[#sections + 1] = buildXmlDecisionInstruction(shared) -- 2379
		end -- 2379
	end -- 2379
	return table.concat(sections, "\n\n") -- 2382
end -- 2382
function buildSkillsSection(shared) -- 2385
	local ____opt_71 = shared.skills -- 2385
	if not (____opt_71 and ____opt_71.loader) then -- 2385
		return "" -- 2387
	end -- 2387
	return shared.skills.loader:buildSkillsPromptSection() -- 2389
end -- 2389
function isFinalDecisionTurn(shared) -- 2455
	return shared.step + 1 >= shared.maxSteps -- 2456
end -- 2456
function buildXmlDecisionInstruction(shared, feedback) -- 2536
	return shared.promptPack.xmlDecisionFormatPrompt .. (feedback or "") -- 2537
end -- 2537
function tryParseAndValidateDecision(rawText, shared) -- 2621
	local parsed = parseXMLToolCallObjectFromText(rawText) -- 2622
	if not parsed.success then -- 2622
		return {success = false, message = parsed.message, raw = rawText} -- 2624
	end -- 2624
	local decision = parseDecisionObject(parsed.obj) -- 2626
	if not decision.success then -- 2626
		return {success = false, message = decision.message, raw = rawText} -- 2628
	end -- 2628
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2630
	if not completionValidation.success then -- 2630
		return {success = false, message = completionValidation.message, raw = rawText} -- 2632
	end -- 2632
	local validation = validateDecision(decision.tool, decision.params) -- 2634
	if not validation.success then -- 2634
		return {success = false, message = validation.message, raw = rawText} -- 2636
	end -- 2636
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2638
	if not sharedValidation.success then -- 2638
		return {success = false, message = sharedValidation.message, raw = rawText} -- 2640
	end -- 2640
	decision.params = validation.params -- 2642
	decision.toolCallId = ensureToolCallId(decision.toolCallId) -- 2643
	return decision -- 2644
end -- 2644
function executeToolAction(shared, action) -- 3978
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3978
		if shared.stopToken.stopped then -- 3978
			return ____awaiter_resolve( -- 3978
				nil, -- 3978
				{ -- 3980
					success = false, -- 3980
					message = getCancelledReason(shared) -- 3980
				} -- 3980
			) -- 3980
		end -- 3980
		if shared.resumeRequiredTool ~= nil and action.tool == shared.resumeRequiredTool then -- 3980
			shared.resumeRequiredTool = nil -- 3983
			shared.resumeCheckpointPending = false -- 3984
		end -- 3984
		local params = action.params -- 3986
		local sharedValidation = validateDecisionForShared(shared, action.tool, params) -- 3987
		if not sharedValidation.success then -- 3987
			return ____awaiter_resolve(nil, sharedValidation) -- 3987
		end -- 3987
		if action.tool == "read_file" then -- 3987
			local ____params_startLine_146 = params.startLine -- 3990
			if ____params_startLine_146 == nil then -- 3990
				____params_startLine_146 = 1 -- 3990
			end -- 3990
			local startLine = __TS__Number(____params_startLine_146) -- 3990
			local ____params_endLine_147 = params.endLine -- 3991
			if ____params_endLine_147 == nil then -- 3991
				____params_endLine_147 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3991
			end -- 3991
			local endLine = __TS__Number(____params_endLine_147) -- 3991
			local clippedAfterCompression = false -- 3992
			if shared.resumeNarrowReadMode == true and startLine > 0 and endLine >= startLine and endLine - startLine + 1 > 160 then -- 3992
				endLine = startLine + 159 -- 3999
				clippedAfterCompression = true -- 4000
			end -- 4000
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4002
			if __TS__StringTrim(path) == "" then -- 4002
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4002
			end -- 4002
			local result = Tools.readFile( -- 4006
				shared.workingDir, -- 4007
				path, -- 4008
				startLine, -- 4009
				endLine, -- 4010
				shared.useChineseResponse and "zh" or "en" -- 4011
			) -- 4011
			if clippedAfterCompression and result.success == true then -- 4011
				result.clipped = true -- 4014
				result.message = shared.useChineseResponse and ((((("压缩恢复阶段已自动截取为第 " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " 行（最多 160 行）。如仍需后续内容，请从第 ") .. tostring(endLine + 1)) .. " 行继续窄读。" or ((((("The post-compression read was clipped to lines " .. tostring(startLine)) .. "-") .. tostring(endLine)) .. " (160 lines maximum). Continue narrowly from line ") .. tostring(endLine + 1)) .. " only if needed." -- 4015
			end -- 4015
			return ____awaiter_resolve(nil, result) -- 4015
		end -- 4015
		if action.tool ~= "build" then -- 4015
			shared.resumeNarrowReadMode = false -- 4025
		end -- 4025
		if action.tool == "grep_files" then -- 4025
			local searchPath = params.path or "" -- 4027
			local searchGlobs = params.globs -- 4028
			local ____Tools_searchFiles_161 = Tools.searchFiles -- 4029
			local ____shared_workingDir_154 = shared.workingDir -- 4030
			local ____temp_155 = params.pattern or "" -- 4032
			local ____params_globs_156 = params.globs -- 4033
			local ____params_useRegex_157 = params.useRegex -- 4034
			local ____params_caseSensitive_158 = params.caseSensitive -- 4035
			local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_159 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4037
			local ____math_max_150 = math.max -- 4038
			local ____math_floor_149 = math.floor -- 4038
			local ____params_limit_148 = params.limit -- 4038
			if ____params_limit_148 == nil then -- 4038
				____params_limit_148 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 4038
			end -- 4038
			local ____math_max_150_result_160 = ____math_max_150( -- 4038
				1, -- 4038
				____math_floor_149(__TS__Number(____params_limit_148)) -- 4038
			) -- 4038
			local ____math_max_153 = math.max -- 4039
			local ____math_floor_152 = math.floor -- 4039
			local ____params_offset_151 = params.offset -- 4039
			if ____params_offset_151 == nil then -- 4039
				____params_offset_151 = 0 -- 4039
			end -- 4039
			local result = __TS__Await(____Tools_searchFiles_161({ -- 4029
				workDir = ____shared_workingDir_154, -- 4030
				path = searchPath, -- 4031
				pattern = ____temp_155, -- 4032
				globs = ____params_globs_156, -- 4033
				useRegex = ____params_useRegex_157, -- 4034
				caseSensitive = ____params_caseSensitive_158, -- 4035
				includeContent = true, -- 4036
				contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_159, -- 4037
				limit = ____math_max_150_result_160, -- 4038
				offset = ____math_max_153( -- 4039
					0, -- 4039
					____math_floor_152(__TS__Number(____params_offset_151)) -- 4039
				), -- 4039
				groupByFile = params.groupByFile == true -- 4040
			})) -- 4040
			return ____awaiter_resolve(nil, result) -- 4040
		end -- 4040
		if action.tool == "search_dora_api" then -- 4040
			shared.apiSearchesSinceBuild = (shared.apiSearchesSinceBuild or 0) + 1 -- 4045
			local ____Tools_searchDoraAPI_170 = Tools.searchDoraAPI -- 4046
			local ____temp_166 = params.pattern or "" -- 4047
			local ____temp_167 = params.docSource or "api" -- 4048
			local ____temp_168 = shared.useChineseResponse and "zh" or "en" -- 4049
			local ____temp_169 = params.programmingLanguage or "ts" -- 4050
			local ____math_min_165 = math.min -- 4051
			local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_164 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 4051
			local ____math_max_163 = math.max -- 4051
			local ____params_limit_162 = params.limit -- 4051
			if ____params_limit_162 == nil then -- 4051
				____params_limit_162 = 8 -- 4051
			end -- 4051
			local result = __TS__Await(____Tools_searchDoraAPI_170({ -- 4046
				pattern = ____temp_166, -- 4047
				docSource = ____temp_167, -- 4048
				docLanguage = ____temp_168, -- 4049
				programmingLanguage = ____temp_169, -- 4050
				limit = ____math_min_165( -- 4051
					____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_164, -- 4051
					____math_max_163( -- 4051
						1, -- 4051
						__TS__Number(____params_limit_162) -- 4051
					) -- 4051
				), -- 4051
				useRegex = params.useRegex, -- 4052
				caseSensitive = false, -- 4053
				includeContent = true, -- 4054
				contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 4055
			})) -- 4055
			return ____awaiter_resolve(nil, result) -- 4055
		end -- 4055
		if action.tool == "glob_files" then -- 4055
			local ____Tools_listFiles_177 = Tools.listFiles -- 4060
			local ____shared_workingDir_174 = shared.workingDir -- 4061
			local ____temp_175 = params.path or "" -- 4062
			local ____params_globs_176 = params.globs -- 4063
			local ____math_max_173 = math.max -- 4064
			local ____math_floor_172 = math.floor -- 4064
			local ____params_maxEntries_171 = params.maxEntries -- 4064
			if ____params_maxEntries_171 == nil then -- 4064
				____params_maxEntries_171 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 4064
			end -- 4064
			local result = ____Tools_listFiles_177({ -- 4060
				workDir = ____shared_workingDir_174, -- 4061
				path = ____temp_175, -- 4062
				globs = ____params_globs_176, -- 4063
				maxEntries = ____math_max_173( -- 4064
					1, -- 4064
					____math_floor_172(__TS__Number(____params_maxEntries_171)) -- 4064
				) -- 4064
			}) -- 4064
			return ____awaiter_resolve(nil, result) -- 4064
		end -- 4064
		if action.tool == "ask_user" then -- 4064
			if not shared.publishQuestionnaire then -- 4064
				return ____awaiter_resolve(nil, {success = false, message = "ask_user is not available in this runtime"}) -- 4064
			end -- 4064
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4064
				return ____awaiter_resolve(nil, {success = false, message = "ask_user requires a session"}) -- 4064
			end -- 4064
			local normalized = normalizeQuestionnaire(params) -- 4071
			if not normalized.success then -- 4071
				return ____awaiter_resolve(nil, normalized) -- 4071
			end -- 4071
			local result = __TS__Await(shared.publishQuestionnaire({sessionId = shared.sessionId, taskId = shared.taskId, step = action.step, schema = normalized.schema})) -- 4073
			if not result.success then -- 4073
				return ____awaiter_resolve(nil, result) -- 4073
			end -- 4073
			shared.waitingQuestionnaireId = result.questionnaireId -- 4080
			return ____awaiter_resolve(nil, {success = true, waitingForUser = true, questionnaireId = result.questionnaireId}) -- 4080
		end -- 4080
		if action.tool == "delete_file" then -- 4080
			local targetFile = type(params.target_file) == "string" and params.target_file or (type(params.path) == "string" and params.path or "") -- 4084
			if __TS__StringTrim(targetFile) == "" then -- 4084
				return ____awaiter_resolve(nil, {success = false, message = "missing target_file"}) -- 4084
			end -- 4084
			local normalizedTargetFile = ____exports.normalizePolicyPath(targetFile) -- 4088
			local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4089
			if ____exports.isMainAgentMemoryPath(normalizedTargetFile) then -- 4089
				return ____awaiter_resolve(nil, {success = false, message = "This .agent/main file is managed automatically and cannot be deleted with delete_file."}) -- 4089
			end -- 4089
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedTargetFile) -- 4093
			local result = Tools.applyFileChanges(shared.taskId, shared.workingDir, {{path = targetFile, op = "delete"}}, {summary = "delete_file: " .. targetFile, toolName = "delete_file"}) -- 4094
			if not result.success then -- 4094
				return ____awaiter_resolve(nil, result) -- 4094
			end -- 4094
			if not isInternalDocumentEdit then -- 4094
				shared.unbuiltEdits = true -- 4102
				shared.lastBuildSucceeded = false -- 4103
				if shared.failedTestNeedsBuild == true then -- 4103
					shared.failedTestHasSourceEdit = true -- 4104
				end -- 4104
				if __TS__ArrayIndexOf(editedPaths, normalizedTargetFile) < 0 then -- 4104
					editedPaths[#editedPaths + 1] = normalizedTargetFile -- 4105
				end -- 4105
				shared.editedPathsSinceBuild = editedPaths -- 4106
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4107
			end -- 4107
			return ____awaiter_resolve(nil, { -- 4107
				success = true, -- 4110
				changed = true, -- 4111
				mode = "delete", -- 4112
				checkpointId = result.checkpointId, -- 4113
				checkpointSeq = result.checkpointSeq, -- 4114
				files = {{path = targetFile, op = "delete"}} -- 4115
			}) -- 4115
		end -- 4115
		if action.tool == "build" then -- 4115
			local buildPath = params.path or "" -- 4119
			local result = __TS__Await(Tools.build({workDir = shared.workingDir, path = buildPath})) -- 4120
			shared.unbuiltEdits = false -- 4124
			shared.editsSinceBuild = 0 -- 4125
			shared.editedPathsSinceBuild = {} -- 4126
			shared.hasBuilt = true -- 4127
			shared.lastBuildSucceeded = result.success -- 4128
			if result.success and shared.freshProjectBuildPending == true then -- 4128
				shared.freshProjectBuildPending = false -- 4134
			end -- 4134
			shared.apiSearchesSinceBuild = 0 -- 4136
			shared.buildRepairPending = false -- 4137
			if not result.success and result.messages ~= nil then -- 4137
				do -- 4137
					local i = 0 -- 4139
					while i < #result.messages do -- 4139
						if result.messages[i + 1].success == false and result.messages[i + 1].file ~= "" then -- 4139
							shared.buildRepairPending = true -- 4141
							break -- 4142
						end -- 4142
						i = i + 1 -- 4139
					end -- 4139
				end -- 4139
			end -- 4139
			if result.success and shared.failedTestNeedsBuild == true and shared.failedTestHasSourceEdit == true then -- 4139
				shared.failedTestNeedsBuild = false -- 4147
				shared.failedTestHasSourceEdit = false -- 4148
			end -- 4148
			return ____awaiter_resolve(nil, result) -- 4148
		end -- 4148
		if action.tool == "fetch_url" then -- 4148
			local result = __TS__Await(Tools.fetchUrl({ -- 4153
				workDir = shared.workingDir, -- 4154
				url = type(params.url) == "string" and params.url or "", -- 4155
				target = type(params.target) == "string" and params.target or "", -- 4156
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4157
				onProgress = function(____, progress) -- 4158
					emitAgentEvent( -- 4159
						shared, -- 4159
						{ -- 4159
							type = "tool_progress", -- 4160
							sessionId = shared.sessionId, -- 4161
							taskId = shared.taskId, -- 4162
							step = action.step, -- 4163
							tool = action.tool, -- 4164
							result = __TS__ObjectAssign({success = false}, progress) -- 4165
						} -- 4165
					) -- 4165
				end -- 4158
			})) -- 4158
			return ____awaiter_resolve(nil, result) -- 4158
		end -- 4158
		if action.tool == "execute_command" then -- 4158
			local mode = type(params.mode) == "string" and params.mode or "" -- 4175
			local result = __TS__Await(Tools.executeCommand({ -- 4176
				workDir = shared.workingDir, -- 4177
				mode = mode, -- 4178
				code = type(params.code) == "string" and params.code or nil, -- 4179
				command = type(params.command) == "string" and params.command or nil, -- 4180
				cwd = type(params.cwd) == "string" and params.cwd or nil, -- 4181
				timeoutSeconds = type(params.timeoutSeconds) == "number" and params.timeoutSeconds or nil, -- 4182
				isCancelled = function() return shared.stopToken.stopped == true end, -- 4183
				onProgress = function(____, progress) -- 4184
					emitAgentEvent( -- 4185
						shared, -- 4185
						{ -- 4185
							type = "tool_progress", -- 4186
							sessionId = shared.sessionId, -- 4187
							taskId = shared.taskId, -- 4188
							step = action.step, -- 4189
							tool = action.tool, -- 4190
							result = __TS__ObjectAssign({success = false}, progress) -- 4191
						} -- 4191
					) -- 4191
				end -- 4184
			})) -- 4184
			if result.success and mode == "lua" then -- 4184
				local deterministicFailure = false -- 4199
				local deterministicPass = false -- 4200
				local outputLines = __TS__StringSplit(result.output, "\n") -- 4201
				do -- 4201
					local i = 0 -- 4202
					while i < #outputLines and not deterministicFailure do -- 4202
						local line = string.lower(__TS__StringTrim(outputLines[i + 1])) -- 4203
						if line == "passed" then -- 4203
							deterministicPass = true -- 4204
						end -- 4204
						if line == "failed" then -- 4204
							deterministicFailure = true -- 4206
							break -- 4207
						end -- 4207
						local searchFrom = 0 -- 4209
						while searchFrom < #line do -- 4209
							local failedIndex = (string.find( -- 4211
								line, -- 4211
								"failed", -- 4211
								math.max(searchFrom + 1, 1), -- 4211
								true -- 4211
							) or 0) - 1 -- 4211
							if failedIndex < 0 then -- 4211
								break -- 4212
							end -- 4212
							local after = failedIndex + #"failed" -- 4213
							while after < #line do -- 4213
								local ch = __TS__StringSlice(line, after, after + 1) -- 4215
								if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4215
									break -- 4216
								end -- 4216
								after = after + 1 -- 4217
							end -- 4217
							local afterEnd = after -- 4219
							while afterEnd < #line do -- 4219
								local ch = __TS__StringSlice(line, afterEnd, afterEnd + 1) -- 4221
								if ch < "0" or ch > "9" then -- 4221
									break -- 4222
								end -- 4222
								afterEnd = afterEnd + 1 -- 4223
							end -- 4223
							local count -- 4225
							if afterEnd > after then -- 4225
								count = __TS__Number(__TS__StringSlice(line, after, afterEnd)) -- 4227
							else -- 4227
								local before = failedIndex - 1 -- 4229
								while before >= 0 do -- 4229
									local ch = __TS__StringSlice(line, before, before + 1) -- 4231
									if ch ~= " " and ch ~= "\t" and ch ~= ":" and ch ~= "=" then -- 4231
										break -- 4232
									end -- 4232
									before = before - 1 -- 4233
								end -- 4233
								local beforeEnd = before + 1 -- 4235
								while before >= 0 do -- 4235
									local ch = __TS__StringSlice(line, before, before + 1) -- 4237
									if ch < "0" or ch > "9" then -- 4237
										break -- 4238
									end -- 4238
									before = before - 1 -- 4239
								end -- 4239
								if beforeEnd > before + 1 then -- 4239
									count = __TS__Number(__TS__StringSlice(line, before + 1, beforeEnd)) -- 4241
								end -- 4241
							end -- 4241
							if count ~= nil and count > 0 or count == nil and failedIndex == 0 then -- 4241
								deterministicFailure = true -- 4244
								break -- 4245
							end -- 4245
							searchFrom = failedIndex + #"failed" -- 4247
						end -- 4247
						i = i + 1 -- 4202
					end -- 4202
				end -- 4202
				if deterministicFailure then -- 4202
					shared.failedTestNeedsBuild = true -- 4251
					shared.failedTestHasSourceEdit = false -- 4252
					shared.deterministicTestFailureCount = (shared.deterministicTestFailureCount or 0) + 1 -- 4253
				elseif deterministicPass then -- 4253
					shared.deterministicTestFailureCount = 0 -- 4255
				end -- 4255
			end -- 4255
			return ____awaiter_resolve(nil, result) -- 4255
		end -- 4255
		if action.tool == "spawn_sub_agent" then -- 4255
			if not shared.spawnSubAgent then -- 4255
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 4255
			end -- 4255
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4255
				return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 4255
			end -- 4255
			local filesHint = isArray(params.filesHint) and __TS__ArrayFilter( -- 4267
				params.filesHint, -- 4268
				function(____, item) return type(item) == "string" end -- 4268
			) or nil -- 4268
			local result = __TS__Await(shared.spawnSubAgent({ -- 4270
				parentSessionId = shared.sessionId, -- 4271
				projectRoot = shared.workingDir, -- 4272
				title = type(params.title) == "string" and params.title or "Sub", -- 4273
				prompt = type(params.prompt) == "string" and params.prompt or "", -- 4274
				expectedOutput = type(params.expectedOutput) == "string" and params.expectedOutput or nil, -- 4275
				filesHint = filesHint, -- 4276
				disabledAgentTools = shared.disabledAgentTools -- 4277
			})) -- 4277
			if not result.success then -- 4277
				return ____awaiter_resolve(nil, result) -- 4277
			end -- 4277
			shared.hasSpawnedSubAgentThisTask = true -- 4282
			return ____awaiter_resolve(nil, { -- 4282
				success = true, -- 4284
				sessionId = result.sessionId, -- 4285
				taskId = result.taskId, -- 4286
				title = result.title, -- 4287
				hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 4288
			}) -- 4288
		end -- 4288
		if action.tool == "list_sub_agents" then -- 4288
			if not shared.listSubAgents then -- 4288
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 4288
			end -- 4288
			if shared.sessionId == nil or shared.sessionId <= 0 then -- 4288
				return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 4288
			end -- 4288
			local result = __TS__Await(shared.listSubAgents({ -- 4298
				sessionId = shared.sessionId, -- 4299
				projectRoot = shared.workingDir, -- 4300
				status = type(params.status) == "string" and params.status or nil, -- 4301
				limit = type(params.limit) == "number" and params.limit or nil, -- 4302
				offset = type(params.offset) == "number" and params.offset or nil, -- 4303
				query = type(params.query) == "string" and params.query or nil -- 4304
			})) -- 4304
			return ____awaiter_resolve(nil, result) -- 4304
		end -- 4304
		if action.tool == "edit_file" then -- 4304
			local path = type(params.path) == "string" and params.path or (type(params.target_file) == "string" and params.target_file or "") -- 4309
			local oldStr = type(params.old_str) == "string" and params.old_str or "" -- 4312
			local newStr = type(params.new_str) == "string" and params.new_str or "" -- 4313
			if __TS__StringTrim(path) == "" then -- 4313
				return ____awaiter_resolve(nil, {success = false, message = "missing path"}) -- 4313
			end -- 4313
			local normalizedPath = ____exports.normalizePolicyPath(path) -- 4315
			local isInternalDocumentEdit = AgentRuntimePolicy.isAgentInternalDocumentPath(normalizedPath) -- 4316
			if not isInternalDocumentEdit then -- 4316
				local preflightIssue = AgentToolRegistry.findUnsupportedDoraTsEdit(normalizedPath, newStr) -- 4318
				if preflightIssue ~= nil then -- 4318
					local targetExists = Content:exist(Path(shared.workingDir, normalizedPath)) -- 4320
					local recovery = oldStr == "" and not targetExists and " This was a rejected new-file create, so the file does not exist. Reissue the complete file content with the unsupported construct replaced; do not attempt a partial patch." or " Reissue the corrected coherent replacement; do not patch text that was never written." -- 4321
					return ____awaiter_resolve(nil, {success = false, message = preflightIssue .. recovery}) -- 4321
				end -- 4321
			end -- 4321
			local actionNode = __TS__New(EditFileAction, 1, 0) -- 4327
			local result = __TS__Await(actionNode:exec({ -- 4328
				path = path, -- 4329
				oldStr = oldStr, -- 4330
				newStr = newStr, -- 4331
				taskId = shared.taskId, -- 4332
				workDir = shared.workingDir -- 4333
			})) -- 4333
			if not isInternalDocumentEdit and result.success == true and result.changed ~= false then -- 4333
				if params.partialStreamRecovery ~= true then -- 4333
					shared.truncatedToolOverwritePath = nil -- 4337
				end -- 4337
				shared.unbuiltEdits = true -- 4339
				shared.lastBuildSucceeded = false -- 4340
				if shared.failedTestNeedsBuild == true then -- 4340
					shared.failedTestHasSourceEdit = true -- 4341
				end -- 4341
				local editedPaths = shared.editedPathsSinceBuild or ({}) -- 4342
				if __TS__ArrayIndexOf(editedPaths, normalizedPath) < 0 then -- 4342
					editedPaths[#editedPaths + 1] = normalizedPath -- 4343
				end -- 4343
				shared.editedPathsSinceBuild = editedPaths -- 4344
				shared.editsSinceBuild = (shared.editsSinceBuild or 0) + 1 -- 4345
			end -- 4345
			return ____awaiter_resolve(nil, result) -- 4345
		end -- 4345
		return ____awaiter_resolve(nil, {success = false, message = action.tool .. " cannot be executed as a batched tool"}) -- 4345
	end) -- 4345
end -- 4345
function sanitizeToolActionResultForHistory(action, result) -- 4352
	if action.tool == "read_file" then -- 4352
		return sanitizeReadResultForHistory(action.tool, result) -- 4354
	end -- 4354
	if action.tool == "grep_files" or action.tool == "search_dora_api" then -- 4354
		return sanitizeSearchResultForHistory(action.tool, result) -- 4357
	end -- 4357
	if action.tool == "glob_files" then -- 4357
		return sanitizeListFilesResultForHistory(result) -- 4360
	end -- 4360
	if action.tool == "build" then -- 4360
		return sanitizeBuildResultForHistory(result) -- 4363
	end -- 4363
	if action.tool == "edit_file" or action.tool == "delete_file" then -- 4363
		if result.success ~= true then -- 4363
			return result -- 4366
		end -- 4366
		if type(result.checkpointId) ~= "number" or type(result.checkpointSeq) ~= "number" then -- 4366
			return result -- 4367
		end -- 4367
		if isArray(result.fileContext) then -- 4367
			return result -- 4368
		end -- 4368
		local contextLimits = { -- 4370
			fullContentChars = 12000, -- 4371
			previewChars = 4000, -- 4372
			diffChars = 8000, -- 4373
			totalChars = 24000, -- 4374
			maxFiles = 8 -- 4375
		} -- 4375
		local function truncateContextSnippet(sourceText, maxChars, label) -- 4377
			if maxChars <= 0 then -- 4377
				return ((("..." .. label) .. " omitted (") .. tostring(#sourceText)) .. " chars total)..." -- 4378
			end -- 4378
			if #sourceText <= maxChars then -- 4378
				return sourceText -- 4379
			end -- 4379
			local nextUtf8Offset = utf8.offset(sourceText, maxChars + 1) -- 4380
			local visiblePrefix = nextUtf8Offset == nil and sourceText or string.sub(sourceText, 1, nextUtf8Offset - 1) -- 4381
			return ((((visiblePrefix .. "\n...") .. label) .. " truncated (") .. tostring(#sourceText)) .. " chars total)..." -- 4382
		end -- 4377
		local function countLines(sourceText) -- 4384
			if sourceText == "" then -- 4384
				return 0 -- 4385
			end -- 4385
			return #__TS__StringSplit(sourceText, "\n") -- 4386
		end -- 4384
		local function buildUnifiedDiffPreview(filePath, beforeContent, afterContent, maxChars) -- 4388
			if beforeContent == afterContent then -- 4388
				return "" -- 4389
			end -- 4389
			local beforeLines = __TS__StringSplit(beforeContent, "\n") -- 4390
			local afterLines = __TS__StringSplit(afterContent, "\n") -- 4391
			local unifiedDiffLines = {"--- " .. filePath, "+++ " .. filePath}
			local firstChangedLine = 0 -- 4393
			while firstChangedLine < #beforeLines and firstChangedLine < #afterLines and beforeLines[firstChangedLine + 1] == afterLines[firstChangedLine + 1] do -- 4393
				firstChangedLine = firstChangedLine + 1 -- 4399
			end -- 4399
			local lastChangedBeforeLine = #beforeLines - 1 -- 4401
			local lastChangedAfterLine = #afterLines - 1 -- 4402
			while lastChangedBeforeLine >= firstChangedLine and lastChangedAfterLine >= firstChangedLine and beforeLines[lastChangedBeforeLine + 1] == afterLines[lastChangedAfterLine + 1] do -- 4402
				lastChangedBeforeLine = lastChangedBeforeLine - 1 -- 4408
				lastChangedAfterLine = lastChangedAfterLine - 1 -- 4409
			end -- 4409
			local previewStartLine = math.max(0, firstChangedLine - 3) -- 4411
			local previewEndLine = math.max( -- 4412
				math.min(#beforeLines - 1, lastChangedBeforeLine + 3), -- 4413
				math.min(#afterLines - 1, lastChangedAfterLine + 3) -- 4414
			) -- 4414
			unifiedDiffLines[#unifiedDiffLines + 1] = ("@@ " .. tostring(previewStartLine + 1)) .. " @@" -- 4416
			do -- 4416
				local lineIndex = previewStartLine -- 4417
				while lineIndex <= previewEndLine do -- 4417
					do -- 4417
						local beforeLine = lineIndex < #beforeLines and beforeLines[lineIndex + 1] or nil -- 4418
						local afterLine = lineIndex < #afterLines and afterLines[lineIndex + 1] or nil -- 4419
						local beforeChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedBeforeLine -- 4420
						local afterChanged = lineIndex >= firstChangedLine and lineIndex <= lastChangedAfterLine -- 4421
						if not beforeChanged and not afterChanged then -- 4421
							local contextLine = afterLine ~= nil and afterLine or beforeLine -- 4423
							if contextLine ~= nil then -- 4423
								unifiedDiffLines[#unifiedDiffLines + 1] = " " .. contextLine -- 4424
							end -- 4424
							goto __continue726 -- 4425
						end -- 4425
						if beforeChanged and beforeLine ~= nil then -- 4425
							unifiedDiffLines[#unifiedDiffLines + 1] = "-" .. beforeLine -- 4427
						end -- 4427
						if afterChanged and afterLine ~= nil then -- 4427
							unifiedDiffLines[#unifiedDiffLines + 1] = "+" .. afterLine -- 4428
						end -- 4428
					end -- 4428
					::__continue726:: -- 4428
					lineIndex = lineIndex + 1 -- 4417
				end -- 4417
			end -- 4417
			return truncateContextSnippet( -- 4430
				table.concat(unifiedDiffLines, "\n"), -- 4430
				maxChars, -- 4430
				"diff" -- 4430
			) -- 4430
		end -- 4388
		local checkpointDiff = Tools.getCheckpointDiff(result.checkpointId) -- 4433
		if not checkpointDiff.success then -- 4433
			return result -- 4434
		end -- 4434
		local remainingContextBudget = contextLimits.totalChars -- 4435
		local fileContextItems = {} -- 4436
		local changedFiles = checkpointDiff.files -- 4437
		local maxContextFiles = math.min(#changedFiles, contextLimits.maxFiles) -- 4438
		do -- 4438
			local fileIndex = 0 -- 4439
			while fileIndex < maxContextFiles do -- 4439
				if remainingContextBudget <= 0 then -- 4439
					break -- 4440
				end -- 4440
				local changedFile = changedFiles[fileIndex + 1] -- 4441
				local beforeContent = changedFile.beforeExists and changedFile.beforeContent or "" -- 4442
				local afterContent = changedFile.afterExists and changedFile.afterContent or "" -- 4443
				local contextItem = { -- 4444
					path = changedFile.path, -- 4445
					op = changedFile.op, -- 4446
					checkpointId = result.checkpointId, -- 4447
					checkpointSeq = result.checkpointSeq, -- 4448
					beforeExists = changedFile.beforeExists, -- 4449
					afterExists = changedFile.afterExists, -- 4450
					beforeBytes = #beforeContent, -- 4451
					afterBytes = #afterContent, -- 4452
					diffPreview = "", -- 4453
					lineCount = changedFile.afterExists and countLines(afterContent) or 0, -- 4454
					contentTruncated = false, -- 4455
					fileListTruncated = #changedFiles > contextLimits.maxFiles -- 4456
				} -- 4456
				if changedFile.afterExists then -- 4456
					if #afterContent <= contextLimits.fullContentChars and #afterContent <= remainingContextBudget then -- 4456
						contextItem.afterContent = afterContent -- 4460
						remainingContextBudget = remainingContextBudget - #afterContent -- 4461
					else -- 4461
						contextItem.afterContentPreview = truncateContextSnippet( -- 4463
							afterContent, -- 4464
							math.min( -- 4465
								contextLimits.previewChars, -- 4465
								math.max(400, remainingContextBudget) -- 4465
							), -- 4465
							"afterContent" -- 4466
						) -- 4466
						remainingContextBudget = remainingContextBudget - #contextItem.afterContentPreview -- 4468
						contextItem.contentTruncated = true -- 4469
					end -- 4469
				end -- 4469
				local diffPreview = buildUnifiedDiffPreview( -- 4472
					changedFile.path, -- 4473
					beforeContent, -- 4474
					afterContent, -- 4475
					math.min( -- 4476
						contextLimits.diffChars, -- 4476
						math.max(400, remainingContextBudget) -- 4476
					) -- 4476
				) -- 4476
				contextItem.diffPreview = diffPreview -- 4478
				remainingContextBudget = remainingContextBudget - #diffPreview -- 4479
				if not changedFile.afterExists and beforeContent ~= "" then -- 4479
					contextItem.beforeContentPreview = truncateContextSnippet( -- 4481
						beforeContent, -- 4482
						math.min( -- 4483
							contextLimits.previewChars, -- 4483
							math.max(400, remainingContextBudget) -- 4483
						), -- 4483
						"beforeContent" -- 4484
					) -- 4484
					remainingContextBudget = remainingContextBudget - #contextItem.beforeContentPreview -- 4486
					if #beforeContent > contextLimits.previewChars then -- 4486
						contextItem.contentTruncated = true -- 4487
					end -- 4487
				end -- 4487
				fileContextItems[#fileContextItems + 1] = contextItem -- 4489
				fileIndex = fileIndex + 1 -- 4439
			end -- 4439
		end -- 4439
		if #fileContextItems == 0 then -- 4439
			return result -- 4491
		end -- 4491
		return __TS__ObjectAssign({}, result, {fileContext = fileContextItems}, #changedFiles > maxContextFiles and ({truncatedFileContextItems = #changedFiles - maxContextFiles}) or ({})) -- 4492
	end -- 4492
	return result -- 4499
end -- 4499
function emitAgentTaskFinishEvent(shared, success, message) -- 4696
	local completion = shared.completion or ____exports.normalizeAgentCompletionReport({outcome = success and "completed" or "blocked", knownIssues = success and ({}) or ({message})}) -- 4697
	local result = success and ({ -- 4701
		success = true, -- 4703
		taskId = shared.taskId, -- 4704
		message = message, -- 4705
		steps = shared.step, -- 4706
		completion = completion -- 4707
	}) or ({ -- 4707
		success = false, -- 4710
		taskId = shared.taskId, -- 4711
		message = message, -- 4712
		steps = shared.step, -- 4713
		completion = completion -- 4714
	}) -- 4714
	emitAgentEvent(shared, { -- 4716
		type = "task_finished", -- 4717
		sessionId = shared.sessionId, -- 4718
		taskId = shared.taskId, -- 4719
		success = result.success, -- 4720
		message = result.message, -- 4721
		steps = result.steps, -- 4722
		completion = result.completion -- 4723
	}) -- 4723
	return result -- 4725
end -- 4725
local function buildLLMOptions(llmConfig, overrides) -- 304
	local options = {temperature = llmConfig.temperature or AgentConfig.AGENT_DEFAULTS.llmTemperature, max_tokens = llmConfig.maxTokens or AgentConfig.AGENT_DEFAULTS.llmMaxTokens} -- 305
	if llmConfig.reasoningEffort then -- 305
		options.reasoning_effort = llmConfig.reasoningEffort -- 310
	end -- 310
	local merged = __TS__ObjectAssign({}, options, overrides or ({})) -- 312
	if type(merged.reasoning_effort) ~= "string" or __TS__StringTrim(merged.reasoning_effort) == "" then -- 312
		__TS__Delete(merged, "reasoning_effort") -- 317
	else -- 317
		merged.reasoning_effort = __TS__StringTrim(merged.reasoning_effort) -- 319
	end -- 319
	__TS__Delete(merged, "tool_choice") -- 324
	return merged -- 325
end -- 304
local function emitLLMContextMetrics(shared, step, phase, messages, options) -- 455
	local messagesTokens = 0 -- 462
	do -- 462
		local i = 0 -- 463
		while i < #messages do -- 463
			local message = messages[i + 1] -- 464
			messagesTokens = messagesTokens + 8 -- 465
			messagesTokens = messagesTokens + estimateTextTokens(message.role or "") -- 466
			messagesTokens = messagesTokens + estimateTextTokens(message.content or "") -- 467
			messagesTokens = messagesTokens + estimateTextTokens(message.name or "") -- 468
			messagesTokens = messagesTokens + estimateTextTokens(message.tool_call_id or "") -- 469
			messagesTokens = messagesTokens + estimateTextTokens(message.reasoning_content or "") -- 470
			local toolCallsText = safeJsonEncode(message.tool_calls or ({})) -- 471
			messagesTokens = messagesTokens + estimateTextTokens(toolCallsText or "") -- 472
			i = i + 1 -- 463
		end -- 463
	end -- 463
	local toolDefinitionsTokens = 0 -- 475
	if options.tools and __TS__ArrayIsArray(options.tools) then -- 475
		local toolsText = safeJsonEncode(options.tools) -- 477
		toolDefinitionsTokens = toolsText and estimateTextTokens(toolsText) or 0 -- 478
	end -- 478
	local optionsWithoutTools = __TS__ObjectAssign({}, options) -- 481
	__TS__Delete(optionsWithoutTools, "tools") -- 482
	local optionsText = safeJsonEncode(optionsWithoutTools) -- 483
	local optionsTokens = optionsText and estimateTextTokens(optionsText) or 0 -- 484
	local contextWindow = shared.llmConfig.contextWindow > 0 and math.floor(shared.llmConfig.contextWindow) or 64000 -- 485
	local explicitMax = type(options.max_tokens) == "number" and math.floor(options.max_tokens) or (type(options.max_completion_tokens) == "number" and math.floor(options.max_completion_tokens) or 0) -- 488
	local reservedOutputTokens = explicitMax > 0 and math.max(256, explicitMax) or math.max( -- 493
		1024, -- 495
		math.floor(contextWindow * 0.2) -- 495
	) -- 495
	local structuralOverhead = math.max(256, #messages * 16) -- 496
	local usedTokens = messagesTokens + optionsTokens + structuralOverhead -- 498
	local maxTokens = contextWindow -- 499
	emitAgentEvent( -- 500
		shared, -- 500
		{ -- 500
			type = "metrics_updated", -- 501
			sessionId = shared.sessionId, -- 502
			taskId = shared.taskId, -- 503
			step = step, -- 504
			metrics = {context = { -- 505
				usedTokens = usedTokens, -- 507
				maxTokens = maxTokens, -- 508
				ratio = math.max( -- 509
					0, -- 509
					math.min(1, usedTokens / maxTokens) -- 509
				), -- 509
				messagesTokens = messagesTokens, -- 510
				optionsTokens = optionsTokens, -- 511
				toolDefinitionsTokens = toolDefinitionsTokens, -- 512
				reservedOutputTokens = reservedOutputTokens, -- 513
				structuralOverhead = structuralOverhead, -- 514
				contextWindow = contextWindow, -- 515
				source = "llm_input_estimate", -- 516
				updatedAt = os.time(), -- 517
				phase = phase, -- 518
				step = step -- 519
			}} -- 519
		} -- 519
	) -- 519
end -- 455
local function recordLLMTokenUsage(shared, step, phase, usage) -- 525
	if not usage then -- 525
		return -- 526
	end -- 526
	local current = shared.tokenUsage -- 527
	local cachedReported = usage.cachedInputTokens ~= nil -- 528
	local cacheMissReported = usage.cacheMissInputTokens ~= nil -- 529
	local reasoningReported = usage.reasoningOutputTokens ~= nil -- 530
	local next = { -- 531
		inputTokens = (current and current.inputTokens or 0) + usage.inputTokens, -- 532
		outputTokens = (current and current.outputTokens or 0) + usage.outputTokens, -- 533
		totalTokens = (current and current.totalTokens or 0) + (usage.totalTokens or usage.inputTokens + usage.outputTokens), -- 534
		cachedInputTokens = (cachedReported or (current and current.cachedInputTokens) ~= nil) and (current and current.cachedInputTokens or 0) + (usage.cachedInputTokens or 0) or nil, -- 535
		cacheMissInputTokens = (cacheMissReported or (current and current.cacheMissInputTokens) ~= nil) and (current and current.cacheMissInputTokens or 0) + (usage.cacheMissInputTokens or 0) or nil, -- 538
		reasoningOutputTokens = (reasoningReported or (current and current.reasoningOutputTokens) ~= nil) and (current and current.reasoningOutputTokens or 0) + (usage.reasoningOutputTokens or 0) or nil, -- 541
		requestCount = (current and current.requestCount or 0) + 1, -- 544
		cacheReportedRequestCount = (cachedReported or (current and current.cacheReportedRequestCount) ~= nil) and (current and current.cacheReportedRequestCount or 0) + (cachedReported and 1 or 0) or nil, -- 545
		model = shared.llmConfig.model, -- 548
		phase = phase, -- 549
		step = step, -- 550
		updatedAt = os.time() -- 551
	} -- 551
	shared.tokenUsage = next -- 553
	emitAgentEvent(shared, { -- 554
		type = "metrics_updated", -- 555
		sessionId = shared.sessionId, -- 556
		taskId = shared.taskId, -- 557
		step = step, -- 558
		metrics = {usage = next} -- 559
	}) -- 559
end -- 525
local function emitAgentStartEvent(shared, action) -- 563
	emitAgentEvent(shared, { -- 564
		type = "tool_started", -- 565
		sessionId = shared.sessionId, -- 566
		taskId = shared.taskId, -- 567
		step = action.step, -- 568
		tool = action.tool -- 569
	}) -- 569
end -- 563
local function emitAgentFinishEvent(shared, action) -- 573
	emitAgentEvent(shared, { -- 574
		type = "tool_finished", -- 575
		sessionId = shared.sessionId, -- 576
		taskId = shared.taskId, -- 577
		step = action.step, -- 578
		tool = action.tool, -- 579
		result = action.result or ({}) -- 580
	}) -- 580
end -- 573
local function emitAssistantMessageUpdated(shared, content, reasoningContent) -- 584
	emitAgentEvent(shared, { -- 585
		type = "assistant_message_updated", -- 586
		sessionId = shared.sessionId, -- 587
		taskId = shared.taskId, -- 588
		step = shared.step + 1, -- 589
		content = content, -- 590
		reasoningContent = reasoningContent -- 591
	}) -- 591
end -- 584
local function getMemoryCompressionStartReason(shared) -- 595
	return shared.useChineseResponse and "开始进行上下文记忆压缩。" or "Starting context memory compression." -- 596
end -- 595
local function getMemoryCompressionSuccessReason(shared, compressedCount) -- 601
	return shared.useChineseResponse and ("记忆压缩完成，已整理 " .. tostring(compressedCount)) .. " 条历史消息。" or ("Memory compression finished after consolidating " .. tostring(compressedCount)) .. " historical messages." -- 602
end -- 601
local function getMemoryCompressionFailureReason(shared, ____error) -- 607
	return shared.useChineseResponse and "记忆压缩失败：" .. ____error or "Memory compression failed: " .. ____error -- 608
end -- 607
local function summarizeHistoryEntryPreview(text, maxChars) -- 613
	if maxChars == nil then -- 613
		maxChars = 180 -- 613
	end -- 613
	local trimmed = __TS__StringTrim(text) -- 614
	if trimmed == "" then -- 614
		return "" -- 615
	end -- 615
	return truncateText(trimmed, maxChars) -- 616
end -- 613
local function getMaxStepsReachedReason(shared) -- 624
	return shared.useChineseResponse and ("已达到最大执行步数限制（" .. tostring(shared.maxSteps)) .. " 步）。如需继续后续处理，请发送“继续”。" or ("Maximum step limit reached (" .. tostring(shared.maxSteps)) .. " steps). Send \"continue\" if you want to proceed with the remaining work." -- 625
end -- 624
local function getFailureSummaryFallback(shared, ____error) -- 630
	return shared.useChineseResponse and "任务因以下问题结束：" .. ____error or "The task ended due to the following issue: " .. ____error -- 631
end -- 630
local function finalizeAgentFailure(shared, ____error) -- 636
	if shared.stopToken.stopped then -- 636
		Tools.setTaskStatus(shared.taskId, "STOPPED") -- 638
		return emitAgentTaskFinishEvent( -- 639
			shared, -- 639
			false, -- 639
			getCancelledReason(shared) -- 639
		) -- 639
	end -- 639
	Tools.setTaskStatus(shared.taskId, "FAILED") -- 641
	return emitAgentTaskFinishEvent(shared, false, ____error) -- 642
end -- 636
local function getPromptCommand(prompt) -- 645
	local trimmed = __TS__StringTrim(prompt) -- 646
	if trimmed == "/compact" then -- 646
		return "compact" -- 647
	end -- 647
	if trimmed == "/clear" then -- 647
		return "clear" -- 648
	end -- 648
	return nil -- 649
end -- 645
function ____exports.truncateAgentUserPrompt(prompt) -- 652
	if not prompt then -- 652
		return "" -- 653
	end -- 653
	if #prompt <= AgentConfig.AGENT_LIMITS.userPromptMaxChars then -- 653
		return prompt -- 654
	end -- 654
	local offset = utf8.offset(prompt, AgentConfig.AGENT_LIMITS.userPromptMaxChars + 1) -- 655
	if offset == nil then -- 655
		return prompt -- 656
	end -- 656
	return string.sub(prompt, 1, offset - 1) -- 657
end -- 652
local function canWriteStepLLMDebug(shared, stepId) -- 660
	if stepId == nil then -- 660
		stepId = shared.step + 1 -- 660
	end -- 660
	return App.debugging == true and shared.sessionId ~= nil and shared.sessionId > 0 and shared.taskId > 0 and stepId > 0 -- 661
end -- 660
local function ensureDirRecursive(dir) -- 668
	if not dir then -- 668
		return false -- 669
	end -- 669
	if Content:exist(dir) then -- 669
		return Content:isdir(dir) -- 670
	end -- 670
	local parent = Path:getPath(dir) -- 671
	if parent ~= "" and parent ~= dir and not Content:exist(parent) and not ensureDirRecursive(parent) then -- 671
		return false -- 673
	end -- 673
	return Content:mkdir(dir) -- 675
end -- 668
local function encodeDebugJSON(value) -- 678
	local text, err = safeJsonEncode(value) -- 679
	return text or ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 680
end -- 678
function ____exports.isAgentPlanPath(path) -- 696
	return AgentRuntimePolicy.isAgentPlanPath(path) -- 697
end -- 696
local FRESH_PROJECT_CODE_GLOBS = { -- 700
	"**/*.ts", -- 701
	"**/*.tsx", -- 702
	"**/*.lua", -- 703
	"**/*.yue", -- 704
	"**/*.tl", -- 705
	"**/*.yarn", -- 706
	"**/*.xml", -- 707
	"!**/*.d.ts" -- 708
} -- 708
local function inspectFreshProject(workDir) -- 711
	local result = Tools.listFiles({workDir = workDir, path = "", globs = FRESH_PROJECT_CODE_GLOBS, maxEntries = 2}) -- 712
	if not result.success then -- 712
		return {fresh = false} -- 718
	end -- 718
	local totalEntries = result.totalEntries or #result.files -- 719
	if totalEntries > 1 then -- 719
		return {fresh = false} -- 720
	end -- 720
	if totalEntries == 0 then -- 720
		return {fresh = true} -- 721
	end -- 721
	if #result.files ~= 1 then -- 721
		return {fresh = false} -- 722
	end -- 722
	local path = result.files[1] -- 723
	local loaded = Tools.readFileRaw(workDir, path) -- 724
	if not loaded.success or loaded.content == nil then -- 724
		return {fresh = false} -- 725
	end -- 725
	local content = __TS__StringEndsWith(loaded.content, "\n") and string.sub(loaded.content, 1, -2) or loaded.content -- 726
	local lineCount = content == "" and 0 or #__TS__StringSplit(content, "\n") -- 729
	return lineCount <= 3 and ({fresh = true, codeFile = path}) or ({fresh = false}) -- 730
end -- 711
local function getStepLLMDebugDir(shared) -- 733
	return Path( -- 734
		shared.workingDir, -- 735
		".agent", -- 736
		tostring(shared.sessionId), -- 737
		tostring(shared.taskId) -- 738
	) -- 738
end -- 733
local function getStepLLMDebugPath(shared, stepId, seq, kind) -- 742
	return Path( -- 743
		getStepLLMDebugDir(shared), -- 743
		((((tostring(stepId) .. "_") .. tostring(seq)) .. "_") .. kind) .. ".md" -- 743
	) -- 743
end -- 742
local function getLatestStepLLMDebugSeq(shared, stepId) -- 746
	if not canWriteStepLLMDebug(shared, stepId) then -- 746
		return 0 -- 747
	end -- 747
	local dir = getStepLLMDebugDir(shared) -- 748
	if not Content:exist(dir) or not Content:isdir(dir) then -- 748
		return 0 -- 749
	end -- 749
	local latest = 0 -- 750
	for ____, file in ipairs(Content:getFiles(dir)) do -- 751
		do -- 751
			local name = Path:getFilename(file) -- 752
			local seqText = string.match( -- 753
				name, -- 753
				("^" .. tostring(stepId)) .. "_(%d+)_in%.md$" -- 753
			) -- 753
			if seqText ~= nil then -- 753
				latest = math.max( -- 755
					latest, -- 755
					tonumber(seqText) -- 755
				) -- 755
				goto __continue59 -- 756
			end -- 756
			local legacyMatch = string.match( -- 758
				name, -- 758
				("^" .. tostring(stepId)) .. "_in%.md$" -- 758
			) -- 758
			if legacyMatch ~= nil then -- 758
				latest = math.max(latest, 1) -- 760
			end -- 760
		end -- 760
		::__continue59:: -- 760
	end -- 760
	return latest -- 763
end -- 746
local function writeStepLLMDebugFile(path, content) -- 766
	if not Content:save(path, content) then -- 766
		Log("Warn", "[CodingAgent] failed to save LLM debug file: " .. path) -- 768
		return false -- 769
	end -- 769
	return true -- 771
end -- 766
local function createStepLLMDebugPair(shared, stepId, inContent) -- 774
	if not canWriteStepLLMDebug(shared, stepId) then -- 774
		return 0 -- 775
	end -- 775
	local dir = getStepLLMDebugDir(shared) -- 776
	if not ensureDirRecursive(dir) then -- 776
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 778
		return 0 -- 779
	end -- 779
	local seq = getLatestStepLLMDebugSeq(shared, stepId) + 1 -- 781
	local inPath = getStepLLMDebugPath(shared, stepId, seq, "in") -- 782
	local outPath = getStepLLMDebugPath(shared, stepId, seq, "out") -- 783
	if not writeStepLLMDebugFile(inPath, inContent) then -- 783
		return 0 -- 785
	end -- 785
	writeStepLLMDebugFile(outPath, "") -- 787
	return seq -- 788
end -- 774
local function updateLatestStepLLMDebugOutput(shared, stepId, content) -- 791
	if not canWriteStepLLMDebug(shared, stepId) then -- 791
		return -- 792
	end -- 792
	local dir = getStepLLMDebugDir(shared) -- 793
	if not ensureDirRecursive(dir) then -- 793
		Log("Warn", "[CodingAgent] failed to create LLM debug dir: " .. dir) -- 795
		return -- 796
	end -- 796
	local latestSeq = getLatestStepLLMDebugSeq(shared, stepId) -- 798
	if latestSeq <= 0 then -- 798
		local outPath = getStepLLMDebugPath(shared, stepId, 1, "out") -- 800
		writeStepLLMDebugFile(outPath, content) -- 801
		return -- 802
	end -- 802
	local outPath = getStepLLMDebugPath(shared, stepId, latestSeq, "out") -- 804
	writeStepLLMDebugFile(outPath, content) -- 805
end -- 791
local function saveStepLLMDebugInput(shared, stepId, phase, messages, options) -- 808
	if not canWriteStepLLMDebug(shared, stepId) then -- 808
		return -- 809
	end -- 809
	local sections = { -- 810
		"# LLM Input", -- 811
		"session_id: " .. tostring(shared.sessionId), -- 812
		"task_id: " .. tostring(shared.taskId), -- 813
		"step_id: " .. tostring(stepId), -- 814
		"phase: " .. phase, -- 815
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 816
		"## Options", -- 817
		"```json", -- 818
		encodeDebugJSON(options), -- 819
		"```" -- 820
	} -- 820
	local firstMessage = #messages > 0 and messages[1] or nil -- 822
	if firstMessage and firstMessage.role == "system" and type(firstMessage.content) == "string" then -- 822
		sections[#sections + 1] = "# System Prompt" -- 824
		sections[#sections + 1] = firstMessage.content -- 825
	end -- 825
	do -- 825
		local i = 0 -- 827
		while i < #messages do -- 827
			local message = messages[i + 1] -- 828
			sections[#sections + 1] = "## Message " .. tostring(i + 1) -- 829
			sections[#sections + 1] = encodeDebugJSON(message) -- 830
			i = i + 1 -- 827
		end -- 827
	end -- 827
	createStepLLMDebugPair( -- 832
		shared, -- 832
		stepId, -- 832
		table.concat(sections, "\n") -- 832
	) -- 832
end -- 808
local function saveStepLLMDebugOutput(shared, stepId, phase, text, meta) -- 835
	if not canWriteStepLLMDebug(shared, stepId) then -- 835
		return -- 836
	end -- 836
	local ____array_24 = __TS__SparseArrayNew( -- 836
		"# LLM Output", -- 838
		"session_id: " .. tostring(shared.sessionId), -- 839
		"task_id: " .. tostring(shared.taskId), -- 840
		"step_id: " .. tostring(stepId), -- 841
		"phase: " .. phase, -- 842
		"timestamp: " .. os.date("!%Y-%m-%dT%H:%M:%SZ"), -- 843
		table.unpack(meta and ({ -- 844
			"## Meta", -- 844
			"```json", -- 844
			encodeDebugJSON(meta), -- 844
			"```" -- 844
		}) or ({})) -- 844
	) -- 844
	__TS__SparseArrayPush(____array_24, "## Content", text) -- 844
	local sections = {__TS__SparseArraySpread(____array_24)} -- 837
	updateLatestStepLLMDebugOutput( -- 848
		shared, -- 848
		stepId, -- 848
		table.concat(sections, "\n") -- 848
	) -- 848
end -- 835
local function toJson(value, emptyAsArray) -- 851
	local text, err = safeJsonEncode(value, false, emptyAsArray) -- 852
	if text ~= nil then -- 852
		return text -- 853
	end -- 853
	return ("{ \"error\": \"json_encode_failed\", \"message\": \"" .. tostring(err)) .. "\" }" -- 854
end -- 851
local function summarizeEditTextParamForHistory(value, key) -- 904
	if type(value) ~= "string" then -- 904
		return nil -- 905
	end -- 905
	local text = value -- 906
	local lineCount = text == "" and 0 or #__TS__StringSplit(text, "\n") -- 907
	return {charCount = #text, lineCount = lineCount, isMultiline = lineCount > 1, summaryType = key .. "_summary"} -- 908
end -- 904
local function sanitizeActionParamsForHistory(tool, params) -- 1024
	if tool ~= "edit_file" then -- 1024
		return params -- 1025
	end -- 1025
	local clone = {} -- 1026
	for key in pairs(params) do -- 1027
		if key == "old_str" then -- 1027
			clone.old_str_stats = summarizeEditTextParamForHistory(params[key], "old_str") -- 1029
		elseif key == "new_str" then -- 1029
			clone.new_str_stats = summarizeEditTextParamForHistory(params[key], "new_str") -- 1031
		else -- 1031
			clone[key] = params[key] -- 1033
		end -- 1033
	end -- 1033
	return clone -- 1036
end -- 1024
local function getDecisionToolSchemaText(shared) -- 1078
	local toolsText = safeJsonEncode(AgentToolRegistry.buildDecisionToolSchema( -- 1079
		shared.role, -- 1079
		AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 1079
		{ -- 1079
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 1080
			workMode = shared.workMode -- 1081
		} -- 1081
	)) -- 1081
	return toolsText or "" -- 1083
end -- 1078
local function clearPreExecutedResults(shared) -- 1093
	shared.preExecutedResults = nil -- 1094
end -- 1093
local function startPreExecutedToolAction(shared, action) -- 1097
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1097
		local ____hasReturned, ____returnValue -- 1097
		local ____try = __TS__AsyncAwaiter(function() -- 1097
			____hasReturned = true -- 1099
			____returnValue = __TS__Await(executeToolAction(shared, action)) -- 1099
			return -- 1099
		end) -- 1099
		____try = ____try.catch( -- 1099
			____try, -- 1099
			function(____, err) -- 1099
				return __TS__AsyncAwaiter(function() -- 1099
					local message = tostring(err) -- 1101
					Log("Error", (((("[CodingAgent] streaming pre-exec failed tool=" .. action.tool) .. " id=") .. action.toolCallId) .. ": ") .. message) -- 1102
					____hasReturned = true -- 1103
					____returnValue = {success = false, message = message} -- 1103
					return -- 1103
				end) -- 1103
			end -- 1103
		) -- 1103
		__TS__Await(____try) -- 1098
		if ____hasReturned then -- 1098
			return ____awaiter_resolve(nil, ____returnValue) -- 1098
		end -- 1098
	end) -- 1098
end -- 1097
local function createPreExecutedToolResult(shared, action) -- 1107
	local cloneParamValue -- 1108
	cloneParamValue = function(value) -- 1108
		if value == nil then -- 1108
			return value -- 1109
		end -- 1109
		if isArray(value) then -- 1109
			return __TS__ArrayMap( -- 1111
				value, -- 1111
				function(____, item) return cloneParamValue(item) end -- 1111
			) -- 1111
		end -- 1111
		if type(value) == "table" then -- 1111
			local clone = {} -- 1114
			for key in pairs(value) do -- 1115
				clone[key] = cloneParamValue(value[key]) -- 1116
			end -- 1116
			return clone -- 1118
		end -- 1118
		return value -- 1120
	end -- 1108
	local params = cloneParamValue(action.params) -- 1122
	local areParamValuesEqual -- 1123
	areParamValuesEqual = function(left, right) -- 1123
		if left == right then -- 1123
			return true -- 1124
		end -- 1124
		if left == nil or right == nil then -- 1124
			return false -- 1125
		end -- 1125
		if isArray(left) or isArray(right) then -- 1125
			if not isArray(left) or not isArray(right) or #left ~= #right then -- 1125
				return false -- 1127
			end -- 1127
			do -- 1127
				local i = 0 -- 1128
				while i < #left do -- 1128
					if not areParamValuesEqual(left[i + 1], right[i + 1]) then -- 1128
						return false -- 1129
					end -- 1129
					i = i + 1 -- 1128
				end -- 1128
			end -- 1128
			return true -- 1131
		end -- 1131
		if type(left) == "table" and type(right) == "table" then -- 1131
			local leftCount = 0 -- 1134
			for key in pairs(left) do -- 1135
				leftCount = leftCount + 1 -- 1136
				if not areParamValuesEqual(left[key], right[key]) then -- 1136
					return false -- 1141
				end -- 1141
			end -- 1141
			local rightCount = 0 -- 1144
			for key in pairs(right) do -- 1145
				rightCount = rightCount + 1 -- 1146
			end -- 1146
			return leftCount == rightCount -- 1148
		end -- 1148
		return false -- 1150
	end -- 1123
	return { -- 1152
		action = action, -- 1153
		matches = function(self, nextAction) -- 1154
			return action.tool == nextAction.tool and areParamValuesEqual(params, nextAction.params) -- 1155
		end, -- 1154
		promise = startPreExecutedToolAction(shared, action) -- 1157
	} -- 1157
end -- 1107
local function executeToolActionWithPreExecution(shared, action) -- 1161
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1161
		local ____opt_27 = shared.preExecutedResults -- 1161
		local preResult = ____opt_27 and ____opt_27:get(action.toolCallId) -- 1162
		local result -- 1163
		if preResult then -- 1163
			local ____opt_29 = shared.preExecutedResults -- 1163
			if ____opt_29 ~= nil then -- 1163
				____opt_29:delete(action.toolCallId) -- 1165
			end -- 1165
			if preResult:matches(action) then -- 1165
				Log("Info", (("[CodingAgent] using streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1167
				result = __TS__Await(preResult.promise) -- 1168
			else -- 1168
				Log("Warn", (("[CodingAgent] discard stale streaming pre-exec result tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 1170
				result = __TS__Await(executeToolAction(shared, action)) -- 1171
			end -- 1171
		else -- 1171
			result = __TS__Await(executeToolAction(shared, action)) -- 1174
		end -- 1174
		local guidance = {} -- 1176
		if (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit and action.tool ~= "spawn_sub_agent" and action.tool ~= "finish" then -- 1176
			guidance[#guidance + 1] = "Foreground work after delegation has reached the recommended bound. Prefer dispatching another independent sub-agent or finishing this turn so the user can continue interacting." -- 1182
		end -- 1182
		if shared.resumeRequiredTool ~= nil and action.tool ~= shared.resumeRequiredTool then -- 1182
			guidance[#guidance + 1] = ("The compression checkpoint recommends " .. shared.resumeRequiredTool) .. " next. Avoid restarting broad discovery unless this result shows it is necessary." -- 1185
		end -- 1185
		if shared.failedTestNeedsBuild == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1185
			guidance[#guidance + 1] = "A deterministic test previously failed. Prefer a narrow authored-source fix and a successful build before further testing or generated-output investigation." -- 1188
		end -- 1188
		if action.tool == "search_dora_api" then -- 1188
			if shared.unbuiltEdits == true then -- 1188
				guidance[#guidance + 1] = "There are unbuilt authored changes. Apply only relevant API evidence from this result, then prefer building before more discovery." -- 1192
			end -- 1192
			if (shared.apiSearchesSinceBuild or 0) >= 2 then -- 1192
				guidance[#guidance + 1] = "Dora API documentation has already been searched since the last build. Prefer applying the evidence and building before another lookup." -- 1195
			end -- 1195
		end -- 1195
		if (action.tool == "edit_file" or action.tool == "delete_file") and not AgentRuntimePolicy.isAgentInternalDocumentPath(getDecisionPath(action.params)) and AgentRuntimePolicy.isEditBudgetExhausted(shared) then -- 1195
			guidance[#guidance + 1] = "Several source files have changed since the last build. Prefer compiling now to obtain concrete diagnostics before broadening the edit set." -- 1203
		end -- 1203
		if action.tool == "edit_file" and shared.resumeNarrowReadMode == true then -- 1203
			local oldStr = type(action.params.old_str) == "string" and action.params.old_str or "" -- 1206
			if oldStr == "" then -- 1206
				guidance[#guidance + 1] = "After compression, prefer a targeted old_str replacement or an early build over rewriting a complete existing file." -- 1208
			end -- 1208
		end -- 1208
		if action.tool == "list_sub_agents" and shared.hasSpawnedSubAgentThisTask == true then -- 1208
			guidance[#guidance + 1] = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains." -- 1212
		end -- 1212
		if shared.freshProjectBuildPending == true and action.tool ~= "build" then -- 1212
			guidance[#guidance + 1] = shared.unbuiltEdits == true and "A fresh project now has an authored implementation. Prefer an early build so later work uses compiler feedback." or "This is a fresh project. Prefer creating a compilable first implementation, then build early." -- 1215
		end -- 1215
		if shared.buildRepairPending == true and action.tool ~= "build" and action.tool ~= "edit_file" then -- 1215
			guidance[#guidance + 1] = "The last build reported authored-file diagnostics. Prefer a narrow source repair, then build again." -- 1220
		end -- 1220
		if shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true then -- 1220
			guidance[#guidance + 1] = "The latest build passed with no pending source edits. If the user's acceptance criteria are satisfied, prefer finishing instead of inventing extra probes." -- 1223
		end -- 1223
		if #guidance > 0 then -- 1223
			result.guidance = table.concat(guidance, "\n") -- 1226
		end -- 1226
		return ____awaiter_resolve(nil, result) -- 1226
	end) -- 1226
end -- 1161
local function maybeCompressHistory(shared, forceAtTurnBoundary, pendingUserPrompt) -- 1231
	if forceAtTurnBoundary == nil then -- 1231
		forceAtTurnBoundary = false -- 1233
	end -- 1233
	if pendingUserPrompt == nil then -- 1233
		pendingUserPrompt = "" -- 1234
	end -- 1234
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1234
		local ____shared_31 = shared -- 1236
		local memory = ____shared_31.memory -- 1236
		local maxRounds = memory.compressor:getMaxCompressionRounds() -- 1237
		local changed = false -- 1238
		do -- 1238
			local round = 0 -- 1239
			while round < maxRounds do -- 1239
				local systemPrompt = buildAgentSystemPrompt(shared, shared.decisionMode == "xml") -- 1240
				local activeMessages = getActiveConversationMessages(shared) -- 1241
				local uncoveredMessages = AgentRuntimePolicy.getUncoveredConversationMessages(shared.messages, shared.lastConsolidatedIndex) -- 1246
				local toolDefinitions = shared.decisionMode == "tool_calling" and getDecisionToolSchemaText(shared) or "" -- 1252
				local thresholdReached = memory.compressor:shouldCompress(uncoveredMessages, systemPrompt, toolDefinitions) -- 1255
				local activeTokens = 0 -- 1260
				if forceAtTurnBoundary and shared.role == "main" then -- 1260
					local ____temp_35 = estimateTextTokens(systemPrompt) + estimateTextTokens(toolDefinitions) + AgentRuntimePolicy.estimateConversationTokens(uncoveredMessages) + estimateTextTokens(pendingUserPrompt) -- 1262
					local ____math_max_34 = math.max -- 1266
					local ____math_floor_33 = math.floor -- 1266
					local ____shared_llmOptions_max_tokens_32 = shared.llmOptions.max_tokens -- 1266
					if ____shared_llmOptions_max_tokens_32 == nil then -- 1266
						____shared_llmOptions_max_tokens_32 = AgentConfig.AGENT_DEFAULTS.llmMaxTokens -- 1266
					end -- 1266
					activeTokens = ____temp_35 + ____math_max_34( -- 1262
						0, -- 1266
						____math_floor_33(__TS__Number(____shared_llmOptions_max_tokens_32)) -- 1266
					) -- 1266
				end -- 1266
				local turnBoundaryThreshold = AgentConfig.getTurnBoundaryCompressionThreshold(shared.llmConfig.contextWindow) -- 1268
				local turnBoundaryReached = forceAtTurnBoundary and shared.role == "main" and #uncoveredMessages > 0 and activeTokens >= turnBoundaryThreshold -- 1271
				if not thresholdReached and not turnBoundaryReached then -- 1271
					if changed then -- 1271
						persistHistoryState(shared) -- 1277
					end -- 1277
					return ____awaiter_resolve(nil) -- 1277
				end -- 1277
				local compressionRound = round + 1 -- 1281
				shared.step = shared.step + 1 -- 1282
				local stepId = shared.step -- 1283
				local pendingMessages = #activeMessages -- 1284
				emitAgentEvent( -- 1285
					shared, -- 1285
					{ -- 1285
						type = "memory_compression_started", -- 1286
						sessionId = shared.sessionId, -- 1287
						taskId = shared.taskId, -- 1288
						step = stepId, -- 1289
						tool = "compress_memory", -- 1290
						reason = getMemoryCompressionStartReason(shared), -- 1291
						params = { -- 1292
							round = compressionRound, -- 1293
							maxRounds = maxRounds, -- 1294
							pendingMessages = pendingMessages, -- 1295
							coveredThroughIndex = shared.lastConsolidatedIndex, -- 1296
							uncoveredMessages = #uncoveredMessages -- 1297
						} -- 1297
					} -- 1297
				) -- 1297
				local result = __TS__Await(memory.compressor:compress( -- 1300
					activeMessages, -- 1301
					shared.llmOptions, -- 1302
					shared.llmMaxTry, -- 1303
					shared.decisionMode, -- 1304
					{ -- 1305
						onInput = function(____, phase, messages, options) -- 1306
							saveStepLLMDebugInput( -- 1307
								shared, -- 1307
								stepId, -- 1307
								phase, -- 1307
								messages, -- 1307
								options -- 1307
							) -- 1307
						end, -- 1306
						onOutput = function(____, phase, text, meta) -- 1309
							saveStepLLMDebugOutput( -- 1310
								shared, -- 1310
								stepId, -- 1310
								phase, -- 1310
								text, -- 1310
								meta -- 1310
							) -- 1310
						end, -- 1309
						onUsage = function(____, phase, usage) -- 1312
							recordLLMTokenUsage(shared, stepId, phase, usage) -- 1313
						end -- 1312
					}, -- 1312
					"default", -- 1316
					systemPrompt, -- 1317
					toolDefinitions -- 1318
				)) -- 1318
				if not (result and result.success and result.compressedCount > 0) then -- 1318
					emitAgentEvent( -- 1321
						shared, -- 1321
						{ -- 1321
							type = "memory_compression_finished", -- 1322
							sessionId = shared.sessionId, -- 1323
							taskId = shared.taskId, -- 1324
							step = stepId, -- 1325
							tool = "compress_memory", -- 1326
							reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1327
							result = {success = false, round = compressionRound, error = result and result.error or "compression returned no changes", compressedCount = result and result.compressedCount or 0} -- 1331
						} -- 1331
					) -- 1331
					if changed then -- 1331
						persistHistoryState(shared) -- 1339
					end -- 1339
					return ____awaiter_resolve(nil) -- 1339
				end -- 1339
				local effectiveCompressedCount = math.max( -- 1343
					0, -- 1344
					result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1345
				) -- 1345
				if effectiveCompressedCount <= 0 then -- 1345
					if changed then -- 1345
						persistHistoryState(shared) -- 1349
					end -- 1349
					return ____awaiter_resolve(nil) -- 1349
				end -- 1349
				emitAgentEvent( -- 1353
					shared, -- 1353
					{ -- 1353
						type = "memory_compression_finished", -- 1354
						sessionId = shared.sessionId, -- 1355
						taskId = shared.taskId, -- 1356
						step = stepId, -- 1357
						tool = "compress_memory", -- 1358
						reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1359
						result = { -- 1360
							success = true, -- 1361
							round = compressionRound, -- 1362
							compressedCount = effectiveCompressedCount, -- 1363
							coveredThroughIndex = math.min(#shared.messages, shared.lastConsolidatedIndex + effectiveCompressedCount), -- 1364
							historyEntryPreview = summarizeHistoryEntryPreview(result.summary or "") -- 1365
						} -- 1365
					} -- 1365
				) -- 1365
				applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1368
				changed = true -- 1369
				Log( -- 1370
					"Info", -- 1370
					((("[Memory] Compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(compressionRound)) .. ")" -- 1370
				) -- 1370
				round = round + 1 -- 1239
			end -- 1239
		end -- 1239
		if changed then -- 1239
			persistHistoryState(shared) -- 1373
		end -- 1373
	end) -- 1373
end -- 1231
local function compactAllHistory(shared) -- 1377
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1377
		local ____shared_42 = shared -- 1378
		local memory = ____shared_42.memory -- 1378
		local rounds = 0 -- 1379
		local totalCompressed = 0 -- 1380
		while getActiveRealMessageCount(shared) > 0 do -- 1380
			if shared.stopToken.stopped then -- 1380
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 1383
				return ____awaiter_resolve( -- 1383
					nil, -- 1383
					emitAgentTaskFinishEvent( -- 1384
						shared, -- 1384
						false, -- 1384
						getCancelledReason(shared) -- 1384
					) -- 1384
				) -- 1384
			end -- 1384
			rounds = rounds + 1 -- 1386
			shared.step = shared.step + 1 -- 1387
			local stepId = shared.step -- 1388
			local activeMessages = getActiveConversationMessages(shared) -- 1389
			local pendingMessages = #activeMessages -- 1390
			emitAgentEvent( -- 1391
				shared, -- 1391
				{ -- 1391
					type = "memory_compression_started", -- 1392
					sessionId = shared.sessionId, -- 1393
					taskId = shared.taskId, -- 1394
					step = stepId, -- 1395
					tool = "compress_memory", -- 1396
					reason = getMemoryCompressionStartReason(shared), -- 1397
					params = {round = rounds, maxRounds = 0, pendingMessages = pendingMessages, fullCompaction = true} -- 1398
				} -- 1398
			) -- 1398
			local result = __TS__Await(memory.compressor:compress( -- 1405
				activeMessages, -- 1406
				shared.llmOptions, -- 1407
				shared.llmMaxTry, -- 1408
				shared.decisionMode, -- 1409
				{ -- 1410
					onInput = function(____, phase, messages, options) -- 1411
						saveStepLLMDebugInput( -- 1412
							shared, -- 1412
							stepId, -- 1412
							phase, -- 1412
							messages, -- 1412
							options -- 1412
						) -- 1412
					end, -- 1411
					onOutput = function(____, phase, text, meta) -- 1414
						saveStepLLMDebugOutput( -- 1415
							shared, -- 1415
							stepId, -- 1415
							phase, -- 1415
							text, -- 1415
							meta -- 1415
						) -- 1415
					end, -- 1414
					onUsage = function(____, phase, usage) -- 1417
						recordLLMTokenUsage(shared, stepId, phase, usage) -- 1418
					end -- 1417
				}, -- 1417
				"budget_max" -- 1421
			)) -- 1421
			if not (result and result.success and result.compressedCount > 0) then -- 1421
				emitAgentEvent( -- 1424
					shared, -- 1424
					{ -- 1424
						type = "memory_compression_finished", -- 1425
						sessionId = shared.sessionId, -- 1426
						taskId = shared.taskId, -- 1427
						step = stepId, -- 1428
						tool = "compress_memory", -- 1429
						reason = getMemoryCompressionFailureReason(shared, result and result.error or "compression returned no changes"), -- 1430
						result = { -- 1434
							success = false, -- 1435
							rounds = rounds, -- 1436
							error = result and result.error or "compression returned no changes", -- 1437
							compressedCount = result and result.compressedCount or 0, -- 1438
							fullCompaction = true -- 1439
						} -- 1439
					} -- 1439
				) -- 1439
				return ____awaiter_resolve( -- 1439
					nil, -- 1439
					finalizeAgentFailure(shared, result and result.error or (shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.")) -- 1442
				) -- 1442
			end -- 1442
			local effectiveCompressedCount = math.max( -- 1447
				0, -- 1448
				result.compressedCount - (type(shared.carryMessageIndex) == "number" and 1 or 0) -- 1449
			) -- 1449
			if effectiveCompressedCount <= 0 then -- 1449
				return ____awaiter_resolve( -- 1449
					nil, -- 1449
					finalizeAgentFailure(shared, shared.useChineseResponse and "记忆压缩未产生可推进的结果。" or "Memory compression produced no progress.") -- 1452
				) -- 1452
			end -- 1452
			emitAgentEvent( -- 1459
				shared, -- 1459
				{ -- 1459
					type = "memory_compression_finished", -- 1460
					sessionId = shared.sessionId, -- 1461
					taskId = shared.taskId, -- 1462
					step = stepId, -- 1463
					tool = "compress_memory", -- 1464
					reason = getMemoryCompressionSuccessReason(shared, result.compressedCount), -- 1465
					result = { -- 1466
						success = true, -- 1467
						round = rounds, -- 1468
						compressedCount = effectiveCompressedCount, -- 1469
						historyEntryPreview = summarizeHistoryEntryPreview(result.summary or ""), -- 1470
						fullCompaction = true -- 1471
					} -- 1471
				} -- 1471
			) -- 1471
			applyCompressedSessionState(shared, result.compressedCount, result.carryMessageIndex, result.sessionSummaryUpdate) -- 1474
			totalCompressed = totalCompressed + effectiveCompressedCount -- 1475
			persistHistoryState(shared) -- 1476
			Log( -- 1477
				"Info", -- 1477
				((("[Memory] Full compaction compressed " .. tostring(effectiveCompressedCount)) .. " messages (round ") .. tostring(rounds)) .. ")" -- 1477
			) -- 1477
		end -- 1477
		Tools.setTaskStatus(shared.taskId, "DONE") -- 1479
		return ____awaiter_resolve( -- 1479
			nil, -- 1479
			emitAgentTaskFinishEvent( -- 1480
				shared, -- 1481
				true, -- 1482
				shared.useChineseResponse and ((("会话整理完成，共整理 " .. tostring(totalCompressed)) .. " 条消息，耗时 ") .. tostring(rounds)) .. " 轮。" or ((("Session compaction completed. Consolidated " .. tostring(totalCompressed)) .. " messages in ") .. tostring(rounds)) .. " rounds." -- 1483
			) -- 1483
		) -- 1483
	end) -- 1483
end -- 1377
local function clearSessionHistory(shared) -- 1489
	shared.messages = {} -- 1490
	shared.lastConsolidatedIndex = 0 -- 1491
	shared.carryMessageIndex = nil -- 1492
	persistHistoryState(shared) -- 1493
	Tools.setTaskStatus(shared.taskId, "DONE") -- 1494
	return emitAgentTaskFinishEvent(shared, true, shared.useChineseResponse and "SESSION.jsonl 已清空。" or "SESSION.jsonl has been cleared.") -- 1495
end -- 1489
COMPLETION_TEXT_MAX_CHARS = 800 -- 1517
COMPLETION_LIST_MAX_ITEMS = 12 -- 1518
COMPLETION_EVIDENCE_MAX_ITEMS = 8 -- 1519
local function appendConversationMessage(shared, message) -- 1714
	local ____shared_messages_51 = shared.messages -- 1714
	____shared_messages_51[#____shared_messages_51 + 1] = __TS__ObjectAssign( -- 1715
		{}, -- 1715
		message, -- 1716
		{ -- 1715
			content = message.content and sanitizeUTF8(message.content) or message.content, -- 1717
			name = message.name and sanitizeUTF8(message.name) or message.name, -- 1718
			tool_call_id = message.tool_call_id and sanitizeUTF8(message.tool_call_id) or message.tool_call_id, -- 1719
			reasoning_content = message.reasoning_content and sanitizeUTF8(message.reasoning_content) or message.reasoning_content, -- 1720
			timestamp = message.timestamp or os.date("!%Y-%m-%dT%H:%M:%SZ") -- 1721
		} -- 1721
	) -- 1721
end -- 1714
local function appendToolResultMessage(shared, action) -- 1730
	appendConversationMessage( -- 1731
		shared, -- 1731
		{ -- 1731
			role = "tool", -- 1732
			tool_call_id = action.toolCallId, -- 1733
			name = action.tool, -- 1734
			content = action.result and toJson(action.result, false) or "" -- 1735
		} -- 1735
	) -- 1735
end -- 1730
local function appendAssistantToolCallsMessage(shared, actions, content, reasoningContent) -- 1739
	appendConversationMessage( -- 1745
		shared, -- 1745
		{ -- 1745
			role = "assistant", -- 1746
			content = content or "", -- 1747
			reasoning_content = reasoningContent, -- 1748
			tool_calls = __TS__ArrayMap( -- 1749
				actions, -- 1749
				function(____, action) return { -- 1749
					id = action.toolCallId, -- 1750
					type = "function", -- 1751
					["function"] = { -- 1752
						name = action.tool, -- 1753
						arguments = toJson(action.params, false) -- 1754
					} -- 1754
				} end -- 1754
			) -- 1754
		} -- 1754
	) -- 1754
end -- 1739
local function llm(shared, messages, phase) -- 1938
	if phase == nil then -- 1938
		phase = "decision_xml" -- 1941
	end -- 1941
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 1941
		local stepId = shared.step + 1 -- 1943
		emitLLMContextMetrics( -- 1944
			shared, -- 1944
			stepId, -- 1944
			phase, -- 1944
			messages, -- 1944
			shared.llmOptions -- 1944
		) -- 1944
		saveStepLLMDebugInput( -- 1945
			shared, -- 1945
			stepId, -- 1945
			phase, -- 1945
			messages, -- 1945
			shared.llmOptions -- 1945
		) -- 1945
		local lastStreamReasoning = "" -- 1946
		local res = __TS__Await(callLLMStreamAggregated( -- 1947
			messages, -- 1948
			shared.llmOptions, -- 1949
			shared.stopToken, -- 1950
			shared.llmConfig, -- 1951
			function(response) -- 1952
				local ____opt_55 = response.choices -- 1952
				local ____opt_53 = ____opt_55 and ____opt_55[1] -- 1952
				local streamMessage = ____opt_53 and ____opt_53.message -- 1953
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 1954
				if nextContent == "" then -- 1954
					return -- 1957
				end -- 1957
				if nextContent == lastStreamReasoning then -- 1957
					return -- 1958
				end -- 1958
				lastStreamReasoning = nextContent -- 1959
				emitAssistantMessageUpdated(shared, "", nextContent) -- 1960
			end -- 1952
		)) -- 1952
		if res.success then -- 1952
			local usage = res.tokenUsage -- 1964
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 1965
			local ____opt_61 = res.response.choices -- 1965
			local ____opt_59 = ____opt_61 and ____opt_61[1] -- 1965
			local message = ____opt_59 and ____opt_59.message -- 1966
			local text = message and message.content -- 1967
			local reasoningContent = type(message and message.reasoning_content) == "string" and sanitizeUTF8(message.reasoning_content) or nil -- 1968
			if text then -- 1968
				local parsed = tryParseAndValidateDecision(text, shared) -- 1972
				if parsed.success then -- 1972
					local reason = parsed.reason or "" -- 1974
					emitAssistantMessageUpdated(shared, "", reason ~= "" and reason or nil) -- 1975
				end -- 1975
				saveStepLLMDebugOutput( -- 1977
					shared, -- 1977
					stepId, -- 1977
					phase, -- 1977
					text, -- 1977
					{success = true, usage = usage} -- 1977
				) -- 1977
				return ____awaiter_resolve(nil, {success = true, text = text, reasoningContent = reasoningContent}) -- 1977
			else -- 1977
				saveStepLLMDebugOutput( -- 1980
					shared, -- 1980
					stepId, -- 1980
					phase, -- 1980
					"empty LLM response", -- 1980
					{success = false, usage = usage} -- 1980
				) -- 1980
				return ____awaiter_resolve(nil, {success = false, message = "empty LLM response"}) -- 1980
			end -- 1980
		else -- 1980
			local usage = res.tokenUsage -- 1984
			recordLLMTokenUsage(shared, stepId, phase, usage) -- 1985
			saveStepLLMDebugOutput( -- 1986
				shared, -- 1986
				stepId, -- 1986
				phase, -- 1986
				res.raw or res.message, -- 1986
				{success = false, usage = usage} -- 1986
			) -- 1986
			return ____awaiter_resolve(nil, {success = false, message = res.message}) -- 1986
		end -- 1986
	end) -- 1986
end -- 1938
local function isDecisionBatchSuccess(result) -- 2010
	return result.kind == "batch" -- 2011
end -- 2010
local function parseDecisionToolCall(functionName, rawObj) -- 2035
	if not AgentToolRegistry.isKnownToolName(functionName) then -- 2035
		return {success = false, message = "unknown tool: " .. functionName} -- 2037
	end -- 2037
	if rawObj == nil then -- 2037
		return {success = true, tool = functionName, params = {}} -- 2040
	end -- 2040
	if not isRecord(rawObj) then -- 2040
		return {success = false, message = ("invalid " .. functionName) .. " arguments"} -- 2043
	end -- 2043
	return {success = true, tool = functionName, params = rawObj} -- 2045
end -- 2035
local function parseToolCallArguments(functionName, argsText) -- 2052
	local trimmedArgs = __TS__StringTrim(argsText) -- 2053
	if trimmedArgs == "" then -- 2053
		return {} -- 2055
	end -- 2055
	local rawObj, err = safeJsonDecode(trimmedArgs) -- 2057
	if err ~= nil or rawObj == nil then -- 2057
		return { -- 2059
			success = false, -- 2060
			message = (("invalid " .. functionName) .. " arguments: ") .. tostring(err), -- 2061
			raw = argsText -- 2062
		} -- 2062
	end -- 2062
	local encodedRaw = safeJsonEncode(rawObj) -- 2065
	if encodedRaw == "null" or not isRecord(rawObj) or __TS__StringAccess(trimmedArgs, 0) == "[" then -- 2065
		return {success = false, message = ("invalid " .. functionName) .. " arguments", raw = argsText} -- 2067
	end -- 2067
	return rawObj -- 2073
end -- 2052
local function parseAndValidateToolCallDecision(shared, functionName, argsText, toolCallId, reason, reasoningContent) -- 2076
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2084
	if isRecord(rawArgs) and rawArgs.success == false then -- 2084
		return rawArgs -- 2086
	end -- 2086
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2088
	if not decision.success then -- 2088
		return {success = false, message = decision.message, raw = argsText} -- 2090
	end -- 2090
	local completionValidation = validateCompletionForRole(shared.role, decision.tool, decision.params) -- 2096
	if not completionValidation.success then -- 2096
		return {success = false, message = completionValidation.message, raw = argsText} -- 2098
	end -- 2098
	local validation = validateDecision(decision.tool, decision.params) -- 2104
	if not validation.success then -- 2104
		return {success = false, message = validation.message, raw = argsText} -- 2106
	end -- 2106
	local sharedValidation = validateDecisionForShared(shared, decision.tool, validation.params, true) -- 2112
	if not sharedValidation.success then -- 2112
		return {success = false, message = sharedValidation.message, raw = argsText} -- 2114
	end -- 2114
	decision.params = validation.params -- 2120
	decision.toolCallId = ensureToolCallId(toolCallId) -- 2121
	decision.reason = reason -- 2122
	decision.reasoningContent = reasoningContent -- 2123
	return decision -- 2124
end -- 2076
local function createPreExecutableActionFromStream(shared, toolCall) -- 2127
	local ____opt_67 = toolCall["function"] -- 2127
	local functionName = ____opt_67 and ____opt_67.name -- 2128
	local ____opt_69 = toolCall["function"] -- 2128
	local argsText = ____opt_69 and ____opt_69.arguments or "" -- 2129
	local toolCallId = type(toolCall.id) == "string" and toolCall.id or nil -- 2130
	if not functionName or not toolCallId then -- 2130
		return nil -- 2131
	end -- 2131
	local rawArgs = parseToolCallArguments(functionName, argsText) -- 2132
	if isRecord(rawArgs) and rawArgs.success == false then -- 2132
		return nil -- 2133
	end -- 2133
	local decision = parseDecisionToolCall(functionName, rawArgs) -- 2134
	if not decision.success or not AgentToolRegistry.canPreExecuteTool(decision.tool) then -- 2134
		return nil -- 2135
	end -- 2135
	local validation = validateDecision(decision.tool, decision.params) -- 2136
	if not validation.success then -- 2136
		return nil -- 2137
	end -- 2137
	if not validateDecisionForShared(shared, decision.tool, validation.params).success then -- 2137
		return nil -- 2138
	end -- 2138
	return { -- 2139
		step = shared.step + 1, -- 2140
		toolCallId = toolCallId, -- 2141
		tool = decision.tool, -- 2142
		reason = "", -- 2143
		params = validation.params, -- 2144
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 2145
	} -- 2145
end -- 2127
local function sanitizeMessagesForLLMInput(messages) -- 2392
	local sanitized = {} -- 2393
	local droppedAssistantToolCalls = 0 -- 2394
	local droppedToolResults = 0 -- 2395
	do -- 2395
		local i = 0 -- 2396
		while i < #messages do -- 2396
			do -- 2396
				local message = messages[i + 1] -- 2397
				if message.role == "assistant" and message.tool_calls and #message.tool_calls > 0 then -- 2397
					local requiredIds = {} -- 2399
					do -- 2399
						local j = 0 -- 2400
						while j < #message.tool_calls do -- 2400
							local toolCall = message.tool_calls[j + 1] -- 2401
							local id = type(toolCall and toolCall.id) == "string" and toolCall.id or "" -- 2402
							if id ~= "" and __TS__ArrayIndexOf(requiredIds, id) < 0 then -- 2402
								requiredIds[#requiredIds + 1] = id -- 2404
							end -- 2404
							j = j + 1 -- 2400
						end -- 2400
					end -- 2400
					if #requiredIds == 0 then -- 2400
						sanitized[#sanitized + 1] = message -- 2408
						goto __continue405 -- 2409
					end -- 2409
					local matchedIds = {} -- 2411
					local matchedTools = {} -- 2412
					local j = i + 1 -- 2413
					while j < #messages do -- 2413
						local toolMessage = messages[j + 1] -- 2415
						if toolMessage.role ~= "tool" then -- 2415
							break -- 2416
						end -- 2416
						local toolCallId = type(toolMessage.tool_call_id) == "string" and toolMessage.tool_call_id or "" -- 2417
						if toolCallId ~= "" and __TS__ArrayIndexOf(requiredIds, toolCallId) >= 0 and matchedIds[toolCallId] ~= true then -- 2417
							matchedIds[toolCallId] = true -- 2419
							matchedTools[#matchedTools + 1] = toolMessage -- 2420
						else -- 2420
							droppedToolResults = droppedToolResults + 1 -- 2422
						end -- 2422
						j = j + 1 -- 2424
					end -- 2424
					local complete = true -- 2426
					do -- 2426
						local j = 0 -- 2427
						while j < #requiredIds do -- 2427
							if matchedIds[requiredIds[j + 1]] ~= true then -- 2427
								complete = false -- 2429
								break -- 2430
							end -- 2430
							j = j + 1 -- 2427
						end -- 2427
					end -- 2427
					if complete then -- 2427
						__TS__ArrayPush( -- 2434
							sanitized, -- 2434
							message, -- 2434
							table.unpack(matchedTools) -- 2434
						) -- 2434
					else -- 2434
						droppedAssistantToolCalls = droppedAssistantToolCalls + 1 -- 2436
						droppedToolResults = droppedToolResults + #matchedTools -- 2437
					end -- 2437
					i = j - 1 -- 2439
					goto __continue405 -- 2440
				end -- 2440
				if message.role == "tool" then -- 2440
					droppedToolResults = droppedToolResults + 1 -- 2443
					goto __continue405 -- 2444
				end -- 2444
				sanitized[#sanitized + 1] = message -- 2446
			end -- 2446
			::__continue405:: -- 2446
			i = i + 1 -- 2396
		end -- 2396
	end -- 2396
	return sanitized -- 2448
end -- 2392
local function getUnconsolidatedMessages(shared) -- 2451
	return sanitizeMessagesForLLMInput(getActiveConversationMessages(shared)) -- 2452
end -- 2451
local function getFinalDecisionTurnPrompt(shared) -- 2459
	return shared.useChineseResponse and "当前已到达本 task 的最后处理轮次。不要再调用其它工具，请调用 finish 收束本轮。只有实施和验收条件确实全部完成时才将 outcome 设为 completed；否则设为 partial，且 message 必须明确分为：已有直接证据的已完成内容、尚未验证或未完成的项目、继续执行时的下一步。validation 对未执行的相关检查使用 not_run，knownIssues 记录剩余问题。不要把部分结果描述为全部完成。" or "This is the final processing turn for the current task. Do not call another work tool; call finish to close the turn. Set outcome to completed only when implementation and every acceptance criterion are actually complete. Otherwise use partial, and clearly separate work completed with direct evidence, unverified or unfinished items, and the next action for continuation in message. Use not_run for relevant validation that was not performed and record remaining issues in knownIssues. Do not describe partial work as fully completed." -- 2460
end -- 2459
local function buildDecisionMessages(shared, lastError, attempt, lastRaw, decisionMode) -- 2465
	if attempt == nil then -- 2465
		attempt = 1 -- 2468
	end -- 2468
	if decisionMode == nil then -- 2468
		decisionMode = shared.decisionMode -- 2470
	end -- 2470
	local systemPrompt = buildAgentSystemPrompt(shared, decisionMode == "xml") -- 2472
	local tailSections = {} -- 2473
	if shared.resumeCheckpointPending == true then -- 2473
		local activeUserInstruction = type(shared.carryMessageIndex) == "number" and " The active carried user instruction is newer than the compressed checkpoint and takes precedence." or "" -- 2475
		tailSections[#tailSections + 1] = "Resume after compression: continue from the Session Summary's Active Checkpoint without restarting discovery." .. activeUserInstruction -- 2478
	end -- 2478
	if shared.truncatedToolOverwritePath ~= nil then -- 2478
		tailSections[#tailSections + 1] = ("Truncated response result: the fully decoded prefix from an empty-old_str whole-file overwrite was saved directly to " .. shared.truncatedToolOverwritePath) .. ". Inspect that file next and decide whether it already suffices or needs a bounded continuation. Do not regenerate the preserved prefix." -- 2481
	end -- 2481
	shared.resumeCheckpointPending = false -- 2483
	local messages = { -- 2484
		{role = "system", content = systemPrompt}, -- 2485
		table.unpack(getUnconsolidatedMessages(shared)) -- 2486
	} -- 2486
	if isFinalDecisionTurn(shared) then -- 2486
		tailSections[#tailSections + 1] = getFinalDecisionTurnPrompt(shared) -- 2489
	end -- 2489
	if lastError and lastError ~= "" then -- 2489
		local retryHeader = decisionMode == "xml" and ("Previous response was invalid (" .. lastError) .. "). Return exactly one valid XML tool_call block only." or replacePromptVars(shared.promptPack.toolCallingRetryPrompt, {LAST_ERROR = lastError}) -- 2492
		if decisionMode == "xml" then -- 2492
			retryHeader = retryHeader .. "\nThe response must start with <tool_call> and end with </tool_call>. Do not use any other root tag. Do not return partial child tags." -- 2496
		end -- 2496
		if decisionMode == "xml" and lastRaw and __TS__StringTrim(lastRaw) ~= "" then -- 2496
			retryHeader = retryHeader .. "\nIf the rejected output said you would inspect, read, search, build, edit, or continue working, convert that intent into the corresponding XML tool call. Do not use finish for intended future work." -- 2499
		end -- 2499
		if decisionMode == "tool_calling" and (string.find(lastError, "truncated by max tokens", nil, true) or 0) - 1 >= 0 then -- 2499
			retryHeader = retryHeader .. "\nThe previous response exceeded the output limit and no recoverable edit result was available. Do not repeat the same payload. Immediately emit one complete tool call with bounded arguments and minimal reasoning." -- 2502
		end -- 2502
		messages[#messages + 1] = { -- 2504
			role = "user", -- 2505
			content = (((retryHeader .. "\n\n\t\tRetry attempt: ") .. tostring(attempt)) .. ".\n\tThe next reply must differ from the previously rejected output.\n\t") .. (lastRaw and lastRaw ~= "" and "Last rejected output summary: " .. truncateText(lastRaw, 300) or "") -- 2506
		} -- 2506
	end -- 2506
	tailSections[#tailSections + 1] = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2513
		role = shared.role, -- 2514
		workMode = shared.workMode, -- 2515
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2516
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2517
		resumeRequiredTool = shared.resumeRequiredTool, -- 2518
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2519
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2520
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2521
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2522
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2523
		buildRepairPending = shared.buildRepairPending, -- 2524
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2525
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2526
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2527
	}) -- 2527
	messages[#messages + 1] = { -- 2529
		role = "user", -- 2530
		content = table.concat(tailSections, "\n\n") -- 2531
	} -- 2531
	return messages -- 2533
end -- 2465
local function buildXmlRepairMessages(shared, originalRaw, originalReasoning, candidateRaw, candidateReasoning, lastError, attempt) -- 2540
	local hasOriginalReasoning = originalReasoning ~= nil and __TS__StringTrim(originalReasoning) ~= "" -- 2549
	local originalReasoningSection = hasOriginalReasoning and ("### Original Reasoning\n```\n" .. truncateText(originalReasoning, 4000)) .. "\n```\n\n" or "" -- 2550
	local hasCandidate = __TS__StringTrim(candidateRaw) ~= "" -- 2558
	local hasCandidateReasoning = candidateReasoning ~= nil and __TS__StringTrim(candidateReasoning) ~= "" -- 2559
	local candidateReasoningSection = hasCandidateReasoning and ("### Current Candidate Reasoning\n```\n" .. truncateText(candidateReasoning, 4000)) .. "\n```\n\n" or "" -- 2560
	local candidateSection = hasCandidate and (("### Current Candidate To Repair\n```\n" .. truncateText(candidateRaw, 4000)) .. "\n```\n\n") .. candidateReasoningSection or "" -- 2568
	local toolRepairReference = AgentToolRegistry.buildRoleToolDefinitionsDetailed( -- 2576
		shared.role, -- 2576
		{ -- 2576
			includeFinish = true, -- 2577
			includeXmlRules = true, -- 2578
			context = {searchDoraApiLimitMax = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax}, -- 2579
			disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2580
			workMode = shared.workMode -- 2581
		} -- 2581
	) -- 2581
	local systemPrompt = replacePromptVars(shared.promptPack.xmlDecisionSystemRepairPrompt, {TOOL_REPAIR_REFERENCE = toolRepairReference}) -- 2583
	local repairPrompt = replacePromptVars( -- 2586
		shared.promptPack.xmlDecisionRepairPrompt, -- 2586
		{ -- 2586
			ORIGINAL_RAW = truncateText(originalRaw, 4000), -- 2587
			ORIGINAL_REASONING_SECTION = originalReasoningSection, -- 2588
			CANDIDATE_SECTION = candidateSection, -- 2589
			LAST_ERROR = lastError, -- 2590
			ATTEMPT = tostring(attempt) -- 2591
		} -- 2591
	) -- 2591
	local availabilityPrompt = AgentToolRegistry.buildCurrentToolAvailabilityPrompt({ -- 2593
		role = shared.role, -- 2594
		workMode = shared.workMode, -- 2595
		taskDisabledAgentTools = shared.disabledAgentTools, -- 2596
		currentDisabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2597
		resumeRequiredTool = shared.resumeRequiredTool, -- 2598
		hasSpawnedSubAgentThisTask = shared.hasSpawnedSubAgentThisTask, -- 2599
		delegatedForegroundBudgetExhausted = (shared.delegatedForegroundBatches or 0) >= AgentConfig.AGENT_DEFAULTS.delegatedForegroundBatchLimit, -- 2600
		freshProjectBuildPending = shared.freshProjectBuildPending, -- 2601
		freshProjectCodeFile = shared.freshProjectCodeFile, -- 2602
		freshProjectHasAuthoredEdit = shared.freshProjectBuildPending == true and shared.unbuiltEdits == true, -- 2603
		buildRepairPending = shared.buildRepairPending, -- 2604
		lastBuildSucceeded = shared.lastBuildSucceeded == true and shared.unbuiltEdits ~= true, -- 2605
		editBudgetExhausted = AgentRuntimePolicy.isEditBudgetExhausted(shared), -- 2606
		repeatedDeterministicTestFailure = (shared.deterministicTestFailureCount or 0) >= 2 -- 2607
	}) -- 2607
	return {{role = "system", content = systemPrompt}, {role = "user", content = (repairPrompt .. "\n\n") .. availabilityPrompt}} -- 2609
end -- 2540
local function replaceFirst(text, oldStr, newStr) -- 2647
	if oldStr == "" then -- 2647
		return text -- 2648
	end -- 2648
	local idx = (string.find(text, oldStr, nil, true) or 0) - 1 -- 2649
	if idx < 0 then -- 2649
		return text -- 2650
	end -- 2650
	return (__TS__StringSubstring(text, 0, idx) .. newStr) .. __TS__StringSubstring(text, idx + #oldStr) -- 2651
end -- 2647
local function splitLines(text) -- 2654
	return __TS__StringSplit(text, "\n") -- 2655
end -- 2654
local function getLeadingWhitespace(text) -- 2658
	local i = 0 -- 2659
	while i < #text do -- 2659
		local ch = __TS__StringAccess(text, i) -- 2661
		if ch ~= " " and ch ~= "\t" then -- 2661
			break -- 2662
		end -- 2662
		i = i + 1 -- 2663
	end -- 2663
	return __TS__StringSubstring(text, 0, i) -- 2665
end -- 2658
local function getCommonIndentPrefix(lines) -- 2668
	local common -- 2669
	do -- 2669
		local i = 0 -- 2670
		while i < #lines do -- 2670
			do -- 2670
				local line = lines[i + 1] -- 2671
				if __TS__StringTrim(line) == "" then -- 2671
					goto __continue449 -- 2672
				end -- 2672
				local indent = getLeadingWhitespace(line) -- 2673
				if common == nil then -- 2673
					common = indent -- 2675
					goto __continue449 -- 2676
				end -- 2676
				local j = 0 -- 2678
				local maxLen = math.min(#common, #indent) -- 2679
				while j < maxLen and __TS__StringAccess(common, j) == __TS__StringAccess(indent, j) do -- 2679
					j = j + 1 -- 2681
				end -- 2681
				common = __TS__StringSubstring(common, 0, j) -- 2683
				if common == "" then -- 2683
					break -- 2684
				end -- 2684
			end -- 2684
			::__continue449:: -- 2684
			i = i + 1 -- 2670
		end -- 2670
	end -- 2670
	return common or "" -- 2686
end -- 2668
local function removeIndentPrefix(line, indent) -- 2689
	if indent ~= "" and __TS__StringStartsWith(line, indent) then -- 2689
		return __TS__StringSubstring(line, #indent) -- 2691
	end -- 2691
	local lineIndent = getLeadingWhitespace(line) -- 2693
	local j = 0 -- 2694
	local maxLen = math.min(#lineIndent, #indent) -- 2695
	while j < maxLen and __TS__StringAccess(lineIndent, j) == __TS__StringAccess(indent, j) do -- 2695
		j = j + 1 -- 2697
	end -- 2697
	return __TS__StringSubstring(line, j) -- 2699
end -- 2689
local function dedentLines(lines) -- 2702
	local indent = getCommonIndentPrefix(lines) -- 2703
	return { -- 2704
		indent = indent, -- 2705
		lines = __TS__ArrayMap( -- 2706
			lines, -- 2706
			function(____, line) return removeIndentPrefix(line, indent) end -- 2706
		) -- 2706
	} -- 2706
end -- 2702
local function joinLines(lines) -- 2710
	return table.concat(lines, "\n") -- 2711
end -- 2710
local function findIndentTolerantReplacement(content, oldStr, newStr) -- 2714
	local function findWhitespaceTolerantReplacement() -- 2719
		local function foldWhitespace(text, withMap) -- 2721
			local parts = {} -- 2722
			local map = {} -- 2723
			local i = 0 -- 2724
			while i < #text do -- 2724
				local ch = __TS__StringAccess(text, i) -- 2726
				if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then -- 2726
					local start = i -- 2728
					while i < #text do -- 2728
						local next = __TS__StringAccess(text, i) -- 2730
						if next ~= " " and next ~= "\t" and next ~= "\n" and next ~= "\r" then -- 2730
							break -- 2731
						end -- 2731
						i = i + 1 -- 2732
					end -- 2732
					parts[#parts + 1] = " " -- 2734
					if withMap then -- 2734
						map[#map + 1] = {char = " ", start = start, ["end"] = i} -- 2735
					end -- 2735
				else -- 2735
					parts[#parts + 1] = ch -- 2737
					if withMap then -- 2737
						map[#map + 1] = {char = ch, start = i, ["end"] = i + 1} -- 2738
					end -- 2738
					i = i + 1 -- 2739
				end -- 2739
			end -- 2739
			return { -- 2742
				text = table.concat(parts, ""), -- 2742
				map = map -- 2742
			} -- 2742
		end -- 2721
		local foldedContent = foldWhitespace(content, true) -- 2744
		local foldedOld = __TS__StringTrim(foldWhitespace(oldStr, false).text) -- 2745
		if foldedOld == "" then -- 2745
			return {success = false, message = "old_str not found in file"} -- 2747
		end -- 2747
		local matches = {} -- 2749
		local pos = 0 -- 2750
		while true do -- 2750
			local idx = (string.find( -- 2752
				foldedContent.text, -- 2752
				foldedOld, -- 2752
				math.max(pos + 1, 1), -- 2752
				true -- 2752
			) or 0) - 1 -- 2752
			if idx < 0 then -- 2752
				break -- 2753
			end -- 2753
			local lastIdx = idx + #foldedOld - 1 -- 2754
			local startMap = foldedContent.map[idx + 1] -- 2755
			local endMap = foldedContent.map[lastIdx + 1] -- 2756
			if startMap ~= nil and endMap ~= nil then -- 2756
				matches[#matches + 1] = {start = startMap.start, ["end"] = endMap["end"]} -- 2758
			end -- 2758
			pos = idx + #foldedOld -- 2760
		end -- 2760
		if #matches == 0 then -- 2760
			return {success = false, message = "old_str not found in file"} -- 2763
		end -- 2763
		if #matches > 1 then -- 2763
			return { -- 2766
				success = false, -- 2767
				message = ("old_str appears " .. tostring(#matches)) .. " times in file after whitespace normalization. Please provide more context to uniquely identify the target location." -- 2768
			} -- 2768
		end -- 2768
		local match = matches[1] -- 2771
		return { -- 2772
			success = true, -- 2773
			content = (__TS__StringSubstring(content, 0, match.start) .. newStr) .. __TS__StringSubstring(content, match["end"]) -- 2774
		} -- 2774
	end -- 2719
	local contentLines = splitLines(content) -- 2777
	local oldLines = splitLines(oldStr) -- 2778
	if #oldLines == 0 then -- 2778
		return {success = false, message = "old_str not found in file"} -- 2780
	end -- 2780
	local dedentedOld = dedentLines(oldLines) -- 2782
	local dedentedOldText = joinLines(dedentedOld.lines) -- 2783
	local dedentedNew = dedentLines(splitLines(newStr)) -- 2784
	local matches = {} -- 2785
	do -- 2785
		local start = 0 -- 2786
		while start <= #contentLines - #oldLines do -- 2786
			local candidateLines = __TS__ArraySlice(contentLines, start, start + #oldLines) -- 2787
			local dedentedCandidate = dedentLines(candidateLines) -- 2788
			if joinLines(dedentedCandidate.lines) == dedentedOldText then -- 2788
				matches[#matches + 1] = {start = start, ["end"] = start + #oldLines, indent = dedentedCandidate.indent} -- 2790
			end -- 2790
			start = start + 1 -- 2786
		end -- 2786
	end -- 2786
	if #matches == 0 then -- 2786
		return findWhitespaceTolerantReplacement() -- 2798
	end -- 2798
	if #matches > 1 then -- 2798
		return { -- 2801
			success = false, -- 2802
			message = ("old_str appears " .. tostring(#matches)) .. " times in file after indentation normalization. Please provide more context to uniquely identify the target location." -- 2803
		} -- 2803
	end -- 2803
	local match = matches[1] -- 2806
	local rebuiltNewLines = __TS__ArrayMap( -- 2807
		dedentedNew.lines, -- 2807
		function(____, line) return line == "" and "" or match.indent .. line end -- 2807
	) -- 2807
	local ____array_75 = __TS__SparseArrayNew(table.unpack(__TS__ArraySlice(contentLines, 0, match.start))) -- 2807
	__TS__SparseArrayPush( -- 2807
		____array_75, -- 2807
		table.unpack(rebuiltNewLines) -- 2810
	) -- 2810
	__TS__SparseArrayPush( -- 2810
		____array_75, -- 2810
		table.unpack(__TS__ArraySlice(contentLines, match["end"])) -- 2811
	) -- 2811
	local nextLines = {__TS__SparseArraySpread(____array_75)} -- 2808
	return { -- 2813
		success = true, -- 2813
		content = joinLines(nextLines) -- 2813
	} -- 2813
end -- 2714
local MainDecisionAgent = __TS__Class() -- 2816
MainDecisionAgent.name = "MainDecisionAgent" -- 2816
__TS__ClassExtends(MainDecisionAgent, Node) -- 2816
function MainDecisionAgent.prototype.prep(self, shared) -- 2817
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2817
		if shared.stopToken.stopped or shared.step >= shared.maxSteps then -- 2817
			return ____awaiter_resolve(nil, {shared = shared}) -- 2817
		end -- 2817
		__TS__Await(maybeCompressHistory(shared)) -- 2822
		return ____awaiter_resolve(nil, {shared = shared}) -- 2822
	end) -- 2822
end -- 2817
function MainDecisionAgent.prototype.commitPreExecutedDecision(self, shared) -- 2827
	local preExecuted = shared.preExecutedResults -- 2828
	if not preExecuted or preExecuted.size == 0 then -- 2828
		return nil -- 2829
	end -- 2829
	local decisions = {} -- 2830
	preExecuted:forEach(function(____, preResult) -- 2831
		local action = preResult.action -- 2832
		decisions[#decisions + 1] = { -- 2833
			success = true, -- 2834
			tool = action.tool, -- 2835
			params = action.params, -- 2836
			toolCallId = action.toolCallId, -- 2837
			reason = action.reason, -- 2838
			reasoningContent = action.reasoningContent -- 2839
		} -- 2839
	end) -- 2831
	if #decisions == 0 then -- 2831
		return nil -- 2842
	end -- 2842
	Log( -- 2843
		"Warn", -- 2843
		"[CodingAgent] committing pre-executed tools after incomplete stream tools=" .. table.concat( -- 2843
			__TS__ArrayMap( -- 2843
				decisions, -- 2843
				function(____, decision) return decision.tool end -- 2843
			), -- 2843
			"," -- 2843
		) -- 2843
	) -- 2843
	if #decisions == 1 then -- 2843
		return decisions[1] -- 2845
	end -- 2845
	return {success = true, kind = "batch", decisions = decisions} -- 2847
end -- 2827
function MainDecisionAgent.prototype.preserveTruncatedEditDecision(self, shared, toolCalls, reasoningContent) -- 2854
	local recovery = Tools.planTruncatedEditRecovery(toolCalls) -- 2859
	if not recovery then -- 2859
		return nil -- 2860
	end -- 2860
	shared.truncatedToolOverwritePath = recovery.target -- 2861
	Log("Warn", "[CodingAgent] preserving truncated whole-file overwrite target=" .. recovery.target) -- 2862
	return { -- 2863
		success = true, -- 2864
		tool = "edit_file", -- 2865
		params = {path = recovery.target, old_str = "", new_str = recovery.receivedText, partialStreamRecovery = true}, -- 2866
		toolCallId = createLocalToolCallId(), -- 2872
		reason = recovery.reason, -- 2873
		reasoningContent = reasoningContent -- 2874
	} -- 2874
end -- 2854
function MainDecisionAgent.prototype.callDecisionByToolCalling(self, shared, lastError, attempt, lastRaw) -- 2878
	if attempt == nil then -- 2878
		attempt = 1 -- 2881
	end -- 2881
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 2881
		if shared.stopToken.stopped then -- 2881
			return ____awaiter_resolve( -- 2881
				nil, -- 2881
				{ -- 2885
					success = false, -- 2885
					message = getCancelledReason(shared) -- 2885
				} -- 2885
			) -- 2885
		end -- 2885
		Log( -- 2887
			"Info", -- 2887
			("[CodingAgent] tool-calling decision start step=" .. tostring(shared.step + 1)) .. (lastError and " retry_error=" .. lastError or "") -- 2887
		) -- 2887
		local tools = AgentToolRegistry.buildDecisionToolSchema( -- 2888
			shared.role, -- 2888
			AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax, -- 2888
			{ -- 2888
				disabledAgentTools = ____exports.getDecisionDisabledAgentTools(shared), -- 2889
				workMode = shared.workMode -- 2890
			} -- 2890
		) -- 2890
		local messages = buildDecisionMessages(shared, lastError, attempt, lastRaw) -- 2892
		local stepId = shared.step + 1 -- 2893
		local useFastGlmToolDecision = __TS__StringIncludes( -- 2894
			string.lower(shared.llmConfig.model), -- 2894
			"glm-5.2" -- 2894
		) and (type(shared.llmOptions.reasoning_effort) ~= "string" or __TS__StringTrim(shared.llmOptions.reasoning_effort) == "") -- 2894
		local llmOptions = __TS__ObjectAssign({}, shared.llmOptions, useFastGlmToolDecision and ({reasoning_effort = "minimal"}) or ({}), {tools = tools}) -- 2897
		emitLLMContextMetrics( -- 2902
			shared, -- 2902
			stepId, -- 2902
			"decision_tool_calling", -- 2902
			messages, -- 2902
			llmOptions -- 2902
		) -- 2902
		saveStepLLMDebugInput( -- 2903
			shared, -- 2903
			stepId, -- 2903
			"decision_tool_calling", -- 2903
			messages, -- 2903
			llmOptions -- 2903
		) -- 2903
		local lastStreamContent = "" -- 2904
		local lastStreamReasoning = "" -- 2905
		local preExecutedResults = __TS__New(Map) -- 2906
		shared.preExecutedResults = preExecutedResults -- 2907
		local res = __TS__Await(callLLMStreamAggregated( -- 2908
			messages, -- 2909
			llmOptions, -- 2910
			shared.stopToken, -- 2911
			shared.llmConfig, -- 2912
			function(response) -- 2913
				local ____opt_78 = response.choices -- 2913
				local ____opt_76 = ____opt_78 and ____opt_78[1] -- 2913
				local streamMessage = ____opt_76 and ____opt_76.message -- 2914
				local nextContent = type(streamMessage and streamMessage.content) == "string" and sanitizeUTF8(streamMessage.content) or "" -- 2915
				local nextReasoning = type(streamMessage and streamMessage.reasoning_content) == "string" and sanitizeUTF8(streamMessage.reasoning_content) or "" -- 2918
				if nextContent == lastStreamContent and nextReasoning == lastStreamReasoning then -- 2918
					return -- 2922
				end -- 2922
				lastStreamContent = nextContent -- 2924
				lastStreamReasoning = nextReasoning -- 2925
				emitAssistantMessageUpdated(shared, nextContent, nextReasoning ~= "" and nextReasoning or nil) -- 2926
			end, -- 2913
			function(tc) -- 2928
				if shared.stopToken.stopped then -- 2928
					return -- 2929
				end -- 2929
				local action = createPreExecutableActionFromStream(shared, tc) -- 2930
				if not action or preExecutedResults:has(action.toolCallId) then -- 2930
					return -- 2931
				end -- 2931
				Log("Info", (("[CodingAgent] streaming pre-exec tool=" .. action.tool) .. " id=") .. action.toolCallId) -- 2932
				preExecutedResults:set( -- 2933
					action.toolCallId, -- 2933
					createPreExecutedToolResult(shared, action) -- 2933
				) -- 2933
			end -- 2928
		)) -- 2928
		if shared.stopToken.stopped then -- 2928
			clearPreExecutedResults(shared) -- 2937
			return ____awaiter_resolve( -- 2937
				nil, -- 2937
				{ -- 2938
					success = false, -- 2938
					message = getCancelledReason(shared) -- 2938
				} -- 2938
			) -- 2938
		end -- 2938
		if not res.success then -- 2938
			local usage = res.tokenUsage -- 2941
			recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2942
			saveStepLLMDebugOutput( -- 2943
				shared, -- 2943
				stepId, -- 2943
				"decision_tool_calling", -- 2943
				res.raw or res.message, -- 2943
				{success = false, usage = usage} -- 2943
			) -- 2943
			Log("Error", "[CodingAgent] tool-calling request failed: " .. res.message) -- 2944
			local committed = self:commitPreExecutedDecision(shared) -- 2945
			if committed then -- 2945
				return ____awaiter_resolve(nil, committed) -- 2945
			end -- 2945
			local ____opt_86 = res.response -- 2945
			local ____opt_84 = ____opt_86 and ____opt_86.choices -- 2945
			local partialChoice = ____opt_84 and ____opt_84[1] -- 2947
			local ____self_preserveTruncatedEditDecision_98 = self.preserveTruncatedEditDecision -- 2948
			local ____shared_96 = shared -- 2949
			local ____opt_88 = partialChoice and partialChoice.message -- 2949
			local ____temp_97 = ____opt_88 and ____opt_88.tool_calls -- 2950
			local ____opt_92 = partialChoice and partialChoice.message -- 2950
			local partialDraft = ____self_preserveTruncatedEditDecision_98(self, ____shared_96, ____temp_97, ____opt_92 and ____opt_92.reasoning_content) -- 2948
			if partialDraft then -- 2948
				return ____awaiter_resolve(nil, partialDraft) -- 2948
			end -- 2948
			clearPreExecutedResults(shared) -- 2954
			return ____awaiter_resolve(nil, {success = false, message = res.message, raw = res.raw}) -- 2954
		end -- 2954
		local usage = res.tokenUsage -- 2957
		recordLLMTokenUsage(shared, stepId, "decision_tool_calling", usage) -- 2958
		saveStepLLMDebugOutput( -- 2959
			shared, -- 2959
			stepId, -- 2959
			"decision_tool_calling", -- 2959
			encodeDebugJSON(res.response), -- 2959
			{success = true, usage = usage} -- 2959
		) -- 2959
		local choice = res.response.choices and res.response.choices[1] -- 2960
		local message = choice and choice.message -- 2961
		local toolCalls = message and message.tool_calls -- 2962
		local finishReason = choice and type(choice.finish_reason) == "string" and choice.finish_reason or "" -- 2963
		local reasoningContent = message and type(message.reasoning_content) == "string" and message.reasoning_content or nil -- 2966
		local messageContent = message and type(message.content) == "string" and __TS__StringTrim(message.content) or nil -- 2969
		Log( -- 2972
			"Info", -- 2972
			(((((("[CodingAgent] tool-calling response finish_reason=" .. (finishReason ~= "" and finishReason or "unknown")) .. " tool_calls=") .. tostring(toolCalls and #toolCalls or 0)) .. " content_len=") .. tostring(messageContent and #messageContent or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2972
		) -- 2972
		if finishReason == "length" then -- 2972
			local committed = self:commitPreExecutedDecision(shared) -- 2974
			if committed then -- 2974
				return ____awaiter_resolve(nil, committed) -- 2974
			end -- 2974
			local partialDraft = self:preserveTruncatedEditDecision(shared, toolCalls, reasoningContent) -- 2976
			if partialDraft then -- 2976
				return ____awaiter_resolve(nil, partialDraft) -- 2976
			end -- 2976
			Log( -- 2978
				"Error", -- 2978
				(("[CodingAgent] no complete or recoverable tool call in truncated output tool_calls=" .. tostring(toolCalls and #toolCalls or 0)) .. " reasoning_len=") .. tostring(reasoningContent and #reasoningContent or 0) -- 2978
			) -- 2978
			clearPreExecutedResults(shared) -- 2979
			return ____awaiter_resolve(nil, {success = false, message = "tool-calling output was truncated by max tokens and no safe recovery was available. A truncated edit with non-empty old_str is rejected and its target is unchanged. Do not repeat the same payload. Retry immediately with one complete tool call using bounded arguments and minimal reasoning.", raw = reasoningContent or messageContent or ""}) -- 2979
		end -- 2979
		if not toolCalls or #toolCalls == 0 then -- 2979
			if messageContent and messageContent ~= "" then -- 2979
				if isFinalDecisionTurn(shared) then -- 2979
					clearPreExecutedResults(shared) -- 2989
					return ____awaiter_resolve(nil, {success = false, message = "the final task turn requires a structured finish call; use completed only with full evidence, otherwise use partial with validation, knownIssues, and a next action in message", raw = messageContent}) -- 2989
				end -- 2989
				if shared.role == "sub" then -- 2989
					Log("Warn", "[CodingAgent] sub-agent returned plain text instead of structured finish") -- 2997
					clearPreExecutedResults(shared) -- 2998
					return ____awaiter_resolve(nil, {success = false, message = "sub agents must call finish with outcome, validation, knownIssues, assumptions, and learningCandidates; plain-text completion is not accepted", raw = messageContent}) -- 2998
				end -- 2998
				Log( -- 3005
					"Info", -- 3005
					"[CodingAgent] tool-calling fallback direct_finish_len=" .. tostring(#messageContent) -- 3005
				) -- 3005
				clearPreExecutedResults(shared) -- 3006
				return ____awaiter_resolve(nil, { -- 3006
					success = true, -- 3008
					tool = "finish", -- 3009
					params = {}, -- 3010
					reason = messageContent, -- 3011
					reasoningContent = reasoningContent, -- 3012
					directSummary = messageContent -- 3013
				}) -- 3013
			end -- 3013
			Log("Error", "[CodingAgent] missing tool call and plain-text fallback") -- 3016
			clearPreExecutedResults(shared) -- 3017
			return ____awaiter_resolve(nil, {success = false, message = "missing tool call", raw = reasoningContent or messageContent or ""}) -- 3017
		end -- 3017
		local decisions = {} -- 3024
		do -- 3024
			local i = 0 -- 3025
			while i < #toolCalls do -- 3025
				local toolCall = toolCalls[i + 1] -- 3026
				local fn = toolCall ~= nil and toolCall["function"] -- 3027
				if not fn or type(fn.name) ~= "string" or fn.name == "" then -- 3027
					Log( -- 3029
						"Error", -- 3029
						"[CodingAgent] missing function name for tool call index=" .. tostring(i + 1) -- 3029
					) -- 3029
					clearPreExecutedResults(shared) -- 3030
					return ____awaiter_resolve( -- 3030
						nil, -- 3030
						{ -- 3031
							success = false, -- 3032
							message = "missing function name for tool call " .. tostring(i + 1), -- 3033
							raw = messageContent -- 3034
						} -- 3034
					) -- 3034
				end -- 3034
				local functionName = fn.name -- 3037
				local argsText = type(fn.arguments) == "string" and fn.arguments or "" -- 3038
				local toolCallId = toolCall ~= nil and type(toolCall.id) == "string" and toolCall.id or nil -- 3039
				Log( -- 3042
					"Info", -- 3042
					(((((("[CodingAgent] tool-calling function=" .. functionName) .. " index=") .. tostring(i + 1)) .. "/") .. tostring(#toolCalls)) .. " args_len=") .. tostring(#argsText) -- 3042
				) -- 3042
				local decision = parseAndValidateToolCallDecision( -- 3043
					shared, -- 3044
					functionName, -- 3045
					argsText, -- 3046
					toolCallId, -- 3047
					messageContent, -- 3048
					reasoningContent -- 3049
				) -- 3049
				if not decision.success then -- 3049
					Log( -- 3052
						"Error", -- 3052
						(("[CodingAgent] invalid tool call index=" .. tostring(i + 1)) .. ": ") .. decision.message -- 3052
					) -- 3052
					clearPreExecutedResults(shared) -- 3053
					return ____awaiter_resolve(nil, decision) -- 3053
				end -- 3053
				decisions[#decisions + 1] = decision -- 3056
				i = i + 1 -- 3025
			end -- 3025
		end -- 3025
		if #decisions == 1 then -- 3025
			Log("Info", "[CodingAgent] tool-calling selected tool=" .. decisions[1].tool) -- 3059
			return ____awaiter_resolve(nil, decisions[1]) -- 3059
		end -- 3059
		do -- 3059
			local i = 0 -- 3062
			while i < #decisions do -- 3062
				if decisions[i + 1].tool == "finish" or decisions[i + 1].tool == "ask_user" then -- 3062
					clearPreExecutedResults(shared) -- 3064
					return ____awaiter_resolve(nil, {success = false, message = decisions[i + 1].tool .. " cannot be mixed with other tool calls", raw = messageContent}) -- 3064
				end -- 3064
				i = i + 1 -- 3062
			end -- 3062
		end -- 3062
		Log( -- 3072
			"Info", -- 3072
			"[CodingAgent] tool-calling selected batch tools=" .. table.concat( -- 3072
				__TS__ArrayMap( -- 3072
					decisions, -- 3072
					function(____, decision) return decision.tool end -- 3072
				), -- 3072
				"," -- 3072
			) -- 3072
		) -- 3072
		return ____awaiter_resolve(nil, { -- 3072
			success = true, -- 3074
			kind = "batch", -- 3075
			decisions = decisions, -- 3076
			content = messageContent, -- 3077
			reasoningContent = reasoningContent -- 3078
		}) -- 3078
	end) -- 3078
end -- 2878
function MainDecisionAgent.prototype.repairDecisionXml(self, shared, originalRaw, originalReasoning, initialError) -- 3082
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3082
		Log( -- 3088
			"Info", -- 3088
			(("[CodingAgent] xml repair flow start step=" .. tostring(shared.step + 1)) .. " error=") .. initialError -- 3088
		) -- 3088
		local lastError = initialError -- 3089
		local candidateRaw = "" -- 3090
		local candidateReasoning = nil -- 3091
		do -- 3091
			local attempt = 0 -- 3092
			while attempt < shared.llmMaxTry do -- 3092
				do -- 3092
					Log( -- 3093
						"Info", -- 3093
						"[CodingAgent] xml repair attempt=" .. tostring(attempt + 1) -- 3093
					) -- 3093
					local messages = buildXmlRepairMessages( -- 3094
						shared, -- 3095
						originalRaw, -- 3096
						originalReasoning, -- 3097
						candidateRaw, -- 3098
						candidateReasoning, -- 3099
						lastError, -- 3100
						attempt + 1 -- 3101
					) -- 3101
					local llmRes = __TS__Await(llm(shared, messages, "decision_xml_repair")) -- 3103
					if shared.stopToken.stopped then -- 3103
						return ____awaiter_resolve( -- 3103
							nil, -- 3103
							{ -- 3105
								success = false, -- 3105
								message = getCancelledReason(shared) -- 3105
							} -- 3105
						) -- 3105
					end -- 3105
					if not llmRes.success then -- 3105
						lastError = llmRes.message -- 3108
						Log("Error", "[CodingAgent] xml repair attempt failed: " .. lastError) -- 3109
						goto __continue522 -- 3110
					end -- 3110
					candidateRaw = llmRes.text -- 3112
					candidateReasoning = llmRes.reasoningContent -- 3113
					local decision = tryParseAndValidateDecision(candidateRaw, shared) -- 3114
					if decision.success then -- 3114
						decision.reasoningContent = llmRes.reasoningContent -- 3116
						Log("Info", "[CodingAgent] xml repair succeeded tool=" .. decision.tool) -- 3117
						return ____awaiter_resolve(nil, decision) -- 3117
					end -- 3117
					lastError = decision.message -- 3120
					Log("Error", "[CodingAgent] xml repair candidate invalid: " .. lastError) -- 3121
				end -- 3121
				::__continue522:: -- 3121
				attempt = attempt + 1 -- 3092
			end -- 3092
		end -- 3092
		Log("Error", "[CodingAgent] xml repair exhausted retries: " .. lastError) -- 3123
		return ____awaiter_resolve(nil, {success = false, message = "cannot repair invalid decision xml: " .. lastError, raw = candidateRaw}) -- 3123
	end) -- 3123
end -- 3082
function MainDecisionAgent.prototype.callDecisionByXml(self, shared, lastError, attempt, lastRaw) -- 3131
	if attempt == nil then -- 3131
		attempt = 1 -- 3134
	end -- 3134
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3134
		local messages = buildDecisionMessages( -- 3137
			shared, -- 3138
			lastError, -- 3139
			attempt, -- 3140
			lastRaw, -- 3141
			"xml" -- 3142
		) -- 3142
		local llmRes = __TS__Await(llm(shared, messages, "decision_xml")) -- 3144
		if shared.stopToken.stopped then -- 3144
			return ____awaiter_resolve( -- 3144
				nil, -- 3144
				{ -- 3146
					success = false, -- 3146
					message = getCancelledReason(shared) -- 3146
				} -- 3146
			) -- 3146
		end -- 3146
		if not llmRes.success then -- 3146
			return ____awaiter_resolve(nil, {success = false, message = llmRes.message, raw = llmRes.text or ""}) -- 3146
		end -- 3146
		local decision = tryParseAndValidateDecision(llmRes.text, shared) -- 3155
		if decision.success then -- 3155
			decision.reasoningContent = llmRes.reasoningContent -- 3157
			return ____awaiter_resolve(nil, decision) -- 3157
		end -- 3157
		return ____awaiter_resolve( -- 3157
			nil, -- 3157
			self:repairDecisionXml(shared, llmRes.text, llmRes.reasoningContent, decision.message) -- 3160
		) -- 3160
	end) -- 3160
end -- 3131
function MainDecisionAgent.prototype.exec(self, input) -- 3163
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3163
		local shared = input.shared -- 3164
		if shared.stopToken.stopped then -- 3164
			return ____awaiter_resolve( -- 3164
				nil, -- 3164
				{ -- 3166
					success = false, -- 3166
					message = getCancelledReason(shared) -- 3166
				} -- 3166
			) -- 3166
		end -- 3166
		if shared.step >= shared.maxSteps then -- 3166
			Log( -- 3169
				"Warn", -- 3169
				(("[CodingAgent] maximum step limit reached step=" .. tostring(shared.step)) .. " max=") .. tostring(shared.maxSteps) -- 3169
			) -- 3169
			return ____awaiter_resolve( -- 3169
				nil, -- 3169
				{ -- 3170
					success = false, -- 3170
					message = getMaxStepsReachedReason(shared) -- 3170
				} -- 3170
			) -- 3170
		end -- 3170
		if shared.decisionMode == "tool_calling" then -- 3170
			Log( -- 3174
				"Info", -- 3174
				(("[CodingAgent] decision mode=tool_calling step=" .. tostring(shared.step + 1)) .. " messages=") .. tostring(#getUnconsolidatedMessages(shared)) -- 3174
			) -- 3174
			local lastError = "tool calling validation failed" -- 3175
			local lastRaw = "" -- 3176
			local shouldFallbackToXml = false -- 3177
			do -- 3177
				local attempt = 0 -- 3178
				while attempt < shared.llmMaxTry do -- 3178
					Log( -- 3179
						"Info", -- 3179
						"[CodingAgent] tool-calling attempt=" .. tostring(attempt + 1) -- 3179
					) -- 3179
					local decision = __TS__Await(self:callDecisionByToolCalling(shared, attempt > 0 and lastError or nil, attempt + 1, lastRaw)) -- 3180
					if shared.stopToken.stopped then -- 3180
						return ____awaiter_resolve( -- 3180
							nil, -- 3180
							{ -- 3187
								success = false, -- 3187
								message = getCancelledReason(shared) -- 3187
							} -- 3187
						) -- 3187
					end -- 3187
					if decision.success then -- 3187
						return ____awaiter_resolve(nil, decision) -- 3187
					end -- 3187
					lastError = decision.message -- 3192
					lastRaw = decision.raw or "" -- 3193
					Log("Error", "[CodingAgent] tool-calling attempt failed: " .. lastError) -- 3194
					if lastError == "missing tool call" then -- 3194
						shouldFallbackToXml = true -- 3196
						break -- 3197
					end -- 3197
					attempt = attempt + 1 -- 3178
				end -- 3178
			end -- 3178
			if shouldFallbackToXml then -- 3178
				Log("Warn", "[CodingAgent] tool-calling returned no tool calls; falling back to XML decision format") -- 3201
				lastError = "tool-calling returned no tool calls. Return exactly one valid XML tool_call block." -- 3202
				do -- 3202
					local attempt = 0 -- 3203
					while attempt < shared.llmMaxTry do -- 3203
						Log( -- 3204
							"Info", -- 3204
							"[CodingAgent] xml fallback attempt=" .. tostring(attempt + 1) -- 3204
						) -- 3204
						local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and lastError or "tool-calling returned no tool calls. Use XML decision format instead.", attempt + 1, lastRaw)) -- 3205
						if shared.stopToken.stopped then -- 3205
							return ____awaiter_resolve( -- 3205
								nil, -- 3205
								{ -- 3212
									success = false, -- 3212
									message = getCancelledReason(shared) -- 3212
								} -- 3212
							) -- 3212
						end -- 3212
						if decision.success then -- 3212
							return ____awaiter_resolve(nil, decision) -- 3212
						end -- 3212
						lastError = decision.message -- 3217
						lastRaw = decision.raw or "" -- 3218
						Log("Error", "[CodingAgent] xml fallback attempt failed: " .. lastError) -- 3219
						attempt = attempt + 1 -- 3203
					end -- 3203
				end -- 3203
				Log("Error", "[CodingAgent] xml fallback exhausted retries: " .. lastError) -- 3221
				return ____awaiter_resolve( -- 3221
					nil, -- 3221
					{ -- 3222
						success = false, -- 3222
						message = (("cannot produce valid XML decision after tool-calling fallback: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3222
					} -- 3222
				) -- 3222
			end -- 3222
			Log("Error", "[CodingAgent] tool-calling exhausted retries: " .. lastError) -- 3224
			return ____awaiter_resolve( -- 3224
				nil, -- 3224
				{ -- 3225
					success = false, -- 3225
					message = (("cannot produce valid tool call: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3225
				} -- 3225
			) -- 3225
		end -- 3225
		local lastError = "xml validation failed" -- 3228
		local lastRaw = "" -- 3229
		do -- 3229
			local attempt = 0 -- 3230
			while attempt < shared.llmMaxTry do -- 3230
				local decision = __TS__Await(self:callDecisionByXml(shared, attempt > 0 and ("Previous request failed before producing repairable output (" .. lastError) .. ")." or nil, attempt + 1, lastRaw)) -- 3231
				if shared.stopToken.stopped then -- 3231
					return ____awaiter_resolve( -- 3231
						nil, -- 3231
						{ -- 3240
							success = false, -- 3240
							message = getCancelledReason(shared) -- 3240
						} -- 3240
					) -- 3240
				end -- 3240
				if decision.success then -- 3240
					return ____awaiter_resolve(nil, decision) -- 3240
				end -- 3240
				lastError = decision.message -- 3245
				lastRaw = decision.raw or "" -- 3246
				attempt = attempt + 1 -- 3230
			end -- 3230
		end -- 3230
		return ____awaiter_resolve( -- 3230
			nil, -- 3230
			{ -- 3248
				success = false, -- 3248
				message = (("cannot produce valid decision xml: " .. lastError) .. "; last_output=") .. truncateText(lastRaw, 400) -- 3248
			} -- 3248
		) -- 3248
	end) -- 3248
end -- 3163
function MainDecisionAgent.prototype.post(self, shared, _prepRes, execRes) -- 3251
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3251
		local result = execRes -- 3252
		if not result.success then -- 3252
			if shared.stopToken.stopped then -- 3252
				shared.error = getCancelledReason(shared) -- 3255
				shared.done = true -- 3256
				return ____awaiter_resolve(nil, "done") -- 3256
			end -- 3256
			shared.error = result.message -- 3259
			shared.response = getFailureSummaryFallback(shared, result.message) -- 3260
			shared.done = true -- 3261
			appendConversationMessage(shared, {role = "assistant", content = shared.response}) -- 3262
			persistHistoryState(shared) -- 3266
			return ____awaiter_resolve(nil, "done") -- 3266
		end -- 3266
		if isDecisionBatchSuccess(result) then -- 3266
			local startStep = shared.step -- 3270
			local actions = {} -- 3271
			do -- 3271
				local i = 0 -- 3272
				while i < #result.decisions do -- 3272
					local decision = result.decisions[i + 1] -- 3273
					local toolCallId = ensureToolCallId(decision.toolCallId) -- 3274
					local step = startStep + i + 1 -- 3275
					local ____temp_99 -- 3276
					if i == 0 then -- 3276
						____temp_99 = decision.reason -- 3276
					else -- 3276
						____temp_99 = "" -- 3276
					end -- 3276
					local actionReason = ____temp_99 -- 3276
					local ____temp_100 -- 3277
					if i == 0 then -- 3277
						____temp_100 = decision.reasoningContent -- 3277
					else -- 3277
						____temp_100 = nil -- 3277
					end -- 3277
					local actionReasoningContent = ____temp_100 -- 3277
					emitAgentEvent(shared, { -- 3278
						type = "decision_made", -- 3279
						sessionId = shared.sessionId, -- 3280
						taskId = shared.taskId, -- 3281
						step = step, -- 3282
						tool = decision.tool, -- 3283
						reason = actionReason, -- 3284
						reasoningContent = actionReasoningContent, -- 3285
						params = decision.params -- 3286
					}) -- 3286
					local action = { -- 3288
						step = step, -- 3289
						toolCallId = toolCallId, -- 3290
						tool = decision.tool, -- 3291
						reason = actionReason or "", -- 3292
						reasoningContent = actionReasoningContent, -- 3293
						params = decision.params, -- 3294
						timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3295
					} -- 3295
					local ____shared_history_101 = shared.history -- 3295
					____shared_history_101[#____shared_history_101 + 1] = action -- 3297
					actions[#actions + 1] = action -- 3298
					i = i + 1 -- 3272
				end -- 3272
			end -- 3272
			shared.step = startStep + #actions -- 3300
			shared.pendingToolActions = actions -- 3301
			appendAssistantToolCallsMessage(shared, actions, result.content or "", result.reasoningContent) -- 3302
			persistHistoryState(shared) -- 3308
			return ____awaiter_resolve(nil, "batch_tools") -- 3308
		end -- 3308
		if result.directSummary and result.directSummary ~= "" then -- 3308
			shared.response = result.directSummary -- 3312
			shared.completion = ____exports.normalizeAgentCompletionReport(shared.role == "sub" and ({outcome = "partial", knownIssues = {"Sub agent returned a plain-text finish without structured completion metadata."}}) or ({})) -- 3313
			shared.done = true -- 3317
			appendConversationMessage(shared, {role = "assistant", content = result.directSummary, reasoning_content = result.reasoningContent}) -- 3318
			persistHistoryState(shared) -- 3323
			return ____awaiter_resolve(nil, "done") -- 3323
		end -- 3323
		if result.tool == "finish" then -- 3323
			local finalMessage = getFinishMessage(result.params, result.reason or "") -- 3327
			shared.response = finalMessage -- 3328
			shared.completion = getCompletionReport(result.params) -- 3329
			shared.done = true -- 3330
			appendConversationMessage(shared, {role = "assistant", content = finalMessage, reasoning_content = result.reasoningContent}) -- 3331
			persistHistoryState(shared) -- 3336
			return ____awaiter_resolve(nil, "done") -- 3336
		end -- 3336
		local toolCallId = ensureToolCallId(result.toolCallId) -- 3339
		shared.step = shared.step + 1 -- 3340
		local step = shared.step -- 3341
		emitAgentEvent(shared, { -- 3342
			type = "decision_made", -- 3343
			sessionId = shared.sessionId, -- 3344
			taskId = shared.taskId, -- 3345
			step = step, -- 3346
			tool = result.tool, -- 3347
			reason = result.reason, -- 3348
			reasoningContent = result.reasoningContent, -- 3349
			params = result.params -- 3350
		}) -- 3350
		local ____shared_history_102 = shared.history -- 3350
		____shared_history_102[#____shared_history_102 + 1] = { -- 3352
			step = step, -- 3353
			toolCallId = toolCallId, -- 3354
			tool = result.tool, -- 3355
			reason = result.reason or "", -- 3356
			reasoningContent = result.reasoningContent, -- 3357
			params = result.params, -- 3358
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") -- 3359
		} -- 3359
		local action = shared.history[#shared.history] -- 3361
		appendAssistantToolCallsMessage(shared, {action}, result.reason or "", result.reasoningContent) -- 3362
		shared.pendingToolActions = {action} -- 3365
		persistHistoryState(shared) -- 3366
		return ____awaiter_resolve(nil, "batch_tools") -- 3366
	end) -- 3366
end -- 3251
local ReadFileAction = __TS__Class() -- 3371
ReadFileAction.name = "ReadFileAction" -- 3371
__TS__ClassExtends(ReadFileAction, Node) -- 3371
function ReadFileAction.prototype.prep(self, shared) -- 3372
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3372
		local last = shared.history[#shared.history] -- 3373
		if not last then -- 3373
			error( -- 3374
				__TS__New(Error, "no history"), -- 3374
				0 -- 3374
			) -- 3374
		end -- 3374
		emitAgentStartEvent(shared, last) -- 3375
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3376
		if __TS__StringTrim(path) == "" then -- 3376
			error( -- 3379
				__TS__New(Error, "missing path"), -- 3379
				0 -- 3379
			) -- 3379
		end -- 3379
		local ____path_105 = path -- 3381
		local ____shared_workingDir_106 = shared.workingDir -- 3383
		local ____temp_107 = shared.useChineseResponse and "zh" or "en" -- 3384
		local ____last_params_startLine_103 = last.params.startLine -- 3385
		if ____last_params_startLine_103 == nil then -- 3385
			____last_params_startLine_103 = 1 -- 3385
		end -- 3385
		local ____TS__Number_result_108 = __TS__Number(____last_params_startLine_103) -- 3385
		local ____last_params_endLine_104 = last.params.endLine -- 3386
		if ____last_params_endLine_104 == nil then -- 3386
			____last_params_endLine_104 = AgentConfig.AGENT_LIMITS.readFileDefaultLimit -- 3386
		end -- 3386
		return ____awaiter_resolve( -- 3386
			nil, -- 3386
			{ -- 3380
				path = ____path_105, -- 3381
				tool = "read_file", -- 3382
				workDir = ____shared_workingDir_106, -- 3383
				docLanguage = ____temp_107, -- 3384
				startLine = ____TS__Number_result_108, -- 3385
				endLine = __TS__Number(____last_params_endLine_104) -- 3386
			} -- 3386
		) -- 3386
	end) -- 3386
end -- 3372
function ReadFileAction.prototype.exec(self, input) -- 3390
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3390
		return ____awaiter_resolve( -- 3390
			nil, -- 3390
			Tools.readFile( -- 3391
				input.workDir, -- 3392
				input.path, -- 3393
				__TS__Number(input.startLine or 1), -- 3394
				__TS__Number(input.endLine or AgentConfig.AGENT_LIMITS.readFileDefaultLimit), -- 3395
				input.docLanguage -- 3396
			) -- 3396
		) -- 3396
	end) -- 3396
end -- 3390
function ReadFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3400
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3400
		local result = execRes -- 3401
		local last = shared.history[#shared.history] -- 3402
		if last ~= nil then -- 3402
			last.result = sanitizeReadResultForHistory(last.tool, result) -- 3404
			appendToolResultMessage(shared, last) -- 3405
			emitAgentFinishEvent(shared, last) -- 3406
		end -- 3406
		persistHistoryState(shared) -- 3408
		__TS__Await(maybeCompressHistory(shared)) -- 3409
		persistHistoryState(shared) -- 3410
		return ____awaiter_resolve(nil, "main") -- 3410
	end) -- 3410
end -- 3400
local SearchFilesAction = __TS__Class() -- 3415
SearchFilesAction.name = "SearchFilesAction" -- 3415
__TS__ClassExtends(SearchFilesAction, Node) -- 3415
function SearchFilesAction.prototype.prep(self, shared) -- 3416
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3416
		local last = shared.history[#shared.history] -- 3417
		if not last then -- 3417
			error( -- 3418
				__TS__New(Error, "no history"), -- 3418
				0 -- 3418
			) -- 3418
		end -- 3418
		emitAgentStartEvent(shared, last) -- 3419
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3419
	end) -- 3419
end -- 3416
function SearchFilesAction.prototype.exec(self, input) -- 3423
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3423
		local params = input.params -- 3424
		local ____Tools_searchFiles_123 = Tools.searchFiles -- 3425
		local ____input_workDir_115 = input.workDir -- 3426
		local ____temp_116 = params.path or "" -- 3427
		local ____temp_117 = params.pattern or "" -- 3428
		local ____params_globs_118 = params.globs -- 3429
		local ____params_useRegex_119 = params.useRegex -- 3430
		local ____params_caseSensitive_120 = params.caseSensitive -- 3431
		local ____AgentConfig_AGENT_LIMITS_searchPreviewContext_121 = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3433
		local ____math_max_111 = math.max -- 3434
		local ____math_floor_110 = math.floor -- 3434
		local ____params_limit_109 = params.limit -- 3434
		if ____params_limit_109 == nil then -- 3434
			____params_limit_109 = AgentConfig.AGENT_LIMITS.searchFilesLimitDefault -- 3434
		end -- 3434
		local ____math_max_111_result_122 = ____math_max_111( -- 3434
			1, -- 3434
			____math_floor_110(__TS__Number(____params_limit_109)) -- 3434
		) -- 3434
		local ____math_max_114 = math.max -- 3435
		local ____math_floor_113 = math.floor -- 3435
		local ____params_offset_112 = params.offset -- 3435
		if ____params_offset_112 == nil then -- 3435
			____params_offset_112 = 0 -- 3435
		end -- 3435
		local result = __TS__Await(____Tools_searchFiles_123({ -- 3425
			workDir = ____input_workDir_115, -- 3426
			path = ____temp_116, -- 3427
			pattern = ____temp_117, -- 3428
			globs = ____params_globs_118, -- 3429
			useRegex = ____params_useRegex_119, -- 3430
			caseSensitive = ____params_caseSensitive_120, -- 3431
			includeContent = true, -- 3432
			contentWindow = ____AgentConfig_AGENT_LIMITS_searchPreviewContext_121, -- 3433
			limit = ____math_max_111_result_122, -- 3434
			offset = ____math_max_114( -- 3435
				0, -- 3435
				____math_floor_113(__TS__Number(____params_offset_112)) -- 3435
			), -- 3435
			groupByFile = params.groupByFile == true -- 3436
		})) -- 3436
		return ____awaiter_resolve(nil, result) -- 3436
	end) -- 3436
end -- 3423
function SearchFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3441
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3441
		local last = shared.history[#shared.history] -- 3442
		if last ~= nil then -- 3442
			local result = execRes -- 3444
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3445
			appendToolResultMessage(shared, last) -- 3446
			emitAgentFinishEvent(shared, last) -- 3447
		end -- 3447
		persistHistoryState(shared) -- 3449
		__TS__Await(maybeCompressHistory(shared)) -- 3450
		persistHistoryState(shared) -- 3451
		return ____awaiter_resolve(nil, "main") -- 3451
	end) -- 3451
end -- 3441
local SearchDoraAPIAction = __TS__Class() -- 3456
SearchDoraAPIAction.name = "SearchDoraAPIAction" -- 3456
__TS__ClassExtends(SearchDoraAPIAction, Node) -- 3456
function SearchDoraAPIAction.prototype.prep(self, shared) -- 3457
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3457
		local last = shared.history[#shared.history] -- 3458
		if not last then -- 3458
			error( -- 3459
				__TS__New(Error, "no history"), -- 3459
				0 -- 3459
			) -- 3459
		end -- 3459
		emitAgentStartEvent(shared, last) -- 3460
		return ____awaiter_resolve(nil, {params = last.params, useChineseResponse = shared.useChineseResponse}) -- 3460
	end) -- 3460
end -- 3457
function SearchDoraAPIAction.prototype.exec(self, input) -- 3464
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3464
		local params = input.params -- 3465
		local ____Tools_searchDoraAPI_132 = Tools.searchDoraAPI -- 3466
		local ____temp_128 = params.pattern or "" -- 3467
		local ____temp_129 = params.docSource or "api" -- 3468
		local ____temp_130 = input.useChineseResponse and "zh" or "en" -- 3469
		local ____temp_131 = params.programmingLanguage or "ts" -- 3470
		local ____math_min_127 = math.min -- 3471
		local ____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_126 = AgentConfig.AGENT_LIMITS.searchDoraApiLimitMax -- 3471
		local ____math_max_125 = math.max -- 3471
		local ____params_limit_124 = params.limit -- 3471
		if ____params_limit_124 == nil then -- 3471
			____params_limit_124 = 8 -- 3471
		end -- 3471
		local result = __TS__Await(____Tools_searchDoraAPI_132({ -- 3466
			pattern = ____temp_128, -- 3467
			docSource = ____temp_129, -- 3468
			docLanguage = ____temp_130, -- 3469
			programmingLanguage = ____temp_131, -- 3470
			limit = ____math_min_127( -- 3471
				____AgentConfig_AGENT_LIMITS_searchDoraApiLimitMax_126, -- 3471
				____math_max_125( -- 3471
					1, -- 3471
					__TS__Number(____params_limit_124) -- 3471
				) -- 3471
			), -- 3471
			useRegex = params.useRegex, -- 3472
			caseSensitive = false, -- 3473
			includeContent = true, -- 3474
			contentWindow = AgentConfig.AGENT_LIMITS.searchPreviewContext -- 3475
		})) -- 3475
		return ____awaiter_resolve(nil, result) -- 3475
	end) -- 3475
end -- 3464
function SearchDoraAPIAction.prototype.post(self, shared, _prepRes, execRes) -- 3480
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3480
		local last = shared.history[#shared.history] -- 3481
		if last ~= nil then -- 3481
			local result = execRes -- 3483
			last.result = sanitizeSearchResultForHistory(last.tool, result) -- 3484
			appendToolResultMessage(shared, last) -- 3485
			emitAgentFinishEvent(shared, last) -- 3486
		end -- 3486
		persistHistoryState(shared) -- 3488
		__TS__Await(maybeCompressHistory(shared)) -- 3489
		persistHistoryState(shared) -- 3490
		return ____awaiter_resolve(nil, "main") -- 3490
	end) -- 3490
end -- 3480
local ListFilesAction = __TS__Class() -- 3495
ListFilesAction.name = "ListFilesAction" -- 3495
__TS__ClassExtends(ListFilesAction, Node) -- 3495
function ListFilesAction.prototype.prep(self, shared) -- 3496
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3496
		local last = shared.history[#shared.history] -- 3497
		if not last then -- 3497
			error( -- 3498
				__TS__New(Error, "no history"), -- 3498
				0 -- 3498
			) -- 3498
		end -- 3498
		emitAgentStartEvent(shared, last) -- 3499
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3499
	end) -- 3499
end -- 3496
function ListFilesAction.prototype.exec(self, input) -- 3503
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3503
		local params = input.params -- 3504
		local ____Tools_listFiles_139 = Tools.listFiles -- 3505
		local ____input_workDir_136 = input.workDir -- 3506
		local ____temp_137 = params.path or "" -- 3507
		local ____params_globs_138 = params.globs -- 3508
		local ____math_max_135 = math.max -- 3509
		local ____math_floor_134 = math.floor -- 3509
		local ____params_maxEntries_133 = params.maxEntries -- 3509
		if ____params_maxEntries_133 == nil then -- 3509
			____params_maxEntries_133 = AgentConfig.AGENT_LIMITS.listFilesMaxEntriesDefault -- 3509
		end -- 3509
		local result = ____Tools_listFiles_139({ -- 3505
			workDir = ____input_workDir_136, -- 3506
			path = ____temp_137, -- 3507
			globs = ____params_globs_138, -- 3508
			maxEntries = ____math_max_135( -- 3509
				1, -- 3509
				____math_floor_134(__TS__Number(____params_maxEntries_133)) -- 3509
			) -- 3509
		}) -- 3509
		return ____awaiter_resolve(nil, result) -- 3509
	end) -- 3509
end -- 3503
function ListFilesAction.prototype.post(self, shared, _prepRes, execRes) -- 3514
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3514
		local last = shared.history[#shared.history] -- 3515
		if last ~= nil then -- 3515
			last.result = sanitizeListFilesResultForHistory(execRes) -- 3517
			appendToolResultMessage(shared, last) -- 3518
			emitAgentFinishEvent(shared, last) -- 3519
		end -- 3519
		persistHistoryState(shared) -- 3521
		__TS__Await(maybeCompressHistory(shared)) -- 3522
		persistHistoryState(shared) -- 3523
		return ____awaiter_resolve(nil, "main") -- 3523
	end) -- 3523
end -- 3514
local DeleteFileAction = __TS__Class() -- 3528
DeleteFileAction.name = "DeleteFileAction" -- 3528
__TS__ClassExtends(DeleteFileAction, Node) -- 3528
function DeleteFileAction.prototype.prep(self, shared) -- 3529
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3529
		local last = shared.history[#shared.history] -- 3530
		if not last then -- 3530
			error( -- 3531
				__TS__New(Error, "no history"), -- 3531
				0 -- 3531
			) -- 3531
		end -- 3531
		emitAgentStartEvent(shared, last) -- 3532
		local targetFile = type(last.params.target_file) == "string" and last.params.target_file or (type(last.params.path) == "string" and last.params.path or "") -- 3533
		if __TS__StringTrim(targetFile) == "" then -- 3533
			error( -- 3536
				__TS__New(Error, "missing target_file"), -- 3536
				0 -- 3536
			) -- 3536
		end -- 3536
		return ____awaiter_resolve(nil, {targetFile = targetFile, taskId = shared.taskId, workDir = shared.workingDir}) -- 3536
	end) -- 3536
end -- 3529
function DeleteFileAction.prototype.exec(self, input) -- 3540
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3540
		local result = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.targetFile, op = "delete"}}, {summary = "delete_file: " .. input.targetFile, toolName = "delete_file"}) -- 3541
		if not result.success then -- 3541
			return ____awaiter_resolve(nil, result) -- 3541
		end -- 3541
		return ____awaiter_resolve(nil, { -- 3541
			success = true, -- 3549
			changed = true, -- 3550
			mode = "delete", -- 3551
			checkpointId = result.checkpointId, -- 3552
			checkpointSeq = result.checkpointSeq, -- 3553
			files = {{path = input.targetFile, op = "delete"}} -- 3554
		}) -- 3554
	end) -- 3554
end -- 3540
function DeleteFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3558
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3558
		local last = shared.history[#shared.history] -- 3559
		if last ~= nil then -- 3559
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3561
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3562
			appendToolResultMessage(shared, last) -- 3563
			emitAgentFinishEvent(shared, last) -- 3564
			local result = last.result -- 3565
			if last.tool == "delete_file" and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3565
				emitAgentEvent(shared, { -- 3570
					type = "checkpoint_created", -- 3571
					sessionId = shared.sessionId, -- 3572
					taskId = shared.taskId, -- 3573
					step = last.step, -- 3574
					tool = "delete_file", -- 3575
					checkpointId = result.checkpointId, -- 3576
					checkpointSeq = result.checkpointSeq, -- 3577
					files = result.files -- 3578
				}) -- 3578
			end -- 3578
		end -- 3578
		persistHistoryState(shared) -- 3585
		__TS__Await(maybeCompressHistory(shared)) -- 3586
		persistHistoryState(shared) -- 3587
		return ____awaiter_resolve(nil, "main") -- 3587
	end) -- 3587
end -- 3558
local BuildAction = __TS__Class() -- 3592
BuildAction.name = "BuildAction" -- 3592
__TS__ClassExtends(BuildAction, Node) -- 3592
function BuildAction.prototype.prep(self, shared) -- 3593
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3593
		local last = shared.history[#shared.history] -- 3594
		if not last then -- 3594
			error( -- 3595
				__TS__New(Error, "no history"), -- 3595
				0 -- 3595
			) -- 3595
		end -- 3595
		emitAgentStartEvent(shared, last) -- 3596
		return ____awaiter_resolve(nil, {params = last.params, workDir = shared.workingDir}) -- 3596
	end) -- 3596
end -- 3593
function BuildAction.prototype.exec(self, input) -- 3600
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3600
		local params = input.params -- 3601
		local result = __TS__Await(Tools.build({workDir = input.workDir, path = params.path or ""})) -- 3602
		return ____awaiter_resolve(nil, result) -- 3602
	end) -- 3602
end -- 3600
function BuildAction.prototype.post(self, shared, _prepRes, execRes) -- 3609
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3609
		local last = shared.history[#shared.history] -- 3610
		if last ~= nil then -- 3610
			last.result = sanitizeBuildResultForHistory(execRes) -- 3612
			appendToolResultMessage(shared, last) -- 3613
			emitAgentFinishEvent(shared, last) -- 3614
		end -- 3614
		persistHistoryState(shared) -- 3616
		__TS__Await(maybeCompressHistory(shared)) -- 3617
		persistHistoryState(shared) -- 3618
		return ____awaiter_resolve(nil, "main") -- 3618
	end) -- 3618
end -- 3609
local SpawnSubAgentAction = __TS__Class() -- 3623
SpawnSubAgentAction.name = "SpawnSubAgentAction" -- 3623
__TS__ClassExtends(SpawnSubAgentAction, Node) -- 3623
function SpawnSubAgentAction.prototype.prep(self, shared) -- 3624
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3624
		local last = shared.history[#shared.history] -- 3634
		if not last then -- 3634
			error( -- 3635
				__TS__New(Error, "no history"), -- 3635
				0 -- 3635
			) -- 3635
		end -- 3635
		emitAgentStartEvent(shared, last) -- 3636
		local filesHint = isArray(last.params.filesHint) and __TS__ArrayFilter( -- 3637
			last.params.filesHint, -- 3638
			function(____, item) return type(item) == "string" end -- 3638
		) or nil -- 3638
		return ____awaiter_resolve( -- 3638
			nil, -- 3638
			{ -- 3640
				title = type(last.params.title) == "string" and last.params.title or "Sub", -- 3641
				prompt = type(last.params.prompt) == "string" and last.params.prompt or "", -- 3642
				expectedOutput = type(last.params.expectedOutput) == "string" and last.params.expectedOutput or nil, -- 3643
				filesHint = filesHint, -- 3644
				sessionId = shared.sessionId, -- 3645
				projectRoot = shared.workingDir, -- 3646
				spawnSubAgent = shared.spawnSubAgent, -- 3647
				disabledAgentTools = shared.disabledAgentTools -- 3648
			} -- 3648
		) -- 3648
	end) -- 3648
end -- 3624
function SpawnSubAgentAction.prototype.exec(self, input) -- 3652
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3652
		if not input.spawnSubAgent then -- 3652
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent is not available in this runtime"}) -- 3652
		end -- 3652
		if input.sessionId == nil or input.sessionId <= 0 then -- 3652
			return ____awaiter_resolve(nil, {success = false, message = "spawn_sub_agent requires a parent session"}) -- 3652
		end -- 3652
		local ____Log_145 = Log -- 3668
		local ____temp_142 = #input.title -- 3668
		local ____temp_143 = #input.prompt -- 3668
		local ____temp_144 = type(input.expectedOutput) == "string" and #input.expectedOutput or 0 -- 3668
		local ____opt_140 = input.filesHint -- 3668
		____Log_145( -- 3668
			"Info", -- 3668
			(((((("[CodingAgent] spawn_sub_agent exec title_len=" .. tostring(____temp_142)) .. " prompt_len=") .. tostring(____temp_143)) .. " expected_len=") .. tostring(____temp_144)) .. " files_hint_count=") .. tostring(____opt_140 and #____opt_140 or 0) -- 3668
		) -- 3668
		local result = __TS__Await(input.spawnSubAgent({ -- 3669
			parentSessionId = input.sessionId, -- 3670
			projectRoot = input.projectRoot, -- 3671
			title = input.title, -- 3672
			prompt = input.prompt, -- 3673
			expectedOutput = input.expectedOutput, -- 3674
			filesHint = input.filesHint, -- 3675
			disabledAgentTools = input.disabledAgentTools -- 3676
		})) -- 3676
		if not result.success then -- 3676
			return ____awaiter_resolve(nil, result) -- 3676
		end -- 3676
		return ____awaiter_resolve(nil, { -- 3676
			success = true, -- 3682
			sessionId = result.sessionId, -- 3683
			taskId = result.taskId, -- 3684
			title = result.title, -- 3685
			hint = "Dispatch any other intended independent sub-agents, do only bounded foreground work that does not depend on them, then finish this turn. Do not call list_sub_agents; results arrive as asynchronous handoffs." -- 3686
		}) -- 3686
	end) -- 3686
end -- 3652
function SpawnSubAgentAction.prototype.post(self, shared, _prepRes, execRes) -- 3690
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3690
		local last = shared.history[#shared.history] -- 3691
		if last ~= nil then -- 3691
			last.result = execRes -- 3693
			if execRes.success == true then -- 3693
				shared.hasSpawnedSubAgentThisTask = true -- 3695
			end -- 3695
			appendToolResultMessage(shared, last) -- 3697
			emitAgentFinishEvent(shared, last) -- 3698
		end -- 3698
		persistHistoryState(shared) -- 3700
		__TS__Await(maybeCompressHistory(shared)) -- 3701
		persistHistoryState(shared) -- 3702
		return ____awaiter_resolve(nil, "main") -- 3702
	end) -- 3702
end -- 3690
local ListSubAgentsAction = __TS__Class() -- 3707
ListSubAgentsAction.name = "ListSubAgentsAction" -- 3707
__TS__ClassExtends(ListSubAgentsAction, Node) -- 3707
function ListSubAgentsAction.prototype.prep(self, shared) -- 3708
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3708
		local last = shared.history[#shared.history] -- 3718
		if not last then -- 3718
			error( -- 3719
				__TS__New(Error, "no history"), -- 3719
				0 -- 3719
			) -- 3719
		end -- 3719
		emitAgentStartEvent(shared, last) -- 3720
		return ____awaiter_resolve( -- 3720
			nil, -- 3720
			{ -- 3721
				sessionId = shared.sessionId, -- 3722
				projectRoot = shared.workingDir, -- 3723
				status = type(last.params.status) == "string" and last.params.status or nil, -- 3724
				limit = type(last.params.limit) == "number" and last.params.limit or nil, -- 3725
				offset = type(last.params.offset) == "number" and last.params.offset or nil, -- 3726
				query = type(last.params.query) == "string" and last.params.query or nil, -- 3727
				listSubAgents = shared.listSubAgents, -- 3728
				shouldDiscouragePolling = shared.hasSpawnedSubAgentThisTask == true -- 3729
			} -- 3729
		) -- 3729
	end) -- 3729
end -- 3708
function ListSubAgentsAction.prototype.exec(self, input) -- 3733
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3733
		if not input.listSubAgents then -- 3733
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents is not available in this runtime"}) -- 3733
		end -- 3733
		if input.sessionId == nil or input.sessionId <= 0 then -- 3733
			return ____awaiter_resolve(nil, {success = false, message = "list_sub_agents requires a current session"}) -- 3733
		end -- 3733
		local result = __TS__Await(input.listSubAgents({ -- 3749
			sessionId = input.sessionId, -- 3750
			projectRoot = input.projectRoot, -- 3751
			status = input.status, -- 3752
			limit = input.limit, -- 3753
			offset = input.offset, -- 3754
			query = input.query -- 3755
		})) -- 3755
		return ____awaiter_resolve( -- 3755
			nil, -- 3755
			__TS__ObjectAssign({}, result, input.shouldDiscouragePolling and ({guidance = "Sub-agent results arrive asynchronously. Avoid polling repeatedly; finish the current turn when no independent foreground work remains."}) or ({})) -- 3757
		) -- 3757
	end) -- 3757
end -- 3733
function ListSubAgentsAction.prototype.post(self, shared, _prepRes, execRes) -- 3765
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3765
		local last = shared.history[#shared.history] -- 3766
		if last ~= nil then -- 3766
			last.result = execRes -- 3768
			appendToolResultMessage(shared, last) -- 3769
			emitAgentFinishEvent(shared, last) -- 3770
		end -- 3770
		persistHistoryState(shared) -- 3772
		__TS__Await(maybeCompressHistory(shared)) -- 3773
		persistHistoryState(shared) -- 3774
		return ____awaiter_resolve(nil, "main") -- 3774
	end) -- 3774
end -- 3765
EditFileAction = __TS__Class() -- 3779
EditFileAction.name = "EditFileAction" -- 3779
__TS__ClassExtends(EditFileAction, Node) -- 3779
function EditFileAction.prototype.prep(self, shared) -- 3780
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3780
		local last = shared.history[#shared.history] -- 3781
		if not last then -- 3781
			error( -- 3782
				__TS__New(Error, "no history"), -- 3782
				0 -- 3782
			) -- 3782
		end -- 3782
		emitAgentStartEvent(shared, last) -- 3783
		local path = type(last.params.path) == "string" and last.params.path or (type(last.params.target_file) == "string" and last.params.target_file or "") -- 3784
		local oldStr = type(last.params.old_str) == "string" and last.params.old_str or "" -- 3787
		local newStr = type(last.params.new_str) == "string" and last.params.new_str or "" -- 3788
		if __TS__StringTrim(path) == "" then -- 3788
			error( -- 3789
				__TS__New(Error, "missing path"), -- 3789
				0 -- 3789
			) -- 3789
		end -- 3789
		return ____awaiter_resolve(nil, { -- 3789
			path = path, -- 3790
			oldStr = oldStr, -- 3790
			newStr = newStr, -- 3790
			taskId = shared.taskId, -- 3790
			workDir = shared.workingDir -- 3790
		}) -- 3790
	end) -- 3790
end -- 3780
function EditFileAction.prototype.exec(self, input) -- 3793
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3793
		local readRes = Tools.readFileRaw(input.workDir, input.path) -- 3794
		if not readRes.success then -- 3794
			if input.oldStr ~= "" then -- 3794
				return ____awaiter_resolve(nil, {success = false, message = "read file failed: " .. readRes.message}) -- 3794
			end -- 3794
			local createRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "create", content = input.newStr}}, {summary = ("create file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3799
			if not createRes.success then -- 3799
				return ____awaiter_resolve(nil, {success = false, message = "create file failed: " .. createRes.message}) -- 3799
			end -- 3799
			return ____awaiter_resolve( -- 3799
				nil, -- 3799
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3806
					success = true, -- 3807
					changed = true, -- 3808
					mode = "create", -- 3809
					checkpointId = createRes.checkpointId, -- 3810
					checkpointSeq = createRes.checkpointSeq, -- 3811
					files = {{path = input.path, op = "create"}} -- 3812
				}) -- 3812
			) -- 3812
		end -- 3812
		if input.oldStr == "" then -- 3812
			if AgentRuntimePolicy.containsWholeFileDuplicate(readRes.content, input.newStr) then -- 3812
				return ____awaiter_resolve( -- 3812
					nil, -- 3812
					{ -- 3817
						success = false, -- 3818
						message = ("rewrite rejected: the complete current file appears more than once in the replacement for " .. input.path) .. ". The existing file is unchanged; submit one coherent full-file replacement.", -- 3819
						actualSaved = false, -- 3820
						actualSavedCharacters = 0, -- 3821
						currentFileExists = true, -- 3822
						currentCharacters = #readRes.content, -- 3823
						currentState = ((("unchanged " .. input.path) .. " (") .. tostring(#readRes.content)) .. " characters)" -- 3824
					} -- 3824
				) -- 3824
			end -- 3824
			local overwriteRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = input.newStr}}, {summary = ("overwrite file " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3827
			if not overwriteRes.success then -- 3827
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. overwriteRes.message}) -- 3827
			end -- 3827
			return ____awaiter_resolve( -- 3827
				nil, -- 3827
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3834
					success = true, -- 3835
					changed = true, -- 3836
					mode = "overwrite", -- 3837
					checkpointId = overwriteRes.checkpointId, -- 3838
					checkpointSeq = overwriteRes.checkpointSeq, -- 3839
					files = {{path = input.path, op = "write"}} -- 3840
				}) -- 3840
			) -- 3840
		end -- 3840
		local normalizedContent = AgentRuntimePolicy.normalizeLineEndings(readRes.content) -- 3845
		local normalizedOldStr = AgentRuntimePolicy.normalizeLineEndings(input.oldStr) -- 3846
		local normalizedNewStr = AgentRuntimePolicy.normalizeLineEndings(input.newStr) -- 3847
		local occurrences = AgentRuntimePolicy.countOccurrences(normalizedContent, normalizedOldStr) -- 3850
		if occurrences == 0 then -- 3850
			local indentTolerant = findIndentTolerantReplacement(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3852
			if not indentTolerant.success then -- 3852
				return ____awaiter_resolve(nil, {success = false, message = indentTolerant.message}) -- 3852
			end -- 3852
			local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = indentTolerant.content}}, {summary = ("replace text in " .. input.path) .. " via edit_file (indent-tolerant)", toolName = "edit_file"}) -- 3856
			if not applyRes.success then -- 3856
				return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3856
			end -- 3856
			return ____awaiter_resolve( -- 3856
				nil, -- 3856
				AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3863
					success = true, -- 3864
					changed = true, -- 3865
					mode = "replace_indent_tolerant", -- 3866
					checkpointId = applyRes.checkpointId, -- 3867
					checkpointSeq = applyRes.checkpointSeq, -- 3868
					files = {{path = input.path, op = "write"}} -- 3869
				}) -- 3869
			) -- 3869
		end -- 3869
		if occurrences > 1 then -- 3869
			return ____awaiter_resolve( -- 3869
				nil, -- 3869
				{ -- 3873
					success = false, -- 3873
					message = ("old_str appears " .. tostring(occurrences)) .. " times in file. Please provide more context to uniquely identify the target location." -- 3873
				} -- 3873
			) -- 3873
		end -- 3873
		local newContent = replaceFirst(normalizedContent, normalizedOldStr, normalizedNewStr) -- 3877
		local applyRes = Tools.applyFileChanges(input.taskId, input.workDir, {{path = input.path, op = "write", content = newContent}}, {summary = ("replace text in " .. input.path) .. " via edit_file", toolName = "edit_file"}) -- 3878
		if not applyRes.success then -- 3878
			return ____awaiter_resolve(nil, {success = false, message = "write file failed: " .. applyRes.message}) -- 3878
		end -- 3878
		return ____awaiter_resolve( -- 3878
			nil, -- 3878
			AgentRuntimePolicy.successfulEditResult(input.workDir, input.path, { -- 3885
				success = true, -- 3886
				changed = true, -- 3887
				mode = "replace", -- 3888
				checkpointId = applyRes.checkpointId, -- 3889
				checkpointSeq = applyRes.checkpointSeq, -- 3890
				files = {{path = input.path, op = "write"}} -- 3891
			}) -- 3891
		) -- 3891
	end) -- 3891
end -- 3793
function EditFileAction.prototype.post(self, shared, _prepRes, execRes) -- 3895
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3895
		local last = shared.history[#shared.history] -- 3896
		if last ~= nil then -- 3896
			last.params = sanitizeActionParamsForHistory(last.tool, last.params) -- 3898
			last.result = sanitizeToolActionResultForHistory(last, execRes) -- 3899
			appendToolResultMessage(shared, last) -- 3900
			emitAgentFinishEvent(shared, last) -- 3901
			local result = last.result -- 3902
			if (last.tool == "edit_file" or last.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3902
				emitAgentEvent(shared, { -- 3907
					type = "checkpoint_created", -- 3908
					sessionId = shared.sessionId, -- 3909
					taskId = shared.taskId, -- 3910
					step = last.step, -- 3911
					tool = last.tool, -- 3912
					checkpointId = result.checkpointId, -- 3913
					checkpointSeq = result.checkpointSeq, -- 3914
					files = result.files -- 3915
				}) -- 3915
			end -- 3915
		end -- 3915
		persistHistoryState(shared) -- 3922
		__TS__Await(maybeCompressHistory(shared)) -- 3923
		persistHistoryState(shared) -- 3924
		return ____awaiter_resolve(nil, "main") -- 3924
	end) -- 3924
end -- 3895
local FetchUrlAction = __TS__Class() -- 3929
FetchUrlAction.name = "FetchUrlAction" -- 3929
__TS__ClassExtends(FetchUrlAction, Node) -- 3929
function FetchUrlAction.prototype.prep(self, shared) -- 3930
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3930
		local last = shared.history[#shared.history] -- 3931
		if not last then -- 3931
			error( -- 3932
				__TS__New(Error, "no history"), -- 3932
				0 -- 3932
			) -- 3932
		end -- 3932
		emitAgentStartEvent(shared, last) -- 3933
		return ____awaiter_resolve(nil, {shared = shared, action = last}) -- 3933
	end) -- 3933
end -- 3930
function FetchUrlAction.prototype.exec(self, input) -- 3937
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3937
		return ____awaiter_resolve( -- 3937
			nil, -- 3937
			executeToolAction(input.shared, input.action) -- 3938
		) -- 3938
	end) -- 3938
end -- 3937
function FetchUrlAction.prototype.post(self, shared, _prepRes, execRes) -- 3941
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 3941
		local last = shared.history[#shared.history] -- 3942
		if last ~= nil then -- 3942
			last.result = execRes -- 3944
			appendToolResultMessage(shared, last) -- 3945
			emitAgentFinishEvent(shared, last) -- 3946
		end -- 3946
		persistHistoryState(shared) -- 3948
		__TS__Await(maybeCompressHistory(shared)) -- 3949
		persistHistoryState(shared) -- 3950
		return ____awaiter_resolve(nil, "main") -- 3950
	end) -- 3950
end -- 3941
local function emitCheckpointEventForAction(shared, action) -- 3955
	local result = action.result -- 3956
	if not result then -- 3956
		return -- 3957
	end -- 3957
	if (action.tool == "edit_file" or action.tool == "delete_file") and type(result.checkpointId) == "number" and type(result.checkpointSeq) == "number" and isArray(result.files) then -- 3957
		emitAgentEvent(shared, { -- 3962
			type = "checkpoint_created", -- 3963
			sessionId = shared.sessionId, -- 3964
			taskId = shared.taskId, -- 3965
			step = action.step, -- 3966
			tool = action.tool, -- 3967
			checkpointId = result.checkpointId, -- 3968
			checkpointSeq = result.checkpointSeq, -- 3969
			files = result.files -- 3970
		}) -- 3970
	end -- 3970
end -- 3955
local function canRunBatchActionInParallel(self, action) -- 4502
	return AgentToolRegistry.canRunToolInParallel(action.tool) -- 4503
end -- 4502
local function partitionToolCalls(actions) -- 4511
	local batches = {} -- 4512
	do -- 4512
		local i = 0 -- 4513
		while i < #actions do -- 4513
			local action = actions[i + 1] -- 4514
			local isSafe = canRunBatchActionInParallel(nil, action) -- 4515
			local lastBatch = #batches > 0 and batches[#batches] or nil -- 4516
			if isSafe and lastBatch and lastBatch.isConcurrencySafe then -- 4516
				local ____lastBatch_actions_178 = lastBatch.actions -- 4516
				____lastBatch_actions_178[#____lastBatch_actions_178 + 1] = action -- 4518
			else -- 4518
				batches[#batches + 1] = {isConcurrencySafe = isSafe, actions = {action}} -- 4520
			end -- 4520
			i = i + 1 -- 4513
		end -- 4513
	end -- 4513
	return batches -- 4523
end -- 4511
local function completeStoppedToolAction(shared, action) -- 4526
	action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4527
	if not action.result then -- 4527
		action.result = { -- 4529
			success = false, -- 4529
			message = getCancelledReason(shared) -- 4529
		} -- 4529
	end -- 4529
	appendToolResultMessage(shared, action) -- 4531
	emitAgentFinishEvent(shared, action) -- 4532
	emitCheckpointEventForAction(shared, action) -- 4533
end -- 4526
local BatchToolAction = __TS__Class() -- 4536
BatchToolAction.name = "BatchToolAction" -- 4536
__TS__ClassExtends(BatchToolAction, Node) -- 4536
function BatchToolAction.prototype.prep(self, shared) -- 4537
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4537
		return ____awaiter_resolve(nil, {shared = shared, actions = shared.pendingToolActions or ({})}) -- 4537
	end) -- 4537
end -- 4537
function BatchToolAction.prototype.exec(self, input) -- 4541
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4541
		local shared = input.shared -- 4542
		local spawnedBeforeBatch = shared.hasSpawnedSubAgentThisTask == true -- 4543
		local preExecuted = shared.preExecutedResults -- 4544
		local batches = partitionToolCalls(input.actions) -- 4545
		local parallelBatchCount = #__TS__ArrayFilter( -- 4546
			batches, -- 4546
			function(____, b) return b.isConcurrencySafe end -- 4546
		) -- 4546
		local serialBatchCount = #__TS__ArrayFilter( -- 4547
			batches, -- 4547
			function(____, b) return not b.isConcurrencySafe end -- 4547
		) -- 4547
		Log( -- 4548
			"Info", -- 4548
			(((("[CodingAgent] smart batch partition total=" .. tostring(#input.actions)) .. " parallel_batches=") .. tostring(parallelBatchCount)) .. " serial_batches=") .. tostring(serialBatchCount) -- 4548
		) -- 4548
		do -- 4548
			local batchIdx = 0 -- 4550
			while batchIdx < #batches do -- 4550
				do -- 4550
					local batch = batches[batchIdx + 1] -- 4551
					if shared.stopToken.stopped then -- 4551
						for ____, action in ipairs(batch.actions) do -- 4553
							completeStoppedToolAction(shared, action) -- 4554
						end -- 4554
						goto __continue754 -- 4556
					end -- 4556
					if batch.isConcurrencySafe and #batch.actions > 1 then -- 4556
						local preExecCount = #__TS__ArrayFilter( -- 4560
							batch.actions, -- 4560
							function(____, a) return preExecuted and preExecuted:has(a.toolCallId) end -- 4560
						) -- 4560
						Log( -- 4561
							"Info", -- 4561
							(((((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " parallel count=") .. tostring(#batch.actions)) .. " pre_executed=") .. tostring(preExecCount) -- 4561
						) -- 4561
						do -- 4561
							local i = 0 -- 4562
							while i < #batch.actions do -- 4562
								emitAgentStartEvent(shared, batch.actions[i + 1]) -- 4563
								i = i + 1 -- 4562
							end -- 4562
						end -- 4562
						__TS__Await(__TS__PromiseAll(__TS__ArrayMap( -- 4565
							batch.actions, -- 4565
							function(____, action) -- 4565
								return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4565
									if shared.stopToken.stopped then -- 4565
										action.result = { -- 4567
											success = false, -- 4567
											message = getCancelledReason(shared) -- 4567
										} -- 4567
										return ____awaiter_resolve(nil, action) -- 4567
									end -- 4567
									local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4570
									action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4571
									action.result = sanitizeToolActionResultForHistory(action, result) -- 4572
									return ____awaiter_resolve(nil, action) -- 4572
								end) -- 4572
							end -- 4565
						))) -- 4565
						do -- 4565
							local i = 0 -- 4575
							while i < #batch.actions do -- 4575
								local action = batch.actions[i + 1] -- 4576
								if not action.result then -- 4576
									action.result = {success = false, message = "tool did not produce a result"} -- 4578
								end -- 4578
								appendToolResultMessage(shared, action) -- 4580
								emitAgentFinishEvent(shared, action) -- 4581
								emitCheckpointEventForAction(shared, action) -- 4582
								i = i + 1 -- 4575
							end -- 4575
						end -- 4575
					else -- 4575
						Log( -- 4585
							"Info", -- 4585
							(((("[CodingAgent] batch " .. tostring(batchIdx + 1)) .. "/") .. tostring(#batches)) .. " serial count=") .. tostring(#batch.actions) -- 4585
						) -- 4585
						do -- 4585
							local i = 0 -- 4586
							while i < #batch.actions do -- 4586
								local action = batch.actions[i + 1] -- 4587
								emitAgentStartEvent(shared, action) -- 4588
								local result = __TS__Await(executeToolActionWithPreExecution(shared, action)) -- 4589
								action.params = sanitizeActionParamsForHistory(action.tool, action.params) -- 4590
								action.result = sanitizeToolActionResultForHistory(action, result) -- 4591
								appendToolResultMessage(shared, action) -- 4592
								emitAgentFinishEvent(shared, action) -- 4593
								emitCheckpointEventForAction(shared, action) -- 4594
								persistHistoryState(shared) -- 4595
								if shared.stopToken.stopped then -- 4595
									do -- 4595
										local j = i + 1 -- 4597
										while j < #batch.actions do -- 4597
											completeStoppedToolAction(shared, batch.actions[j + 1]) -- 4598
											j = j + 1 -- 4597
										end -- 4597
									end -- 4597
									break -- 4600
								end -- 4600
								i = i + 1 -- 4586
							end -- 4586
						end -- 4586
					end -- 4586
				end -- 4586
				::__continue754:: -- 4586
				batchIdx = batchIdx + 1 -- 4550
			end -- 4550
		end -- 4550
		local spawnSeen = spawnedBeforeBatch -- 4605
		local didDelegatedForegroundWork = false -- 4606
		do -- 4606
			local i = 0 -- 4607
			while i < #input.actions do -- 4607
				do -- 4607
					local action = input.actions[i + 1] -- 4608
					if action.tool == "spawn_sub_agent" then -- 4608
						local ____opt_181 = action.result -- 4608
						if (____opt_181 and ____opt_181.success) == true then -- 4608
							spawnSeen = true -- 4610
						end -- 4610
						goto __continue774 -- 4611
					end -- 4611
					if spawnSeen and action.tool ~= "finish" then -- 4611
						didDelegatedForegroundWork = true -- 4614
					end -- 4614
				end -- 4614
				::__continue774:: -- 4614
				i = i + 1 -- 4607
			end -- 4607
		end -- 4607
		if didDelegatedForegroundWork then -- 4607
			shared.delegatedForegroundBatches = (shared.delegatedForegroundBatches or 0) + 1 -- 4618
		end -- 4618
		persistHistoryState(shared) -- 4620
		return ____awaiter_resolve(nil, input.actions) -- 4620
	end) -- 4620
end -- 4541
function BatchToolAction.prototype.post(self, shared, _prepRes, _execRes) -- 4624
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4624
		shared.pendingToolActions = nil -- 4625
		shared.preExecutedResults = nil -- 4626
		persistHistoryState(shared) -- 4627
		__TS__Await(maybeCompressHistory(shared)) -- 4628
		persistHistoryState(shared) -- 4629
		return ____awaiter_resolve(nil, shared.waitingQuestionnaireId ~= nil and "done" or "main") -- 4629
	end) -- 4629
end -- 4624
local EndNode = __TS__Class() -- 4634
EndNode.name = "EndNode" -- 4634
__TS__ClassExtends(EndNode, Node) -- 4634
function EndNode.prototype.post(self, _shared, _prepRes, _execRes) -- 4635
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4635
		return ____awaiter_resolve(nil, nil) -- 4635
	end) -- 4635
end -- 4635
local CodingAgentFlow = __TS__Class() -- 4640
CodingAgentFlow.name = "CodingAgentFlow" -- 4640
__TS__ClassExtends(CodingAgentFlow, Flow) -- 4640
function CodingAgentFlow.prototype.____constructor(self, role) -- 4641
	local main = __TS__New(MainDecisionAgent, 1, 0) -- 4642
	local read = __TS__New(ReadFileAction, 1, 0) -- 4643
	local search = __TS__New(SearchFilesAction, 1, 0) -- 4644
	local searchDora = __TS__New(SearchDoraAPIAction, 1, 0) -- 4645
	local list = __TS__New(ListFilesAction, 1, 0) -- 4646
	local listSub = __TS__New(ListSubAgentsAction, 1, 0) -- 4647
	local del = __TS__New(DeleteFileAction, 1, 0) -- 4648
	local build = __TS__New(BuildAction, 1, 0) -- 4649
	local spawn = __TS__New(SpawnSubAgentAction, 1, 0) -- 4650
	local edit = __TS__New(EditFileAction, 1, 0) -- 4651
	local fetch = __TS__New(FetchUrlAction, 1, 0) -- 4652
	local exec = __TS__New(FetchUrlAction, 1, 0) -- 4653
	local batch = __TS__New(BatchToolAction, 1, 0) -- 4654
	local done = __TS__New(EndNode, 1, 0) -- 4655
	main:on("batch_tools", batch) -- 4657
	main:on("grep_files", search) -- 4658
	main:on("search_dora_api", searchDora) -- 4659
	main:on("glob_files", list) -- 4660
	main:on("fetch_url", fetch) -- 4661
	main:on("execute_command", exec) -- 4662
	if role == "main" then -- 4662
		main:on("read_file", read) -- 4664
		main:on("delete_file", del) -- 4665
		main:on("build", build) -- 4666
		main:on("edit_file", edit) -- 4667
		main:on("list_sub_agents", listSub) -- 4668
		main:on("spawn_sub_agent", spawn) -- 4669
	else -- 4669
		main:on("read_file", read) -- 4671
		main:on("delete_file", del) -- 4672
		main:on("build", build) -- 4673
		main:on("edit_file", edit) -- 4674
	end -- 4674
	main:on("done", done) -- 4676
	search:on("main", main) -- 4678
	searchDora:on("main", main) -- 4679
	list:on("main", main) -- 4680
	listSub:on("main", main) -- 4681
	spawn:on("main", main) -- 4682
	batch:on("main", main) -- 4683
	batch:on("done", done) -- 4684
	read:on("main", main) -- 4685
	del:on("main", main) -- 4686
	build:on("main", main) -- 4687
	edit:on("main", main) -- 4688
	fetch:on("main", main) -- 4689
	exec:on("main", main) -- 4690
	Flow.prototype.____constructor(self, main) -- 4692
end -- 4641
local function runCodingAgentAsync(options) -- 4728
	return __TS__AsyncAwaiter(function(____awaiter_resolve) -- 4728
		if not options.workDir or not Content:isAbsolutePath(options.workDir) or not Content:exist(options.workDir) or not Content:isdir(options.workDir) then -- 4728
			return ____awaiter_resolve(nil, {success = false, message = "workDir must be an existing absolute directory path"}) -- 4728
		end -- 4728
		local normalizedPrompt = ____exports.truncateAgentUserPrompt(options.prompt) -- 4732
		local llmConfigRes = options.llmConfig and ({success = true, config = options.llmConfig}) or getActiveLLMConfig() -- 4733
		if not llmConfigRes.success then -- 4733
			return ____awaiter_resolve(nil, {success = false, message = llmConfigRes.message}) -- 4733
		end -- 4733
		local llmConfig = llmConfigRes.config -- 4739
		local taskRes = options.taskId ~= nil and ({success = true, taskId = options.taskId}) or Tools.createTask(normalizedPrompt, options.workMode or "code") -- 4740
		if not taskRes.success then -- 4740
			return ____awaiter_resolve(nil, {success = false, message = taskRes.message}) -- 4740
		end -- 4740
		local compressor = __TS__New(MemoryCompressor, { -- 4747
			compressionThreshold = 0.8, -- 4748
			compressionTargetThreshold = 0.5, -- 4749
			maxCompressionRounds = 3, -- 4750
			projectDir = options.workDir, -- 4751
			llmConfig = llmConfig, -- 4752
			promptPack = options.promptPack, -- 4753
			scope = options.memoryScope -- 4754
		}) -- 4754
		local persistedSession = compressor:getStorage():readSessionState() -- 4756
		local effectiveUserQuery = normalizedPrompt -- 4757
		if options.resumeConversation == true then -- 4757
			do -- 4757
				local i = #persistedSession.messages - 1 -- 4759
				while i >= 0 do -- 4759
					local message = persistedSession.messages[i + 1] -- 4760
					if message.role == "user" and type(message.content) == "string" and __TS__StringTrim(message.content) ~= "" then -- 4760
						effectiveUserQuery = message.content -- 4762
						break -- 4763
					end -- 4763
					i = i - 1 -- 4759
				end -- 4759
			end -- 4759
		end -- 4759
		local promptPack = compressor:getPromptPack() -- 4767
		local freshProject = inspectFreshProject(options.workDir) -- 4768
		local freshProjectBuildPending = freshProject.fresh -- 4769
		local freshProjectCodeFile = freshProject.codeFile -- 4770
		local shared = { -- 4772
			sessionId = options.sessionId, -- 4773
			taskId = taskRes.taskId, -- 4774
			role = options.role or "main", -- 4775
			maxSteps = math.max( -- 4776
				1, -- 4776
				math.floor(options.maxSteps or AgentConfig.AGENT_DEFAULTS.maxSteps) -- 4776
			), -- 4776
			llmMaxTry = math.max( -- 4777
				1, -- 4777
				math.floor(options.llmMaxTry or AgentConfig.AGENT_DEFAULTS.llmMaxTry) -- 4777
			), -- 4777
			step = 0, -- 4778
			done = false, -- 4779
			stopToken = options.stopToken or ({stopped = false}), -- 4780
			response = "", -- 4781
			userQuery = effectiveUserQuery, -- 4782
			workingDir = options.workDir, -- 4783
			useChineseResponse = options.useChineseResponse == true, -- 4784
			workMode = options.workMode or "code", -- 4785
			decisionMode = options.decisionMode and options.decisionMode or (llmConfig.supportsFunctionCalling and "tool_calling" or "xml"), -- 4786
			llmOptions = buildLLMOptions(llmConfig, options.llmOptions), -- 4789
			llmConfig = llmConfig, -- 4790
			onEvent = options.onEvent, -- 4791
			promptPack = promptPack, -- 4792
			history = {}, -- 4793
			messages = persistedSession.messages, -- 4794
			lastConsolidatedIndex = persistedSession.lastConsolidatedIndex, -- 4795
			carryMessageIndex = persistedSession.carryMessageIndex, -- 4796
			memory = {compressor = compressor}, -- 4798
			skills = {loader = AgentSkills.createSkillsLoader({ -- 4802
				projectDir = options.workDir, -- 4804
				disabledAgentTools = options.disabledAgentTools or ({}), -- 4805
				allowedAgentTools = AgentToolRegistry.getAllowedToolsForRole(options.role or "main", {workMode = options.workMode or "code", disabledAgentTools = options.disabledAgentTools or ({})}) -- 4806
			})}, -- 4806
			spawnSubAgent = options.spawnSubAgent, -- 4812
			listSubAgents = options.listSubAgents, -- 4813
			publishQuestionnaire = options.publishQuestionnaire, -- 4814
			disabledAgentTools = options.disabledAgentTools or ({}), -- 4815
			freshProjectBuildPending = freshProjectBuildPending, -- 4816
			freshProjectCodeFile = freshProjectCodeFile, -- 4817
			hasSpawnedSubAgentThisTask = false, -- 4818
			delegatedForegroundBatches = 0 -- 4819
		} -- 4819
		local ____hasReturned, ____returnValue -- 4819
		local ____try = __TS__AsyncAwaiter(function() -- 4819
			if shared.workMode == "plan" then -- 4819
				local planDocuments = AgentRuntimePolicy.ensureAgentPlanDocuments(shared.workingDir) -- 4824
				if not planDocuments.success then -- 4824
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4826
					____hasReturned = true -- 4827
					____returnValue = {success = false, taskId = shared.taskId, message = planDocuments.message} -- 4827
					return -- 4827
				end -- 4827
			end -- 4827
			emitAgentEvent(shared, { -- 4830
				type = "task_started", -- 4831
				sessionId = shared.sessionId, -- 4832
				taskId = shared.taskId, -- 4833
				prompt = shared.userQuery, -- 4834
				workDir = shared.workingDir, -- 4835
				maxSteps = shared.maxSteps -- 4836
			}) -- 4836
			if shared.stopToken.stopped then -- 4836
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4839
				____hasReturned = true -- 4840
				____returnValue = emitAgentTaskFinishEvent( -- 4840
					shared, -- 4840
					false, -- 4840
					getCancelledReason(shared) -- 4840
				) -- 4840
				return -- 4840
			end -- 4840
			Tools.setTaskStatus(shared.taskId, "RUNNING") -- 4842
			local ____temp_183 -- 4843
			if options.resumeConversation == true then -- 4843
				____temp_183 = nil -- 4843
			else -- 4843
				____temp_183 = getPromptCommand(shared.userQuery) -- 4843
			end -- 4843
			local promptCommand = ____temp_183 -- 4843
			if promptCommand == "clear" then -- 4843
				____hasReturned = true -- 4845
				____returnValue = clearSessionHistory(shared) -- 4845
				return -- 4845
			end -- 4845
			if promptCommand == "compact" then -- 4845
				if shared.role == "sub" then -- 4845
					Tools.setTaskStatus(shared.taskId, "FAILED") -- 4849
					____hasReturned = true -- 4850
					____returnValue = emitAgentTaskFinishEvent(shared, false, shared.useChineseResponse and "子代理会话不支持 /compact。" or "Sub-agent sessions do not support /compact.") -- 4850
					return -- 4850
				end -- 4850
				____hasReturned = true -- 4858
				____returnValue = __TS__Await(compactAllHistory(shared)) -- 4858
				return -- 4858
			end -- 4858
			__TS__Await(maybeCompressHistory(shared, true, options.resumeConversation == true and "" or normalizedPrompt)) -- 4860
			if shared.stopToken.stopped then -- 4860
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4862
				____hasReturned = true -- 4863
				____returnValue = emitAgentTaskFinishEvent( -- 4863
					shared, -- 4863
					false, -- 4863
					getCancelledReason(shared) -- 4863
				) -- 4863
				return -- 4863
			end -- 4863
			if options.resumeConversation ~= true then -- 4863
				appendConversationMessage(shared, {role = "user", content = normalizedPrompt}) -- 4866
				persistHistoryState(shared) -- 4870
			end -- 4870
			local flow = __TS__New(CodingAgentFlow, shared.role) -- 4872
			__TS__Await(flow:run(shared)) -- 4873
			if shared.stopToken.stopped then -- 4873
				Tools.setTaskStatus(shared.taskId, "STOPPED") -- 4875
				____hasReturned = true -- 4876
				____returnValue = emitAgentTaskFinishEvent( -- 4876
					shared, -- 4876
					false, -- 4876
					getCancelledReason(shared) -- 4876
				) -- 4876
				return -- 4876
			end -- 4876
			if shared.error then -- 4876
				____hasReturned = true -- 4879
				____returnValue = finalizeAgentFailure(shared, shared.response and shared.response ~= "" and shared.response or shared.error) -- 4879
				return -- 4879
			end -- 4879
			if shared.waitingQuestionnaireId ~= nil then -- 4879
				Tools.setTaskStatus(shared.taskId, "WAITING_USER") -- 4883
				emitAgentEvent(shared, { -- 4884
					type = "task_waiting_for_user", -- 4885
					sessionId = shared.sessionId, -- 4886
					taskId = shared.taskId, -- 4887
					step = shared.step, -- 4888
					questionnaireId = shared.waitingQuestionnaireId -- 4889
				}) -- 4889
				____hasReturned = true -- 4891
				____returnValue = { -- 4891
					success = true, -- 4892
					taskId = shared.taskId, -- 4893
					message = shared.useChineseResponse and "等待用户填写调查问卷。" or "Waiting for questionnaire feedback.", -- 4894
					steps = shared.step, -- 4895
					waitingForUser = true, -- 4896
					questionnaireId = shared.waitingQuestionnaireId -- 4897
				} -- 4897
				return -- 4891
			end -- 4891
			local ____isFinalDecisionTurn_result_186 = isFinalDecisionTurn(shared) -- 4900
			if ____isFinalDecisionTurn_result_186 then -- 4900
				local ____opt_184 = shared.completion -- 4900
				____isFinalDecisionTurn_result_186 = (____opt_184 and ____opt_184.outcome) == "partial" -- 4900
			end -- 4900
			if ____isFinalDecisionTurn_result_186 then -- 4900
				Tools.setTaskStatus(shared.taskId, "FAILED") -- 4901
				____hasReturned = true -- 4902
				____returnValue = emitAgentTaskFinishEvent(shared, false, shared.response or (shared.useChineseResponse and "本轮达到处理上限，工作尚未完成。" or "This task reached its processing limit with work remaining.")) -- 4902
				return -- 4902
			end -- 4902
			Tools.setTaskStatus(shared.taskId, "DONE") -- 4905
			____hasReturned = true -- 4906
			____returnValue = emitAgentTaskFinishEvent(shared, true, shared.response or (shared.useChineseResponse and "任务完成。" or "Task completed.")) -- 4906
			return -- 4906
		end) -- 4906
		____try = ____try.catch( -- 4906
			____try, -- 4906
			function(____, e) -- 4906
				return __TS__AsyncAwaiter(function() -- 4906
					____hasReturned = true -- 4909
					____returnValue = finalizeAgentFailure( -- 4909
						shared, -- 4909
						tostring(e) -- 4909
					) -- 4909
					return -- 4909
				end) -- 4909
			end -- 4909
		) -- 4909
		__TS__Await(____try) -- 4822
		if ____hasReturned then -- 4822
			return ____awaiter_resolve(nil, ____returnValue) -- 4822
		end -- 4822
	end) -- 4822
end -- 4728
function ____exports.runCodingAgent(options, callback) -- 4913
	local ____self_187 = runCodingAgentAsync(options) -- 4913
	____self_187["then"]( -- 4913
		____self_187, -- 4913
		function(____, result) return callback(result) end -- 4914
	) -- 4914
end -- 4913
return ____exports -- 4913